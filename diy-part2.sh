#!/bin/bash

echo -e "\n===== 开始执行 diy-part2.sh（feeds install 后处理）=====\n"

# ====================== 1. 清理 feeds 残留和重复包 ======================
echo "🔧 清理 feeds 残留包..."
# 清理 feeds 目录下的冲突包
rm -rf feeds/packages/util/phicomm-k3screenctrl  feeds/pack
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

# ====================== 3. 安装自定义 feeds 包（openclash + nikki） ======================
echo -e "\n🔧 安装自定义 feeds 包..."
./scripts/feeds update openclash nikki
./scripts/feeds install -a -p openclash
./scripts/feeds install -a -p nikki

# ====================== 4. 手动克隆高优先级包（argon + k3screenctrl） ======================
echo -e "\n🔧 手动克隆自定义包到 package/lean..."
# 克隆 argon 主题 + 配置
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-theme-argon package/lean/luci-theme-argon
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config

# 克隆 k3screenctrl 主程序 + luci 控制界面
git clone --depth=1 https://github.com/yangxu52/k3screenctrl_build.git package/lean/k3screenctrl
git clone --depth=1 https://github.com/yangxu52/luci-app-k3screenctrl.git package/lean/luci-app-k3screenctrl

# ====================== 5. 可选：将 feeds 包迁移到 package/lean 提升优先级（如需，取消注释） ======================
# echo -e "\n🔧 提升 feeds 包优先级..."
# cp -rf package/feeds/openclash/* package/lean/ 2>/dev/null
# cp -rf package/feeds/nikki/* package/lean/ 2>/dev/null

echo -e "\n===== diy-part2.sh 执行完成 =====\n"

echo '修改主机名'
sed -i "s/hostname='LEDE'/hostname='PHICOMM'/g" package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate |grep hostname=
echo '=========Alert hostname OK!========='

echo '修改路由器默认IP'
# 精准只改 lan 接口那一行，避免误伤其他地方
sed -i 's/"192\.168\.1\.1"/"192.168.2.1"/g' package/base-files/files/bin/config_generate
# 或者更严谨的整行匹配（你以前用过的）
# sed -i 's/^\s*lan) ipad=\${ipaddr:-"192\.168\.1\.1"} ;;$/lan) ipad=${ipaddr:-"192.168.2.1"} ;;/' package/base-files/files/bin/config_generate

echo '=========Alert default IP OK!========='

# 修改插件名字
# sed -i 's/"aMule设置"/"电驴下载"/g' `grep "aMule设置" -rl ./`
# sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
# sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
# sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
# sed -i 's/"TTYD 终端"/"命令窗"/g' `grep "TTYD 终端" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
# sed -i 's/"Web 管理"/"Web"/g' `grep "Web 管理" -rl ./`
# sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./`
# sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
# sed -i 's/"ShadowSocksR Plus+"/"SSR Plus+"/g' `grep "ShadowSocksR Plus+" -rl ./`



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
