#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COLLAB_FILE="$RULES_ROOT/frontend-backend-collaboration.md"
FRONT_INDEX="$RULES_ROOT/frontend/index.md"
FRONT_COMPAT="$RULES_ROOT/frontend.md"
GO_INDEX="$RULES_ROOT/go-server/index.md"
GO_COMPAT="$RULES_ROOT/go-server.md"
DOTNET_INDEX="$RULES_ROOT/dotnet-server/index.md"
DOTNET_COMPAT="$RULES_ROOT/dotnet-server.md"
API_TMPL="$RULES_ROOT/templates/frontend-backend/api-contract-template.md"
INT_TMPL="$RULES_ROOT/templates/frontend-backend/integration-checklist-template.md"
REL_TMPL="$RULES_ROOT/templates/frontend-backend/release-rollback-record-template.md"

fail() {
  echo "错误: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "缺少文件: $path"
}

require_file "$COLLAB_FILE"
require_file "$FRONT_INDEX"
require_file "$FRONT_COMPAT"
require_file "$GO_INDEX"
require_file "$GO_COMPAT"
require_file "$DOTNET_INDEX"
require_file "$DOTNET_COMPAT"
require_file "$API_TMPL"
require_file "$INT_TMPL"
require_file "$REL_TMPL"

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$FRONT_INDEX"; then
  fail "frontend/index.md 未索引协作规则"
fi

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$FRONT_COMPAT"; then
  fail "frontend.md 未索引协作规则"
fi

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$GO_INDEX"; then
  fail "go-server/index.md 未索引协作规则"
fi

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$GO_COMPAT"; then
  fail "go-server.md 未索引协作规则"
fi

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$DOTNET_INDEX"; then
  fail "dotnet-server/index.md 未索引协作规则"
fi

if ! rg -q 'rules/frontend-backend-collaboration\.md' "$DOTNET_COMPAT"; then
  fail "dotnet-server.md 未索引协作规则"
fi

echo "通过: 前后端协作规则结构与索引校验通过"
