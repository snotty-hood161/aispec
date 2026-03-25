#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/android/common"

fail() {
  echo "错误: $*" >&2
  exit 1
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

arch_file="$COMMON_DIR/architecture.md"
sec_file="$COMMON_DIR/security.md"
err_file="$COMMON_DIR/error-handling.md"
baseline_file="$COMMON_DIR/baseline.md"
code_file="$COMMON_DIR/code-style.md"
data_file="$COMMON_DIR/data-access.md"
forbid_file="$COMMON_DIR/forbidden.md"
obs_file="$COMMON_DIR/observability.md"

# 架构
check "$arch_file" "ViewModel" "ViewModel 分层"
check "$arch_file" "Hilt" "依赖注入"
check "$arch_file" "Repository" "Repository 模式"
check "$arch_file" "StateFlow" "状态管理"

# 安全
check "$sec_file" "R8" "代码混淆"
check "$sec_file" "EncryptedSharedPreferences" "安全存储"
check "$sec_file" "HTTPS" "网络安全"
check "$sec_file" "Certificate" "证书固定"

# 错误处理
check "$err_file" "sealed" "密封类错误建模"
check "$err_file" "Result" "Result 类型"
check "$err_file" "Coroutine" "协程异常处理"

# 基线
check "$baseline_file" "ktlint" "代码格式化"
check "$baseline_file" "detekt" "静态分析"
check "$baseline_file" "Version Catalog" "依赖管理"

# 代码风格
check "$code_file" "PascalCase" "Composable 命名"
check "$code_file" "KDoc" "文档注释"

# 数据访问
check "$data_file" "Room" "本地数据库"
check "$data_file" "Retrofit" "网络请求"
check "$data_file" "DataStore" "配置存储"

# 可观测性
check "$obs_file" "Timber" "日志框架"
check "$obs_file" "Crashlytics" "崩溃报告"

# 禁止项
check "$forbid_file" "禁止" "禁止项存在"
check "$forbid_file" "!!" "非空断言禁止"
check "$forbid_file" "GlobalScope" "全局协程禁止"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: android 语义约束校验通过"
echo "检查项数: ${checks}"
