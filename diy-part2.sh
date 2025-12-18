#!/bin/bash

echo -e "\n===== 开始执行 diy-part2.sh（深度清理与配置补丁）=====\n"

# ====================== 1. 深度清理：防止包冲突 ======================
echo "🔧 正在执行深度清理，防止包冲突..."

# A. 清理 feeds 源码目录中的冲突项
rm -rf feeds/packages/util/phicomm-k3screenctrl 2>/dev/null
rm -rf feeds/luci/applications/luci-app-openclash 2>/dev/null
rm -rf feeds/luci/applications/luci-app-k3screenctrl 2>/dev/null
rm -rf feeds/luci/themes/luci-theme-argon 2>/dev/null
rm -rf feeds/luci/applications/luci-app-nikki 2>/dev/null

# B. 清理 package/feeds 下的软链接（彻底抹除 menuconfig 旧索引）
rm -rf package/feeds/packages/phicomm-k3screenctrl 2>/dev/null
rm -rf package/feeds/luci/luci-app-openclash 2>/dev/null
rm -rf package/feeds/luci/luci-app-k3screenctrl 2>/dev/null
rm -rf package/feeds/luci/luci-theme-argon 2>/dev/null
rm -rf package/feeds/luci/luci-app-nikki 2>/dev/null

# C. 清理 package/lean 中的旧包（防止手动克隆冲突）
rm -rf package/lean/luci-app-openclash 2>/dev/null
rm -rf package/lean/luci-app-nikki 2>/dev/null
rm -rf package/lean/luci-theme-argon 2>/dev/null
rm -rf package/lean/luci-app-argon-config 2>/dev/null
rm -rf package/lean/k3screenctrl 2>/dev/null
rm -rf package/lean/luci-app-k3screenctrl 2>/dev/null
echo "✅ 冗余包清理完成"

# ====================== 2. 重新安装插件：强制指定源 ======================
echo "🔧 正在重新建立插件索引并安装..."

# 更新特定索引
./scripts/feeds update openclash nikki

# 强制安装：-f 参数确保即便有同名包，也以指定源（-p）为准
./scripts/feeds install -f -p openclash luci-app-openclash
./scripts/feeds install -f -p nikki luci-app-nikki

# 安装其余所有依赖包（补全底层库）
# ./scripts/feeds install -a
echo "✅ 插件 feeds 安装与链接完成"

# ====================== 3. 手动克隆高优先级包 ======================
echo "🔧 正在克隆自定义包到 package/lean..."
# 克隆 argon 主题 + 配置 (使用 18.06 分支适配旧版 LuCI)
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-theme-argon package/lean/luci-theme-argon
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config

# 克隆 k3screenctrl 屏幕控制插件
git clone --depth=1 https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone --depth=1 https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl
echo "✅ 手动包克隆完成"

# ====================== 4. 系统配置修改 ======================
echo "🔧 正在修改系统默认配置..."

# A. 修改主机名（LEDE -> PHICOMM）
sed -i 's/hostname='"'"'LEDE'"'"'/hostname='"'"'PHICOMM'"'"'/g' package/base-files/files/bin/config_generate
echo "✅ 主机名已修改为: PHICOMM"

# B. 修改默认 LAN IP（192.168.1.1 -> 192.168.2.1）
sed -i 's/lan) ipad=\${ipaddr:-"192\.168\.1\.1"} ;;$/lan) ipad=${ipaddr:-"192.168.2.1"} ;;/g' package/base-files/files/bin/config_generate
echo "✅ 默认 LAN IP 已修改为: 192.168.2.1"

# C. 修改插件名称
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./` 2>/dev/null
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./` 2>/dev/null
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./` 2>/dev/null
echo "✅ 菜单名称优化完成"

# ====================== 5. 刷新索引：确保 menuconfig 可见 ======================
echo "🔧 正在刷新编译缓存并同步配置..."

# 彻底删除 tmp 目录是解决“找不到插件”问题的终极方案
rm -rf tmp
echo "✅ tmp 缓存已清理"

# 预生成配置（会让 menuconfig 启动时直接加载新变更）
make defconfig > /dev/null 2>&1
echo "✅ 编译配置文件 (defconfig) 已刷新"

echo -e "\n===== ✅ diy-part2.sh 执行成功 =====\n"

#------------------------------------------------
# 以下是备用自定义配置，去'#'后才会执行，非必要不添加

# echo '修改默认主题'
# sed -i 's/luci-theme-bootstrap/luci-theme-infinityfreedom/g' feeds/luci/collections/luci/Makefile 
# echo '=========Alert Default theme OK!========='

# echo '修改upnp绑定文件位置'
# sed -i 's/\/var\/upnp.leases/\/tmp\/upnp.leases/g' feeds/packages/net/miniupnpd/files/upnpd.config
# cat feeds/packages/net/miniupnpd/files/upnpd.config |grep upnp_lease_file
# echo '=========Alert upnp binding file directory!========='

# sed -i 's/"aMule设置"/"电驴下载"/g' `grep "aMule设置" -rl ./`
# sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./`
# sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
# sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
# sed -i 's/"TTYD 终端"/"命令窗"/g' `grep "TTYD 终端" -rl ./`
# sed -i 's/"Web 管理"/"Web"/g' `grep "Web 管理" -rl ./`
# sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./`
# sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
# sed -i 's/"ShadowSocksR Plus+"/"SSR Plus+"/g' `grep "ShadowSocksR Plus+" -rl ./


# 修改NTP设置
# sed -i "s/'0.openwrt.pool.ntp.org'/'ntp1.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'1.openwrt.pool.ntp.org'/'ntp2.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'2.openwrt.pool.ntp.org'/'ntp3.aliyun.com'/g" package/base-files/files/bin/config_generate
# sed -i "s/'3.openwrt.pool.ntp.org'/'ntp4.aliyun.com'/g" package/base-files/files/bin/config_generate
# cat package/base-files/files/bin/config_generate |grep system.ntp.server=
# echo 'Alert NTP Settings OK!====================='
