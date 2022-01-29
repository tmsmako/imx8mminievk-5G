#!/bin/bash

# immediately exit on error
set -e

# make sure that we are running from container
if [ -f /.dockerenv ]; then
    echo "Running from container $(hostname) ..";
else
    echo "ERROR: Must run from container";
    exit 1
fi

# environment variables
DOCKER_IMAGE_TAG="imx-yocto"
DOCKER_WORKDIR="/workspaces/imx8mminievk/yocto"
IMX_RELEASE="imx-5.4.70-2.3.0"
YOCTO_DIR="${DOCKER_WORKDIR}/${IMX_RELEASE}-build"
MACHINE="imx8mmevk"
DISTRO="fsl-imx-xwayland"
IMAGES="imx-image-core" # core-image-minimal, imx-image-multimedia
REMOTE="https://source.codeaurora.org/external/imx/imx-manifest"
BRANCH="imx-linux-hardknott"
MANIFEST=${IMX_RELEASE}".xml"
# K_BUILDDIR="/tmp/work/imx8mmevk-poky-linux/linux-imx/5.10.35+gitAUTOINC+ef3f2cfc60-r0/"

# Create build folder
mkdir -p ${YOCTO_DIR}
cd ${YOCTO_DIR}

# configure git user (required for repo setup script)
git config --global user.name "pentaloon"
git config --global user.email "pentaloon@gmail.com"

# Init repo
repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST}

repo sync -j8

# source the yocto env
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

# update kernel config - this method is not preferred, create a new layer instead
# if [[ -d "$(pwd)$K_BUILDDIR" ]]; then
#     echo "* overriding kernel config"
#     cp ./../../../defconfig ./$K_BUILDDIR/defconfig
#     cp ./../../../.config ./$K_BUILDDIR/build/.config
# fi

# override local conf - this method is not preferred, create a new layer instead
# if [[ -d "$(pwd)" ]]; then
#     echo "* overriding local.conf"
#     cp ./../../../local.conf ./conf/local.conf
# fi

function print_help
{
    echo ""
    echo "Usage: bb [args]"
    echo "  -b --build [target]         build a specific image or recipe"
    echo "  -c --compile [target]       run (force) tasks starting from 'do_compile' on a specific recipe"
    echo "  -r --rebuild [target]       re-build a specific image or recipe (clears sstate-cache)"
    echo "  -d --dependencies [target]  show dependencies of recipe/image"
    echo "  -m --menuconfig             execute menuconfig on virtual/kernel"
    echo ""
    echo " just run without any arguments to build $IMAGES (default)"
    echo ""
    echo " to rebuild the kernel image:"
    echo "  bb -c virtual/kernel"
    echo ""
    echo " to rebuild $IMAGES (default)"
    echo "  bb -r"
    echo ""
}

case "$@" in
    -b*|--build*)
        if [ $# -ne 2 ]; then
            print_help
            exit -1
        fi
        echo "* building '$2'"
        bitbake -c $2
        ;;
    -r*|--rebuild*)
        if [ $# -eq 1 ]; then
            echo "* re-building '$IMAGES' (default)"
            bitbake $IMAGES -c cleansstate && bitbake $IMAGES
        elif [ $# -eq 2 ]; then
            echo "* re-building '$2'"
            bitbake $2 -c cleansstate && bitbake $2
        else
            print_help
            exit -1
        fi
        ;;
    -c*|--compile*)
        if [ $# -ne 2 ]; then
            print_help
            exit -1
        fi
        echo "* (re-)compile $2"
        # bitbake -f -c compile $2
        # bitbake $2
        bitbake $2 -C compile
        ;;
    -d*|--dependencies*)
        if [ $# -ne 2 ]; then
            print_help
            exit -1
        fi
        bitbake -g $2 && clear && cat ./pn-buildlist
        ;;
    -m*|--menuconfig*)
        if [ $# -ne 1 ]; then
            print_help
            exit -1
        fi
        bitbake virtual/kernel -c menuconfig
        ;;
    *)
        if [ $# -ne 0 ]; then
            print_help
            exit -1
        fi
        echo "* building '$IMAGES' (default)"
        bitbake ${IMAGES}
        ;;
esac
