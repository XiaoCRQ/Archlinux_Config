#!/bin/bash

# 检查是否启用时间戳
USE_TIMESTAMP=false
BACKUP_DIR_SUFFIX=""

while getopts "t" opt; do
  case $opt in
  t)
    USE_TIMESTAMP=true
    # 只获取一次时间戳（精确到分钟）
    BACKUP_DIR_SUFFIX="_$(date +"%Y%m%d_%H%M")"
    ;;
  *)
    echo "用法: $0 [-t]"
    exit 1
    ;;
  esac
done

declare -A COPY_MAP_SOURCES

# 添加源路径
add_source() {
  local target="$1"
  local src="$2"
  if [[ -z "${COPY_MAP_SOURCES[$target]}" ]]; then
    COPY_MAP_SOURCES[$target]="$src"
  else
    COPY_MAP_SOURCES[$target]+=$'\n'"$src"
  fi
}

# 添加备份条目
add_source "./.config" "$HOME/.config/hypr"
add_source "./.config" "$HOME/.config/kitty"
add_source "./.config" "$HOME/.config/fcitx"
add_source "./.config" "$HOME/.config/fcitx5"
add_source "./.config" "$HOME/.config/fish"
add_source "./.config/hyde" "$HOME/.config/hyde/config.toml"
# add_source "./Pictures" "$HOME/Pictures/Wallpapers"
add_source "./applications" "/usr/share/applications/wechat.desktop"
add_source "./applications" "/usr/share/applications/qq.desktop"
add_source "./applications" "/usr/share/applications/obsidian.desktop"
add_source "./applications" "/usr/share/applications/spotify.desktop"
add_source "./applications" "/usr/share/applications/wps-office-et.desktop"
add_source "./applications" "/usr/share/applications/wps-office-pdf.desktop"
add_source "./applications" "/usr/share/applications/wps-office-prometheus.desktop"
add_source "./applications" "/usr/share/applications/wps-office-wpp.desktop"
add_source "./applications" "/usr/share/applications/wps-office-wps.desktop"
add_source "./applications" "/usr/share/applications/steam.desktop"
add_source "./applications" "/usr/share/applications/eusoft-eudic.desktop"
add_source "./applications" "/usr/share/applications/eusoft-ting-en.desktop"

# 获取一次当前时间戳用于所有备份目录
TIMESTAMP=""
if $USE_TIMESTAMP; then
  TIMESTAMP="_$(date +"%Y%m%d_%H%M")"
fi

# 处理备份
for TARGET_BASE in "${!COPY_MAP_SOURCES[@]}"; do
  # 构造目标路径
  if $USE_TIMESTAMP; then
    TARGET="${TARGET_BASE}${TIMESTAMP}"
  else
    TARGET="$TARGET_BASE"
  fi

  mkdir -p "$TARGET"

  IFS=$'\n' read -rd '' -a SRCS <<<"${COPY_MAP_SOURCES[$TARGET_BASE]}"

  for SRC_PATTERN in "${SRCS[@]}"; do
    # 展开 ~
    SRC_PATTERN="${SRC_PATTERN/#\~/$HOME}"

    # 展开通配符
    matches=()
    while IFS= read -r -d '' match; do
      matches+=("$match")
    done < <(eval "printf '%s\0' $SRC_PATTERN")

    if [ ${#matches[@]} -eq 0 ]; then
      echo "⚠ 未找到匹配路径: $SRC_PATTERN"
      continue
    fi

    for SRC in "${matches[@]}"; do
      if [ -d "$SRC" ] || [ -f "$SRC" ]; then
        # 如果源路径是系统目录，则使用 sudo 读取
        if [[ "$SRC" == /usr/* || "$SRC" == /etc/* ]]; then
          sudo rsync -a --info=progress2 "$SRC" "$TARGET/"
        else
          rsync -a --info=progress2 "$SRC" "$TARGET/"
        fi
        echo "✔ 已备份: $SRC -> $TARGET/"
      else
        echo "⚠ 无效路径: $SRC"
      fi
    done
  done
done
