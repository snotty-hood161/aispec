#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/dotnet-server/common"
PROFILE_MONOLITH="$RULES_ROOT/dotnet-server/profiles/monolith/project-structure.md"
PROFILE_MICRO="$RULES_ROOT/dotnet-server/profiles/microservice/project-structure.md"

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

api_file="$COMMON_DIR/api-design.md"
cfg_file="$COMMON_DIR/configuration.md"
comp_file="$COMMON_DIR/component-initialization.md"
forbid_file="$COMMON_DIR/forbidden.md"
test_file="$COMMON_DIR/testing-and-release.md"
err_file="$COMMON_DIR/error-handling.md"
sec_file="$COMMON_DIR/security.md"
db_file="$COMMON_DIR/database-access.md"

for f in "$api_file" "$cfg_file" "$comp_file" "$forbid_file" "$test_file" "$err_file" "$sec_file" "$db_file"; do
  require_file "$f"
done

# API 响应与版本策略
check "$api_file" "ApiResponse" "统一响应结构"
check "$api_file" "FluentValidation" "参数校验框架"

# 配置策略
check "$cfg_file" "Options Pattern" "Options Pattern 配置"
check "$cfg_file" "appsettings" "分层配置结构"

# DI 与健康检查
check "$comp_file" "AddHealthChecks" "健康检查注册"
check "$comp_file" "ValidateOnBuild" "DI 启动校验"

# 错误处理
check "$err_file" "IExceptionHandler" "全局异常处理"
check "$err_file" "BusinessException" "业务异常基类"

# 安全
check "$sec_file" "JWT" "JWT 认证"
check "$sec_file" "Rate Limiting" "限流策略"

# 数据库
check "$db_file" "EF Core" "ORM 框架"
check "$db_file" "AsNoTracking" "只读查询优化"

# 禁止项联动
check "$forbid_file" "禁止" "禁止项存在"

# 测试门禁
check "$test_file" "xUnit" "测试框架"
check "$test_file" "WebApplicationFactory" "集成测试工厂"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: dotnet-server 语义约束校验通过"
echo "检查项数: ${checks}"
