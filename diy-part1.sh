#!/bin/bash
echo "K3 专用修复版 —— 强制加回 k3wifi + 最新屏幕（永不卡条+WiFi满血）"

# 第一步：强制把 k3wifi 塞进固件（这是解决无WiFi和卡条的命根子！
sed -i '/define Device\/phicomm_k3/,/endef/s/DEVICE_PACKAGES := .*/DEVICE_PACKAGES := kmod-brcmfmac k3wifi kmod-usb3 kmod-usb-ledtrig-usbport k3screenctrl luci-app-k3screenctrl/' target/linux/bcm53xx/image/Makefile

# 第二步：拉最新最强的 yangxu52 屏幕插件（覆盖官方旧版）
rm -rf package/lean/k3screenctrl package/lean/luci-app-k3screenctrl
git clone https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl

# 其他插件照常加
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default

git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/lean/luci-app-argon-config

echo "K3 修复完成：k3wifi 已强塞，屏幕已升级最新版"
