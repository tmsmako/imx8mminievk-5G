# references 
devcontainer and yocto-build script implementations are based on the following materials from NXP
https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX
https://www.nxp.com/docs/en/user-guide/IMX_YOCTO_PROJECT_USERS_GUIDE.pdf
https://source.codeaurora.org/external/imx/imx-docker/tree/
https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Useful-bitbake-commands/ta-p/1128559

# kernel

# enable generic cellular modem support via USB serial connection
* run `bitbake virtual/kernel -c menuconfig`
* set `CONFIG_USB_SERIAL_OPTION=y` by selecting *device drivers/usb support/usb serial converter support/usb driver for GSM and CDMA modems*
* save `.config`
* save defconfig `make savedefconfig`
* overwrite defconfig file `yocto/imx-5.10.35-2.0.0-build/build_fsl-imx-xwayland/tmp/work/imx8mmevk-poky-linux/linux-imx/5.10.35+gitAUTOINC+ef3f2cfc60-r0/defconfig` 
* rebuild kernel

# get list of recipes
run `bitbake -g $IMAGES` then look into the generated file 'pn-buildlist'