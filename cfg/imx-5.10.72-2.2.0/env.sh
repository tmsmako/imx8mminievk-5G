#!/bin/bash
DOCKER_IMAGE_TAG="imx-yocto"
DOCKER_WORKDIR="${ROOT_DIR}/yocto"
IMX_RELEASE="imx-5.10.72-2.2.0"
YOCTO_DIR="${DOCKER_WORKDIR}/${IMX_RELEASE}-build"
MACHINE="imx8mmevk"
DISTRO="fsl-imx-xwayland"
IMAGES="imx-image-core" # core-image-minimal, imx-image-multimedia
REMOTE="https://source.codeaurora.org/external/imx/imx-manifest"
BRANCH="imx-linux-hardknott"
MANIFEST=${IMX_RELEASE}".xml"
