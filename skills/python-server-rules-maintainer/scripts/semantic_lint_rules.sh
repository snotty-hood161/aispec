#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/python-server/common"
PROFILE_MONOLITH="$RULES_ROOT/python-server/profiles/monolith/project-structure.md"
PROFILE_MICRO="$RULES_ROOT/python-server/profiles/microservice/project-structure.md"

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

api_file="$COMMON_DIR/api-design.md"
cfg_file="$COMMON_DIR/configuration.md"
comp_file="$COMMON_DIR/component-initialization.md"
forbid_file="$COMMON_DIR/forbidden.md"
test_file="$COMMON_DIR/testing-and-release.md"

require_file "$api_file"
require_file "$cfg_file"
require_file "$comp_file"
require_file "$forbid_file"
require_file "$test_file"
require_file "$PROFILE_MONOLITH"
require_file "$PROFILE_MICRO"

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

check "$api_file" "统一响应结构" "统一响应结构"
check "$api_file" "语义化 HTTP 状态码" "语义化状态码约束"
check "$api_file" '禁止对失败请求统一返回 `200`' "失败请求禁用统一 200"

check "$cfg_file" "环境变量" "环境变量配置"
check "$cfg_file" "多环境" "多环境支持"

check "$comp_file" "/healthz" "存活探针"
check "$comp_file" "/readyz" "就绪探针"
check "$comp_file" "初始化顺序" "组件初始化顺序"
check "$comp_file" "依赖注入" "DI 注入策略"

check "$forbid_file" "禁止在 controller" "禁止 controller 直接访问数据库"
check "$forbid_file" '禁止对失败请求统一返回 `200`' "禁止统一 200 错误返回"

check "$test_file" '所有 `P0` 必须通过' "P0 门禁"
check "$test_file" "健康探针与就绪探针" "探针测试要求"

check "$PROFILE_MONOLITH" "目录结构" "单体目录结构规则"
check "$PROFILE_MICRO" "目录结构" "微服务目录结构规则"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: python-server 语义约束校验通过"
echo "检查项数: ${checks}"
