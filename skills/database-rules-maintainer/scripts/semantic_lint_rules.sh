#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

DB_RULE_FILE="$RULES_ROOT/database/database.md"

fail() {
  echo "错误: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "缺少文件: $path"
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local desc="$3"
  if ! grep -qF "$pattern" "$file"; then
    echo "错误: $file 缺少语义约束: $desc" >&2
    return 1
  fi
  return 0
}

errors=0
checks=0

check() {
  local file="$1"
  local pattern="$2"
  local desc="$3"
  checks=$((checks + 1))
  if ! require_pattern "$file" "$pattern" "$desc"; then
    errors=$((errors + 1))
  fi
}

require_file "$DB_RULE_FILE"

check "$DB_RULE_FILE" "schema.sql" "全量初始化脚本定义"
check "$DB_RULE_FILE" "docs/migrations" "迁移脚本目录定义"
check "$DB_RULE_FILE" "yyyyMMdd" "迁移脚本命名格式"
check "$DB_RULE_FILE" "严禁修改" "历史脚本保护条款"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: database 语义约束校验通过"
echo "检查项数: ${checks}"
