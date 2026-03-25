#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

DB_RULE_FILE="$RULES_ROOT/database/database.md"
INDEX_FILE="$RULES_ROOT/index.md"

fail() {
  echo "错误: $*" >&2
  exit 1
}

[[ -d "$RULES_ROOT/database" ]] || fail "缺少目录: database/"
[[ -f "$DB_RULE_FILE" ]] || fail "缺少文件: database/database.md"
[[ -f "$INDEX_FILE" ]] || fail "缺少文件: index.md"

if ! grep -qF 'database/database.md' "$INDEX_FILE"; then
  fail "index.md 未引用 database/database.md"
fi

actual_files=()
while IFS= read -r line; do
  actual_files+=("$line")
done < <(
  find "$RULES_ROOT/database" -type f -name '*.md' 2>/dev/null | sort
)

(( ${#actual_files[@]} > 0 )) || fail "database 目录中无 .md 文件"

echo "通过: database 结构与索引校验通过"
echo "规则文件数: ${#actual_files[@]}"
