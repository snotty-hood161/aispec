#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COLLAB_FILE="$RULES_ROOT/frontend-backend-collaboration.md"
FRONT_INDEX="$RULES_ROOT/frontend/index.md"
GO_INDEX="$RULES_ROOT/go-server/index.md"

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
  if ! rg -q -F "$pattern" "$file"; then
    echo "错误: $file 缺少语义约束: $desc" >&2
    return 1
  fi
  return 0
}

require_file "$COLLAB_FILE"
require_file "$FRONT_INDEX"
require_file "$GO_INDEX"

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

check "$COLLAB_FILE" "先契约后开发" "契约优先"
check "$COLLAB_FILE" "先兼容后替换" "兼容优先"
check "$COLLAB_FILE" "先服务端兼容发布，再前端发布切换" "发布顺序"
check "$COLLAB_FILE" "lint + typecheck + test" "前端质量门禁"
check "$COLLAB_FILE" "rules/database/database.md" "数据库优先冲突规则"
check "$COLLAB_FILE" "检查方式：" "检查方式字段"
check "$COLLAB_FILE" "阻断级别：" "阻断级别字段"
check "$COLLAB_FILE" "rules/templates/frontend-backend/api-contract-template.md" "契约模板引用"
check "$COLLAB_FILE" "rules/templates/frontend-backend/integration-checklist-template.md" "联调模板引用"
check "$COLLAB_FILE" "rules/templates/frontend-backend/release-rollback-record-template.md" "发布回滚模板引用"

check "$FRONT_INDEX" '前后端协作相关条款以 `rules/frontend-backend-collaboration.md` 为准' "前端冲突优先级挂载"
check "$GO_INDEX" '前后端协作相关条款以 `rules/frontend-backend-collaboration.md` 为准' "服务端冲突优先级挂载"

if (( errors > 0 )); then
  echo "失败: 前后端协作语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: 前后端协作语义约束校验通过"
echo "检查项数: ${checks}"
