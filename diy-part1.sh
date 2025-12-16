#!/bin/bash

echo -e "\n===== 开始执行 diy-part1.sh（feeds update 前配置）=====\n"

# ====================== 1. 屏蔽官方 feeds 中的重复包（源头杜绝拉取） ======================
echo "🔧 屏蔽官方 feeds 中的目标包..."
# 屏蔽 feeds/packages 中的 phicomm-k3screenctrl
sed -i '/packages/ s/$/ --exclude=phicomm-k3screenctrl/' scripts/feeds
# 屏蔽 feeds/luci 中的冲突包
sed -i '/luci/ s/$/ --exclude=luci-app-openclash --exclude=luci-app-k3screenctrl --exclude=luci-theme-argon --exclude=luci-app-nikki/' scripts/feeds

# ====================== 2. 配置自定义 feeds 源（openclash + nikki） ======================
echo -e "\n🔧 配置自定义 feeds 源..."
# 先删除已存在的同名 feeds 配置（避免重复添加）
sed -i '/openclash/d' feeds.conf.default
sed -i '/nikki/d' feeds.conf.default
# 添加自定义 feeds 到配置文件末尾
echo 'src-git openclash https://github.com/vernesong/OpenClash' >> feeds.conf.default
echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki' >> feeds.conf.default

# ====================== 3. 可选：注释官方无用 feeds（如需精简，取消下面注释） ======================
# echo -e "\n🔧 精简官方 feeds..."
# sed -i 's/^src-git telephony/#&/' feeds.conf.default

echo -e "\n===== diy-part1.sh 执行完成 =====\n"

# 删除标准固件包，避免冲突。如果你想用k3wifi，那么就得删除BRCMFMAC_4366C0，因为k3wifi里面已经包含
# sed -i 's/\$(BRCMFMAC_4366C0)//g' target/linux/bcm53xx/image/Makefile

echo '移除bcm53xx中的其他机型，lede最新版本适配你设置的单机型，而不是生成所有，此代码没必要了'
sed -i '421,453d' target/linux/bcm53xx/image/Makefile
sed -i '140,412d' target/linux/bcm53xx/image/Makefile
# sed -i 's/$(USB3_PACKAGES) k3screenctrl/luci-app-k3screenctrl/g' target/linux/bcm53xx/image/Makefile
# 从源码最根源改 K3 的 DEVICE_PACKAGES（你测试有效的版本）
# 下面这行指定编译固件封装锁死的插件！
# sed -i '/define Device\/phicomm_k3/,/endef/s#DEVICE_PACKAGES := .*#DEVICE_PACKAGES := $(IEEE8021X) kmod-brcmfmac k3wifi $(USB3_PACKAGES) k3screenctrl#' target/linux/bcm53xx/image/Makefile
# 下面这行只生成k3这个设备的固件！
# sed -i '/define Device\/phicomm_k3/,/TARGET_DEVICES += phicomm_k3/!{ /define Device\//,/endef/d; /TARGET_DEVICES +=/d }' target/linux/bcm53xx/image/Makefile
# sed -i '/phicomm_k3/a\  DEVICE_PACKAGES += k3screenctrl luci-app-k3screenctrl luci-app-argon-config' target/linux/bcm53xx/image/Makefile
# sed -n '532,538p' target/linux/bcm53xx/image/Makefile
echo '=========Remove other devices of bcm53xx OK!========='


# ================以下备用，多以失效，按顺序最上为最有效====================

# ======== 强制只编译 K3 并生成完整固件（必须用这个完整版！） ========
#cat > target/linux/bcm53xx/image/Makefile <<'EOF'
#define Device/phicomm-k3
#  DEVICE_VENDOR := Phicomm
#  DEVICE_MODEL := K3
#  SOC := bcm4709
#  DEVICE_DTS_CONFIG := config@cv1812cp
#  IMAGE_SIZE := 128m
#  IMAGES := trx
#  DEVICE_PACKAGES := kmod-brcmfmac kmod-brcmfmac_4366c0 firmware-brcmfmac4366c-pcie \
#                     kmod-usb3 kmod-usb-ledtrig-usbport \
#                     k3screenctrl luci-app-k3screenctrl luci-app-argon-config
#  KERNEL := kernel-bin | lzma | fit lzma \$KERNEL
#  KERNEL_INITRAMFS := kernel-bin | lzma | fit lzma \$KERNEL_INITRAMFS
#  IMAGE/trx := append-kernel | pad-to 64k | append-rootfs | pad-rootfs | append-metadata
#endef
#TARGET_DEVICES += phicomm-k3
#EOF


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间（根据编译机型变化,自行调整需要删除的固件名称）
# cat >${GITHUB_WORKSPACE}/Clear <<-EOF
# rm -rf config.buildinfo
# rm -rf feeds.buildinfo
# rm -rf sha256sums
# rm -rf version.buildinfo
# rm -rf openwrt-bcm53xx-generic-phicomm_k3.manifest
# rm -rf *.manifest
# EOF

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
