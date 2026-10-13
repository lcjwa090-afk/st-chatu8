#!/usr/bin/env bash
# ============================================================
#  st-chatu8「本地生图 LocalDream 8081」补丁 · 还原成原版
#  用法：bash 还原原版.sh
# ============================================================
set -euo pipefail

IDX="$(find "$HOME" -path '*st-chatu8*/index.js' 2>/dev/null | head -1 || true)"
if [ -z "$IDX" ]; then
  echo "!! 没找到 st-chatu8 扩展目录"
  exit 1
fi
EXT="$(dirname "$IDX")"
cd "$EXT"
echo "目录: $EXT"

if [ ! -f index.js.bak ]; then
  echo "!! 没有找到备份 index.js.bak，无法自动还原。"
  echo "   请直接在 SillyTavern 里删掉扩展重新安装一次原版："
  echo "   https://github.com/damoshen123/st-chatu8"
  exit 1
fi

cp -f index.js.bak index.js
if [ -f manifest.json.bak ]; then
  cp -f manifest.json.bak manifest.json
fi
echo "==> 已还原成原版，回浏览器硬刷新 SillyTavern 页面即可。"
echo "    （还原后备份文件 index.js.bak 还留着，想再装补丁可以直接重跑一键安装.sh）"
