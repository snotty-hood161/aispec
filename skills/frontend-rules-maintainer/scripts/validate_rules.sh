#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

FRONT_DIR="$RULES_ROOT/frontend"
INDEX_FILE="$FRONT_DIR/index.md"
COMPAT_FILE="$RULES_ROOT/frontend.md"

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

require_file "$INDEX_FILE"
require_file "$COMPAT_FILE"
require_dir "$FRONT_DIR/common"
require_dir "$FRONT_DIR/project-structure"
require_dir "$FRONT_DIR/applications"
require_dir "$FRONT_DIR/frameworks"

if ! rg -q 'rules/frontend/index\.md|frontend/index\.md' "$COMPAT_FILE"; then
  fail "兼容入口文件未引用 frontend/index.md"
fi

required_rule_files=(
  "common/governance.md"
  "common/project-structure.md"
  "project-structure/admin-console.md"
  "project-structure/wechat-h5.md"
  "project-structure/miniprogram.md"
  "common/stack-baseline.md"
  "common/baseline.md"
  "common/naming.md"
  "common/tooling.md"
  "common/workflow.md"
  "common/normalization.md"
  "common/componentization-and-adaptation.md"
  "applications/admin-console.md"
  "applications/wechat-h5.md"
  "applications/miniprogram.md"
  "frameworks/vue3-typescript.md"
  "frameworks/react-typescript.md"
)

for rel in "${required_rule_files[@]}"; do
  require_file "$FRONT_DIR/$rel"
done

index_entries_raw=()
while IFS= read -r line; do
  index_entries_raw+=("$line")
done < <(
  rg -o '`[^`]+`' "$INDEX_FILE" \
    | tr -d '`' \
    | grep -E '^(common|project-structure|applications|frameworks|matrix)/.+\.md$' \
    | grep -v '\*' || true
)

(( ${#index_entries_raw[@]} > 0 )) || fail "index 中未找到规则文件条目"

index_entries=()
while IFS= read -r line; do
  [[ -n "$line" ]] && index_entries+=("$line")
done < <(printf '%s\n' "${index_entries_raw[@]}" | sort -u)

missing_target=0
for rel_path in "${index_entries[@]}"; do
  full_path="$FRONT_DIR/$rel_path"
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
  find "$FRONT_DIR/common" "$FRONT_DIR/project-structure" "$FRONT_DIR/applications" "$FRONT_DIR/frameworks" -type f -name '*.md' 2>/dev/null \
    | sed "s#^$FRONT_DIR/##" \
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

missing_required=0
for rel in "${required_rule_files[@]}"; do
  if ! printf '%s\n' "${index_entries[@]}" | grep -Fxq "$rel"; then
    echo "错误: 索引缺少必需规则文件: $rel" >&2
    missing_required=1
  fi
done
(( missing_required == 0 )) || exit 1

echo "通过: frontend 结构与索引校验通过"
echo "规则文件数: ${#actual_rule_files[@]}"
echo "索引条目数: ${#index_entries[@]}"
