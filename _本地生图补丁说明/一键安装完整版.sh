#!/usr/bin/env bash
# ============================================================
#  st-chatu8（含本地生图补丁）完整版 · 一键安装
#
#  用法：
#    bash 一键安装完整版.sh <完整版zip的路径 或 下载地址>
#
#  例：
#    bash 一键安装完整版.sh /sdcard/Download/st-chatu8-本地生图-完整版.zip
#
#  特点：不需要事先装过原版扩展。
#        如果已经装过 st-chatu8，会自动把它改名备份，不会留两份。
# ============================================================
set -euo pipefail

SRC="${1:-}"
if [ -z "$SRC" ]; then
  echo "用法: bash $0 <完整版zip的路径或下载地址>"
  echo "例:   bash $0 /sdcard/Download/st-chatu8-本地生图-完整版.zip"
  exit 1
fi

# 相对路径先转成绝对路径（脚本后面会 cd 到扩展目录，否则找不到压缩包）
if [ -f "$SRC" ]; then
  SRC="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
fi

echo "==> 1/6 找 SillyTavern 目录"
ST=""
for c in "$HOME/SillyTavern" "$HOME/sillytavern"; do
  [ -d "$c" ] && ST="$c" && break
done
if [ -z "$ST" ]; then
  ST="$(find "$HOME" -maxdepth 3 -type d -name SillyTavern 2>/dev/null | head -1 || true)"
fi
if [ -z "$ST" ]; then
  echo "!! 没找到 SillyTavern 目录（默认只在 Termux 主目录下找）"
  echo "   如果你的 ST 装在别的地方，请用文件管理器手动解压到扩展目录。"
  exit 1
fi
echo "    $ST"

echo "==> 2/6 选扩展目录"
EXIST="$(find "$ST" -maxdepth 6 -type d -name st-chatu8 2>/dev/null | head -1 || true)"
if [ -n "$EXIST" ]; then
  TARGET="$(dirname "$EXIST")"
  echo "    已有 st-chatu8，将原地替换"
else
  if compgen -G "$ST/data/*/extensions" >/dev/null 2>&1; then
    for d in "$ST"/data/*/extensions; do TARGET="$d"; break; done
  else
    TARGET="$ST/public/scripts/extensions/third-party"
  fi
  echo "    首次安装"
fi
[ -d "$TARGET" ] || { echo "!! 扩展目录不存在: $TARGET"; exit 1; }
echo "    $TARGET"

echo "==> 3/6 检查依赖"
command -v unzip >/dev/null 2>&1 || pkg install -y unzip
if [ ! -f "$SRC" ]; then
  command -v curl >/dev/null 2>&1 || pkg install -y curl
fi

echo "==> 4/6 备份已装的 st-chatu8（如果有）"
cd "$TARGET"
if [ -d st-chatu8 ]; then
  BAK="st-chatu8.old-$(date +%Y%m%d-%H%M%S)"
  mv st-chatu8 "$BAK"
  echo "    已改名备份为: $TARGET/$BAK"
  echo "    （不需要了可以整份删掉：rm -rf \"$TARGET/$BAK\"）"
else
  echo "    没有旧版本，跳过"
fi

echo "==> 5/6 准备完整版压缩包"
TMP=".ld-full.zip"
if [ -f "$SRC" ]; then
  echo "    使用本地文件: $SRC"
  cp -f "$SRC" "$TMP"
else
  echo "    下载: $SRC"
  curl -fL --progress-bar -o "$TMP" "$SRC"
fi
ls -l "$TMP"

echo "==> 6/6 解压 + 校验"
unzip -oq "$TMP"
rm -f "$TMP"

N1="$(grep -c localdream_mode st-chatu8/index.js || true)"
N2="$(grep -c localdream_mode st-chatu8/html/settings/sd.html || true)"
echo "    st-chatu8/index.js 命中: $N1  (正确值 3)"
echo "    st-chatu8/html/settings/sd.html 命中: $N2  (正确值 2)"
if [ "$N1" -eq 0 ] || [ "$N2" -eq 0 ]; then
  echo "!! 校验失败，正在回滚..."
  if [ -n "${BAK:-}" ] && [ -d "${BAK:-}" ]; then
    rm -rf st-chatu8
    mv "$BAK" st-chatu8
    echo "   已回滚到原来的 st-chatu8"
  else
    echo "   没有可回滚的旧版本，请手动检查 $TARGET"
  fi
  echo "   请把上面的输出发给分享给你的人。"
  exit 1
fi

cat <<'EOF'

============================================================
 安装完成！
 接下来在手机上：
   1. 回浏览器「硬刷新」SillyTavern 页面（下拉刷新不够，
      用浏览器菜单里的刷新，或关掉标签页重开）
   2. 进 文生图设置 → Stable Diffusion
      应该能看到新的「本地生图 (LocalDream)」区块
   3. API 地址填 http://127.0.0.1:8081
      打开「启用本地生图」开关
      点「连接刷新数据」→ 应提示连接成功

 说明文档在 _本地生图补丁说明/ 文件夹里（就在扩展目录旁边）
============================================================
EOF
