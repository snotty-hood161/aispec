#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

INDEX_FILE="$RULES_ROOT/dotnet-server/index.md"
COMPAT_FILE="$RULES_ROOT/dotnet-server.md"
DOTNET_SERVER_DIR="$RULES_ROOT/dotnet-server"
DB_RULE_FILE="$RULES_ROOT/database/database.md"

fail() {
  echo "错误: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "缺少文件: $path"
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "缺少目录: $path"
}

[[ -f "$INDEX_FILE" ]] || fail "缺少索引文件: $INDEX_FILE"
[[ -f "$COMPAT_FILE" ]] || fail "缺少兼容入口文件: $COMPAT_FILE"
[[ -f "$DB_RULE_FILE" ]] || fail "缺少数据库总规则文件: $DB_RULE_FILE"
require_dir "$DOTNET_SERVER_DIR/common"
require_dir "$DOTNET_SERVER_DIR/profiles"
require_dir "$DOTNET_SERVER_DIR/profiles/monolith"
require_dir "$DOTNET_SERVER_DIR/profiles/microservice"

if ! grep -qF 'dotnet-server/index.md' "$COMPAT_FILE"; then
  fail "兼容入口文件未引用 dotnet-server/index.md"
fi

required_rule_files=(
  "common/baseline.md"
  "common/code-style.md"
  "common/component-initialization.md"
  "common/api-design.md"
  "common/error-handling.md"
  "common/observability.md"
  "common/configuration.md"
  "common/concurrency-and-resource.md"
  "common/database-access.md"
  "common/security.md"
  "common/testing-and-release.md"
  "common/performance.md"
  "common/caching.md"
  "common/file-storage.md"
  "common/scheduled-tasks.md"
  "common/forbidden.md"
  "profiles/monolith/project-structure.md"
  "profiles/microservice/project-structure.md"
)

for rel in "${required_rule_files[@]}"; do
  require_file "$DOTNET_SERVER_DIR/$rel"
done

index_entries=()
while IFS= read -r line; do
  index_entries+=("$line")
done < <(
  grep -oE '`[^`]+`' "$INDEX_FILE" \
    | tr -d '`' \
    | grep -E '^(common|profiles)/.+\.md$' || true
)

(( ${#index_entries[@]} > 0 )) || fail "index 中未找到规则文件条目"

duplicates="$(printf '%s\n' "${index_entries[@]}" | sort | uniq -d || true)"
if [[ -n "$duplicates" ]]; then
  echo "错误: 检测到重复索引条目:" >&2
  echo "$duplicates" >&2
  exit 1
fi

missing_target=0
for rel_path in "${index_entries[@]}"; do
  full_path="$DOTNET_SERVER_DIR/$rel_path"
  if [[ ! -f "$full_path" ]]; then
    echo "错误: index 指向不存在文件: $rel_path" >&2
    missing_target=1
  fi
done
(( missing_target == 0 )) || exit 1

actual_rule_files=()
while IFS= read -r line; do
  actual_rule_files+=("$line")
done < <(
  find "$DOTNET_SERVER_DIR/common" "$DOTNET_SERVER_DIR/profiles" -type f -name '*.md' 2>/dev/null \
    | sed "s#^$DOTNET_SERVER_DIR/##" \
    | sort
)

not_indexed=0
for file in "${actual_rule_files[@]}"; do
  if ! printf '%s\n' "${index_entries[@]}" | grep -Fxq "$file"; then
    echo "错误: 规则文件未被索引: $file" >&2
    not_indexed=1
  fi
done
(( not_indexed == 0 )) || exit 1

echo "通过: dotnet-server 结构与索引校验通过"
echo "规则文件数: ${#actual_rule_files[@]}"
echo "索引条目数: ${#index_entries[@]}"
