#!/bin/bash

# 在还原前执行备份
echo "🔄 正在执行备份 ./backup.sh -t..."
if ./backup.sh -t; then
  echo "✅ 备份完成，开始导入..."
else
  echo "❌ 备份失败，中止导入。"
  exit 1
fi

declare -A RESTORE_MAP_SOURCES

# 添加还原路径（本地备份路径 -> 还原目标路径）
add_restore() {
  local local_dir="$1"
  local restore_to="$2"
  if [[ -z "${RESTORE_MAP_SOURCES[$local_dir]}" ]]; then
    RESTORE_MAP_SOURCES[$local_dir]="$restore_to"
  else
    RESTORE_MAP_SOURCES[$local_dir]+=$'\n'"$restore_to"
  fi
}

# 添加还原条目（与备份脚本匹配）
add_restore "./.config" "$HOME/.config"
# add_restore "./Pictures" "$HOME/Pictures"
add_restore "./applications" "/usr/share/applications"

# 还原处理
for LOCAL in "${!RESTORE_MAP_SOURCES[@]}"; do
  IFS=$'\n' read -rd '' -a TARGETS <<<"${RESTORE_MAP_SOURCES[$LOCAL]}"

  for DEST in "${TARGETS[@]}"; do
    # 展开 ~
    DEST="${DEST/#\~/$HOME}"

    if [ ! -d "$LOCAL" ]; then
      echo "⚠ 本地目录不存在: $LOCAL"
      continue
    fi

    mkdir -p "$DEST"

    # 判断是否需要 sudo（非用户目录）
    if [[ "$DEST" == /usr/* || "$DEST" == /etc/* ]]; then
      sudo rsync -a "$LOCAL/" "$DEST/"
    else
      rsync -a "$LOCAL/" "$DEST/"
    fi

    echo "✔ 已导入: $LOCAL -> $DEST/"
  done
done
