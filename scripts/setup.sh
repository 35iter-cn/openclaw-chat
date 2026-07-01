#!/usr/bin/env bash
# =============================================================================
# setup.sh — 一键初始化脚本
# =============================================================================
# 克隆上游仓库到本地，准备 Docker 构建上下文。
# 运行方式：bash scripts/setup.sh
# =============================================================================

set -euo pipefail

UPSTREAM_DIR="_upstream"
REPOS=(
  "openclaw|https://github.com/openclaw/openclaw.git|main"
  "claw-control|https://github.com/adarshmishra07/claw-control.git|main"
)

echo "================================================"
echo "  OpenClaw + Claw Control — 初始化"
echo "================================================"

cd "$(dirname "$0")/.."  # 切换到项目根目录
mkdir -p "$UPSTREAM_DIR"

for entry in "${REPOS[@]}"; do
  IFS='|' read -r name url branch <<< "$entry"
  target="$UPSTREAM_DIR/$name"

  if [ -d "$target/.git" ]; then
    echo ""
    echo "⟳ $name — 已存在，更新中..."
    cd "$target" && git fetch origin && git reset --hard "origin/$branch" && cd ..
  else
    echo ""
    echo "⟳ $name — 克隆中..."
    git clone --depth 1 --branch "$branch" "$url" "$target"
  fi

  echo "   ✓ $name: $(git -C "$target" rev-parse --short HEAD)"
done

echo ""
echo "================================================"
echo "  ✓ 初始化完成！运行 'docker compose up -d' 启动"
echo "================================================"
