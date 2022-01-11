#!/bin/bash
# This script is expected to run in devcontainer
# Building the core image consumes ~ 115 GB. 
# Before kicking off a build, make sure that you have enough free space on the drive

# immediately exit on error
set -e

# environment variables
DOCKER_IMAGE_TAG="imx-yocto"
DOCKER_WORKDIR="/workspaces/imx8mminievk/yocto"
IMX_RELEASE="imx-5.10.35-2.0.0"
YOCTO_DIR="${DOCKER_WORKDIR}/${IMX_RELEASE}-build"
MACHINE="imx8mmevk"
DISTRO="fsl-imx-xwayland"
IMAGES="imx-image-multimedia"
REMOTE="https://source.codeaurora.org/external/imx/imx-manifest"
BRANCH="imx-linux-hardknott"
MANIFEST=${IMX_RELEASE}".xml"
K_DEFCONFIG="imx_v8_defconfig"

# Create build folder
mkdir -p ${YOCTO_DIR}
cd ${YOCTO_DIR}

# configure git user (required for repo setup script)
git config --global user.name "vscode"
git config --global user.email "dev@example.org"

# Init repo
repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST}

repo sync -j12

# source the yocto env
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

# update kernel config
if [[ -d "$(pwd)/tmp/" ]]; then
    echo "using $(pwd)/$K_DEFCONFIG"
    cp ./../../../$K_DEFCONFIG ./tmp/work/cortexa53-crypto-mx8mn-poky-linux/linux-imx-headers/5.10-r0/git/arch/arm64/configs/
    cp ./../../../$K_DEFCONFIG ./tmp/work-shared/imx8mnevk/kernel-source/arch/arm64/configs/
fi

function print_help
{
    echo ""
    echo "Usage: bb [args]"
    echo "  -b --build [target]     build a specific image or recipe"
    echo "  -c --compile [target]   run (force) tasks starting from 'do_compile' on a specific recipe"
    echo "  -r --rebuild [target]   re-build a specific image or recipe (clears sstate-cache)"
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
        bitbake $2 -C compile
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
