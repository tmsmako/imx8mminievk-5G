# references 
devcontainer and yocto-build script implementations are based on the following materials from NXP
https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX
https://www.nxp.com/docs/en/user-guide/IMX_YOCTO_PROJECT_USERS_GUIDE.pdf
https://source.codeaurora.org/external/imx/imx-docker/tree/

# kernel
see in `./yocto/imx-5.10.35-2.0.0-build/sources/meta-freescale/conf/machine/include/imx-base.inc` the following lines: `IMX_DEFAULT_KERNEL = "linux-fslc-imx"` and `IMX_DEFAULT_KERNEL_mx8 = "linux-fslc-imx"`
and
`./yocto/imx-5.10.35-2.0.0-build/sources/meta-freescale/recipes-kernel/linux`

https://community.nxp.com/t5/i-MX-Processors/what-is-the-purpose-of-linux-fslc-git/m-p/1047602

# enable generic cellular modem support via USB serial connection
add `CONFIG_USB_SERIAL_OPTION=y` in `imx_v8_defconfig` then (re-)build

# get list of recipes
run `bitbake -g $IMAGES` then look into the generated file 'pn-buildlist'