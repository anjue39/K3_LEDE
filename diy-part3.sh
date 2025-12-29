#!/bin/bash

echo -e "\n===== 开始执行 diy-part3.sh ====="

echo '添加自定义源'
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
# sed -i '$a src-git small https://github.com/kenzok8/small-package' feeds.conf.default
echo "✅ 自定义源添加完成"

echo '添加jerrykuku的argon主题及设置'
rm -rf package/lean/luci-theme-argon package/lean/luci-app-argon-config  
git clone -b https://github.com/jerrykuku/luci-theme-argon package/lean/luci-theme-argon
git clone -b https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config
echo "✅ Add argon主题 完成"

echo '拉最新最强的 yangxu52 屏幕插件（覆盖官方旧版）'
rm -rf package/lean/k3screenctrl package/lean/luci-app-k3screenctrl
git clone https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl
echo "✅ Add k3screen plug OK!"

# 删除标准固件包，避免冲突。如果你想用k3wifi，那么就得删除BRCMFMAC_4366C0，因为k3wifi里面已经包含
# sed -i 's/\$(BRCMFMAC_4366C0)//g' target/linux/bcm53xx/image/Makefile

echo '移除bcm53xx中的其他机型，lede最新版本适配你设置的单机型，而不是生成所有，此代码没必要了'
sed -i '/define Device\/phicomm_k3/,/endef/s#DEVICE_PACKAGES := .*#DEVICE_PACKAGES := $(IEEE8021X) kmod-brcmfmac k3wifi $(USB3_PACKAGES)#' target/linux/bcm53xx/image/Makefile
echo "✅ Remove other devices of bcm53xx OK!"

echo '移除主页跑分信息显示'
sed -i 's/ <%=luci.sys.exec("cat \/etc\/bench.log") or ""%>//g' package/lean/autocore/files/arm/index.htm
echo "✅ Remove benchmark display in index OK!"

echo "🔧 开始 Phicomm K3 专用优化..."
# 首次开机自动解锁平衡增强发射功率 28 dBm（2.4G + 5G）
echo "→ 添加首次开机功率解锁脚本"
cat > package/base-files/files/etc/uci-defaults/99-k3-txpower <<EOF
#!/bin/sh
# K3 无线最大功率解锁（31 dBm）
uci set wireless.radio0.txpower='28'   # 2.4G
uci set wireless.radio1.txpower='28'   # 5G
uci commit wireless
wifi reload
rm -f \$0   # 执行完后自动删除本脚本
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-k3-txpower
echo "✅ 功率解锁脚本已添加（首次开机自动执行）"

echo "🎉 K3 优化全部完成！"
echo "   - 发射功率: 28 dBm（平衡加强）"

echo -e "\n===== diy-part3.sh 执行完成 =====\n"
