# references 
devcontainer and yocto-build script implementations are based on the following materials from NXP
https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX
https://www.nxp.com/docs/en/user-guide/IMX_YOCTO_PROJECT_USERS_GUIDE.pdf
https://source.codeaurora.org/external/imx/imx-docker/tree/
https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Useful-bitbake-commands/ta-p/1128559
https://easylinuxji.blogspot.com/2019/03/replace-default-splash-screen-in-yocto.html
https://www.nxp.com/design/training/i-mx-8m-mini-and-linux-online-hands-on:TIP-I-MX-8M-MINI-AND-LINUX-ONLINE-HANDS-ON
https://docs.docker.com/engine/reference/builder/
https://elinux.org/Bitbake_Cheat_Sheet

# kernel

## enable generic cellular modem support via USB serial connection
* run `bitbake virtual/kernel -c menuconfig`
* set `CONFIG_USB_SERIAL_OPTION=y` by selecting *device drivers/usb support/usb serial converter support/usb driver for GSM and CDMA modems*
* save `.config`
* save defconfig `ARCH=arm64 make savedefconfig`
* overwrite defconfig file `yocto/imx-{ver}-build/build_fsl-imx-xwayland/tmp/work/imx8mmevk-poky-linux/linux-imx/{kernel}/defconfig` 
* rebuild kernel

## add recipes to image
* yocto/imx-5.10.35-2.0.0-build/conf/local.conf
* yocto/imx-5.10.35-2.0.0-build/build_fsl-imx-xwayland/conf/local.conf

## package management
`IMAGE_INSTALL_append = " gnupg"`

## modem support
`IMAGE_INSTALL_append = " ppp"`
* rebuild image

## get list of recipes
run `bitbake -g $IMAGES` then look into the generated file 'pn-buildlist'