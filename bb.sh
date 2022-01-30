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

# workaround
git config --global user.name "pentaloon"
git config --global user.email "pentaloon@gmail.com"

#setup environment variables
ROOT_DIR=$(pwd)
source imx-5.4.70-2.5.3/env.sh

if [[ -d "${YOCTO_DIR}/build_${DISTRO}/tmp/work" ]]; then
    echo "starting up from existing repo: ${YOCTO_DIR}"
    cd ${YOCTO_DIR}
else
    echo "setting up a new repo: ${YOCTO_DIR}"
    # Create build folder
    mkdir -p ${YOCTO_DIR}
    cd ${YOCTO_DIR}

    # init repo
    repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST}
    repo sync -j8
fi

# source the yocto env
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO}

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
