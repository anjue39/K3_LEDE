#!/bin/bash

echo -e "\n===== 开始执行 diy-part3.sh ====="

echo '添加自定义源'
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
# sed -i '$a src-git small https://github.com/kenzok8/small-package' feeds.conf.default
# echo 'src-git openclash https://github.com/vernesong/OpenClash' >> feeds.conf.default
# echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki' >> feeds.conf.default
# sed -i '$a src-git ECH https://github.com/SunshineList/luci-app-ech-workers' feeds.conf.default
echo "✅ 自定义源添加完成"

# echo '添加jerrykuku的argon主题及设置'
# rm -rf package/lean/luci-theme-argon package/lean/luci-app-argon-config  
# git clone -b https://github.com/jerrykuku/luci-theme-argon package/lean/luci-theme-argon
# git clone -b https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config
# echo "✅ Add argon主题 完成"

echo '拉最新最强的 yangxu52 屏幕插件（覆盖官方旧版）'
rm -rf package/lean/k3screenctrl package/lean/luci-app-k3screenctrl
git clone https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl
echo "✅ Add k3screen plug OK!"

# 删除标准固件包，避免冲突。如果你想用k3wifi，那么就得删除BRCMFMAC_4366C0，因为k3wifi里面已经包含
# sed -i 's/\$(BRCMFMAC_4366C0)//g' target/linux/bcm53xx/image/Makefile

echo '移除bcm53xx中的其他机型，lede最新版本适配你设置的单机型，而不是生成所有，此代码没必要了'
# sed -i '421,453d' target/linux/bcm53xx/image/Makefile
# sed -i '140,412d' target/linux/bcm53xx/image/Makefile
# sed -i 's/$(USB3_PACKAGES) k3screenctrl/luci-app-k3screenctrl/g' target/linux/bcm53xx/image/Makefile
# 从源码最根源改 K3 的 DEVICE_PACKAGES（你测试有效的版本）
# 下面这行指定编译固件封装锁死的插件！
sed -i '/define Device\/phicomm_k3/,/endef/s#DEVICE_PACKAGES := .*#DEVICE_PACKAGES := $(IEEE8021X) kmod-brcmfmac k3wifi $(USB3_PACKAGES)#' target/linux/bcm53xx/image/Makefile
# 下面这行只生成k3这个设备的固件！
# sed -i '/define Device\/phicomm_k3/,/TARGET_DEVICES += phicomm_k3/!{ /define Device\//,/endef/d; /TARGET_DEVICES +=/d }' target/linux/bcm53xx/image/Makefile
# sed -i '/phicomm_k3/a\  DEVICE_PACKAGES += k3screenctrl luci-app-k3screenctrl luci-app-argon-config' target/linux/bcm53xx/image/Makefile
# sed -n '532,538p' target/linux/bcm53xx/image/Makefile
echo "✅ Remove other devices of bcm53xx OK!"

echo '移除主页跑分信息显示'
sed -i 's/ <%=luci.sys.exec("cat \/etc\/bench.log") or ""%>//g' package/lean/autocore/files/arm/index.htm
echo "✅ Remove benchmark display in index OK!"

# ==========================================
# Phicomm K3 专用优化脚本（diy-part1.sh）
# ==========================================

echo "🔧 开始 Phicomm K3 专用优化..."

# 1. 强制回滚 kernel 到 5.15（解决 kernel 6.x 兼容性问题）
echo "→ 回滚 kernel 到 5.15"
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=5.15/g' target/linux/bcm53xx/Makefile
echo "✅ kernel 已锁定为 5.15"

# 2. 替换无线固件为 AC88U 48260 版（xiangfeidexiaohuo 仓库，最佳性能）
echo "→ 替换无线固件为 AC88U 48260 版"
wget -O package/lean/k3wifi/files/brcmfmac4366c-pcie.bin \
    https://raw.githubusercontent.com/xiangfeidexiaohuo/Phicomm-K3_Wireless-Firmware/master/brcmfmac4366c-pcie.bin_ac88.48260
echo "✅ 无线固件已替换（无需手动 mkdir，wget 会自动处理目录）"

# 3. 首次开机自动解锁最大发射功率 31 dBm（2.4G + 5G）
echo "→ 添加首次开机功率解锁脚本"
cat > package/base-files/files/etc/uci-defaults/99-k3-txpower <<EOF
#!/bin/sh
# K3 无线最大功率解锁（31 dBm）
uci set wireless.radio0.txpower='31'   # 2.4G
uci set wireless.radio1.txpower='31'   # 5G
uci commit wireless
wifi reload
rm -f \$0   # 执行完后自动删除本脚本
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-k3-txpower
echo "✅ 功率解锁脚本已添加（首次开机自动执行）"

echo "🎉 K3 优化全部完成！"
echo "   - kernel: 5.15（稳定）"
echo "   - 无线固件: AC88U 48260（最强）"
echo "   - 发射功率: 31 dBm（满血）"

echo -e "\n===== diy-part3.sh 执行完成 =====\n"


# echo '临时替换kernel＜5.10，解决编译问题，等上游修复'
# rm -rf package/kernel
# git clone https://github.com/anjue39/kernel package/kernel
# echo '=========Add kernel hack patch OK!========='

# echo '修改5.4分支为5.4.150'
# sed -i '/^LINUX_VERSION-5.4/c LINUX_VERSION-5.4 = .150' include/kernel-version.mk
# sed -i '/^LINUX_KERNEL_HASH-5.4/c LINUX_KERNEL_HASH-5.4.150 = f424a9bbb05007f04c17f96a2e4f041a8001554a9060d2c291606e8a97c62aa2' include/kernel-version.mk
# wget -nv https://github.com/yangxu52/OP-old-kernel-target/raw/main/target-5.4.150.tar.gz
# rm -rf ./target/
# tar -zxf ./target-5.4.150.tar.gz
# rm -rf ./target-5.4.150.tar.gz
# echo '=========Alert kernel to 5.4.150 OK!========='

# mkdir -p files/etc/hotplug.d/block && curl -fsSL https://raw.githubusercontent.com/281677160/openwrt-package/usb/block/10-mount > files/etc/hotplug.d/block/10-mount

# echo '替换K3屏幕驱动插件'
# rm -rf package/lean/k3screenctrl
# git clone https://github.com/RLEDE/k3screenctrl_build.git package/lean/k3screenctrl/
# echo '=========Replace k3screen drive plug OK!========='

# echo '替换K3的无线驱动'
# wget -nv https://github.com/RLEDE/target/raw/main/brcmfmac4366c-pcie.bin -O package/lean/k3-brcmfmac4366c-firmware/files/lib/firmware/brcm/brcmfmac4366c-pcie.bin
# echo '=========Replace k3wifi OK!========='

# echo '添加theme'
# git clone https://github.com/abctel/luci-theme-edge.git package/lean/luci-theme-edge
# git clone https://github.com/thinktip/luci-theme-neobird.git package/lean/luci-theme-neobird
# echo '=========Add theme OK!========='

# sed -i 's|^TARGET_|# TARGET_|g; s|# TARGET_DEVICES += phicomm_k3|TARGET_DEVICES += phicomm_k3|' target/linux/bcm53xx/image/Makefile

# Add a feed source
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
# echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# Add cpufreq
#rm -rf package/lean/luci-app-cpufreq
#svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
#ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq

#添加主页的CPU温度显示
# sed -i "/<tr><td width=\"33%\"><%:Load Average%>/a \ \t\t<tr><td width=\"33%\"><%:CPU Temperature%></td><td><%=luci.sys.exec(\"sed 's/../&./g' /sys/class/thermal/thermal_zone0/temp|cut -c1-4\")%></td></tr>" feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
# cat feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm |grep Temperature
# echo "Add CPU Temperature in Admin Index OK====================="
