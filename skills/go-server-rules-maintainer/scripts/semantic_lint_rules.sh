#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/go-server/common"
PROFILE_MONOLITH="$RULES_ROOT/go-server/profiles/monolith/project-structure.md"
PROFILE_MICRO="$RULES_ROOT/go-server/profiles/microservice/project-structure.md"

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
check_file="$COMMON_DIR/pr-review-checklist.md"

require_file "$api_file"
require_file "$cfg_file"
require_file "$comp_file"
require_file "$forbid_file"
require_file "$test_file"
require_file "$check_file"
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

# API 响应与状态码策略
check "$api_file" "统一包结构" "统一响应结构"
check "$api_file" "语义化 HTTP 状态码" "语义化状态码约束"
check "$api_file" '禁止对失败请求统一返回 `200`' "失败请求禁用统一 200"

# 配置策略
check "$cfg_file" "application.yml + application-<profile>.yml" "分层配置结构"
check "$cfg_file" "Profile 必须白名单校验" "profile 白名单校验"
check "$cfg_file" '数据库配置必须显式声明 `type`' "数据库类型字段约束"
check "$cfg_file" '`mysql` 或 `postgresql`' "数据库类型候选值"

# DI 与探针策略
check "$comp_file" "/healthz" "存活探针"
check "$comp_file" "/readyz" "就绪探针"
check "$comp_file" "初始化顺序" "组件初始化顺序"
check "$comp_file" "手动 DI" "DI 注入策略"

# 禁止项联动
check "$forbid_file" '禁止在 `init()` 中初始化' "禁止 init 建连"
check "$forbid_file" "禁止在 handler/service 内直接构造基础组件客户端" "禁止业务层直接构造基础组件"
check "$forbid_file" '禁止对失败请求统一返回 `200`' "禁止统一 200 错误返回"

# 质量门禁联动
check "$test_file" '所有 `P0` 必须通过' "P0 门禁"
check "$test_file" "健康探针与就绪探针" "探针测试要求"

# PR 清单联动
check "$check_file" '`P0` 为阻塞项' "P0 定义"
check "$check_file" "[P0]" "P0 勾选项"
check "$check_file" "Conditional Approve" "条件通过结论"

# Profile 关键章节
check "$PROFILE_MONOLITH" "中间件组织规则" "单体中间件组织规则"
check "$PROFILE_MONOLITH" "数据模型组织规则" "单体数据模型规则"
check "$PROFILE_MONOLITH" "组件初始化规则" "单体组件初始化规则"
check "$PROFILE_MICRO" "中间件组织规则" "微服务中间件组织规则"
check "$PROFILE_MICRO" "数据模型组织规则" "微服务数据模型规则"
check "$PROFILE_MICRO" "组件初始化规则" "微服务组件初始化规则"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: go-server 语义约束校验通过"
echo "检查项数: ${checks}"
