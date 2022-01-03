#!/bin/bash
# This script is expected to run in devcontainer
# Building the core image consumes ~ 115 GB. 
# Before kicking off a build, make sure that you have enough free space on the drive

# environment variables
DOCKER_IMAGE_TAG="imx-yocto"
DOCKER_WORKDIR="/workspaces/imx8mminievk/yocto"
IMX_RELEASE="imx-5.10.35-2.0.0"
YOCTO_DIR="${DOCKER_WORKDIR}/${IMX_RELEASE}-build"
MACHINE="imx8mnevk"
DISTRO="fsl-imx-xwayland"
IMAGES="imx-image-core"
REMOTE="https://source.codeaurora.org/external/imx/imx-manifest"
BRANCH="imx-linux-hardknott"
MANIFEST=${IMX_RELEASE}".xml"

# Create build folder
mkdir -p ${YOCTO_DIR} && \
cd ${YOCTO_DIR} && \

# configure git user (required for repo setup script)
git config --global user.name "vscode"
git config --global user.email "dev@example.org"

# Init repo
repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST} && \

repo sync -j12 && \

# source the yocto env
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b build_${DISTRO} && \

# Build
bitbake ${IMAGES}