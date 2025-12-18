#!/bin/bash
set -e  # 出错立即终止，便于定位问题

# ====================== 脚本配置区（根据你的实际路径修改） ======================
# LEDE 源码根目录（本地路径，示例：~/lede）
LEDES_DIR="$HOME/lede1"
# DIY 脚本文件名（默认和此脚本同目录）
DIY_P1="diy-part1.sh"
DIY_P2="diy-part2.sh"
# ===============================================================================

# 脚本标题
echo -e "\n====================================="
echo -e "  OpenWrt 编译前置一键脚本"
echo -e "=====================================\n"

# 1. 检查 LEDE 源码目录是否存在
if [ ! -d "$LEDES_DIR" ]; then
    echo -e "❌ 错误：LEDE 源码目录不存在 → $LEDES_DIR"
    echo -e "请先克隆源码，或修改脚本中的 LEDES_DIR 路径"
    exit 1
fi

# 2. 进入 LEDE 源码根目录
echo -e "🔧 进入 LEDE 源码目录 → $LEDES_DIR"
cd "$LEDES_DIR" || { echo "❌ 无法进入源码目录"; exit 1; }

# 3. 检查 diy-part1.sh/diy-part2.sh 是否存在
if [ ! -f "$DIY_P1" ] || [ ! -f "$DIY_P2" ]; then
    echo -e "❌ 错误：缺少 DIY 脚本"
    echo -e "请确保 $DIY_P1 和 $DIY_P2 放在 $LEDES_DIR 目录下"
    exit 1
fi

# 4. 给 DIY 脚本添加可执行权限
echo -e "🔧 赋予脚本可执行权限..."
chmod +x "$DIY_P1" "$DIY_P2"

# 5. 执行 diy-part1.sh（feeds update 前配置）
echo -e "\n===== 执行 $DIY_P1 ====="
./"$DIY_P1"

# 6. 执行 feeds update + install 核心命令
echo -e "\n===== 执行 feeds update -a ====="
./scripts/feeds update -a

echo -e "\n===== 执行 feeds install -a ====="
./scripts/feeds install -a

# 7. 执行 diy-part2.sh（feeds install 后处理）
echo -e "\n===== 执行 $DIY_P2 ====="
./"$DIY_P2"

# 8. 执行完成提示
echo -e "\n====================================="
echo -e "✅ 编译前置流程全部完成！"
echo -e "下一步可执行：make defconfig && make -j$(nproc)"
echo -e "=====================================\n"
