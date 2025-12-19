#!/bin/bash

# ====================== 1. 系统配置修改 ======================
echo "🔧 正在修改系统默认配置..."

# A. 修改主机名（LEDE -> PHICOMM）
sed -i 's/hostname='"'"'OpenWrt'"'"'/hostname='"'"'PHICOMM'"'"'/g' package/base-files/files/bin/config_generate
echo "✅ 主机名已修改为: PHICOMM"

# B. 修改默认 LAN IP（192.168.1.1 -> 192.168.2.1）
sed -i 's/lan) ipad=\${ipaddr:-"192\.168\.1\.1"} ;;$/lan) ipad=${ipaddr:-"192.168.2.1"} ;;/g' package/base-files/files/bin/config_generate
echo "✅ 默认 LAN IP 已修改为: 192.168.2.1"

# C. 修改插件名称
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./` 2>/dev/null
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./` 2>/dev/null
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./` 2>/dev/null
echo "✅ 菜单名称优化完成"

# ====================== 2. 刷新索引：确保 menuconfig 可见 ======================
echo "🔧 正在刷新编译缓存并同步配置..."

# 彻底删除 tmp 目录是解决“找不到插件”问题的终极方案
rm -rf tmp
echo "✅ tmp 缓存已清理"

# 预生成配置（会让 menuconfig 启动时直接加载新变更）
make defconfig > /dev/null 2>&1
echo "✅ 编译配置文件 (defconfig) 已刷新"

echo -e "\n===== ✅ diy-part2.sh 执行成功 =====\n"



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
