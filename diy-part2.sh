#!/bin/bash

echo -e "\n===== 开始执行 diy-part2.sh（feeds install 后处理）=====\n"

# ====================== 1. 清理 feeds 残留和重复包 ======================
echo "🔧 清理 feeds 残留包..."
# 清理 feeds 目录下的冲突包
rm -rf feeds/packages/util/phicomm-k3screenctrl 2>/dev/null
rm -rf feeds/luci/applications/luci-app-openclash 2>/dev/null
rm -rf feeds/luci/applications/luci-app-k3screenctrl 2>/dev/null
rm -rf feeds/luci/themes/luci-theme-argon 2>/dev/null
rm -rf feeds/luci/applications/luci-app-nikki 2>/dev/null

# 清理 package/feeds 下的软链接
rm -rf package/feeds/packages/phicomm-k3screenctrl 2>/dev/null
rm -rf package/feeds/luci/luci-app-openclash 2>/dev/null
rm -rf package/feeds/luci/luci-app-k3screenctrl 2>/dev/null
rm -rf package/feeds/luci/luci-theme-argon 2>/dev/null
rm -rf package/feeds/luci/luci-app-nikki 2>/dev/null

# ====================== 2. 清理 package/lean 中的旧包 ======================
echo -e "\n🔧 清理 package/lean 旧包..."
rm -rf package/lean/phicomm-k3screenctrl 2>/dev/null
rm -rf package/lean/luci-app-openclash 2>/dev/null
rm -rf package/lean/luci-app-k3screenctrl 2>/dev/null
rm -rf package/lean/luci-theme-argon 2>/dev/null
rm -rf package/lean/luci-app-argon-config 2>/dev/null
rm -rf package/lean/luci-app-nikki 2>/dev/null
rm -rf package/lean/k3screenctrl 2>/dev/null

# ====================== 3. 手动克隆高优先级包（openclash + nikki） ======================
echo -e "\n🔧 手动克隆自定义包到 package/lean..."
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash package/lean/luci-app-openclash
git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/lean/luci-app-nikki

# ====================== 4. 手动克隆高优先级包（argon + k3screenctrl） ======================
echo -e "\n🔧 手动克隆自定义包到 package/lean..."
# 克隆 argon 主题 + 配置
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-theme-argon package/lean/luci-theme-argon
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config

# 克隆 k3screenctrl 主程序 + luci 控制界面
git clone --depth=1 https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone --depth=1 https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl

# ====================== 5. 系统配置修改（主机名+默认IP，精准匹配） ======================
echo -e "\n🔧 修改系统默认配置..."
# 修改主机名（精准匹配，避免误伤其他行）
sed -i 's/hostname='"'"'LEDE'"'"'/hostname='"'"'PHICOMM'"'"'/g' package/base-files/files/bin/config_generate
echo "✅ 主机名已修改为 PHICOMM"
grep -E "hostname=" package/base-files/files/bin/config_generate | grep -v '#'

# 修改默认 LAN IP（整行精准匹配，避免改到 wan 口）
sed -i 's/lan) ipad=\${ipaddr:-"192\.168\.1\.1"} ;;$/lan) ipad=${ipaddr:-"192.168.2.1"} ;;/g' package/base-files/files/bin/config_generate
echo "✅ 默认 LAN IP 已修改为 192.168.2.1"
grep -E "192.168.2.1" package/base-files/files/bin/config_generate | grep -v '#'

# 修改插件名称（保留你的配置）
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
# sed -i 's/"aMule设置"/"电驴下载"/g' `grep "aMule设置" -rl ./`
# sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./`
# sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
# sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
# sed -i 's/"TTYD 终端"/"命令窗"/g' `grep "TTYD 终端" -rl ./`
# sed -i 's/"Web 管理"/"Web"/g' `grep "Web 管理" -rl ./`
# sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./`
# sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
# sed -i 's/"ShadowSocksR Plus+"/"SSR Plus+"/g' `grep "ShadowSocksR Plus+" -rl ./`
echo "✅ 插件名称已修改完成"

# ====================== 6. 更新配置（让编译系统感知变化） ======================
echo -e "\n🔧 更新编译配置..."
make defconfig > /dev/null 2>&1
echo "✅ 编译配置已更新"

echo -e "\n===== diy-part2.sh 执行完成 =====\n"



# 以下是备用自定义配置，去'#'后才会执行，非必要不添加

# echo '修改默认主题'
# sed -i 's/luci-theme-bootstrap/luci-theme-infinityfreedom/g' feeds/luci/collections/luci/Makefile 
# echo '=========Alert Default theme OK!========='

# echo '修改upnp绑定文件位置'
# sed -i 's/\/var\/upnp.leases/\/tmp\/upnp.leases/g' feeds/packages/net/miniupnpd/files/upnpd.config
# cat feeds/packages/net/miniupnpd/files/upnpd.config |grep upnp_lease_file
# echo '=========Alert upnp binding file directory!========='

# 修改NTP设置
# sed -i "s/'0.openwrt.pool.ntp.org'/'ntp1.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'1.openwrt.pool.ntp.org'/'ntp2.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'2.openwrt.pool.ntp.org'/'ntp3.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'3.openwrt.pool.ntp.org'/'ntp4.aliyun.com'/g" package/base-files/files/bin/config_generate
# cat package/base-files/files/bin/config_generate |grep system.ntp.server=
# echo 'Alert NTP Settings OK!====================='
