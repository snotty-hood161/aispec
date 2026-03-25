#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/ios/common"

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
check "$arch_file" "ObservableObject" "状态管理协议"
check "$arch_file" "Repository" "Repository 模式"
check "$arch_file" "@MainActor" "主线程标注"

# 安全
check "$sec_file" "Keychain" "安全存储"
check "$sec_file" "ATS" "App Transport Security"
check "$sec_file" "HTTPS" "网络安全"
check "$sec_file" "SSL Pinning" "证书固定"

# 错误处理
check "$err_file" "Error" "Error 协议"
check "$err_file" "LocalizedError" "本地化错误"
check "$err_file" "async throws" "异步异常处理"

# 基线
check "$baseline_file" "SwiftLint" "代码规范检查"
check "$baseline_file" "Swift Package Manager" "依赖管理"

# 代码风格
check "$code_file" "Swift API Design Guidelines" "API 设计指南"
check "$code_file" "force_unwrapping" "强制解包规则"

# 数据访问
check "$data_file" "URLSession" "网络请求"
check "$data_file" "Repository" "数据访问层"

# 可观测性
check "$obs_file" "os.Logger" "日志框架"
check "$obs_file" "Crashlytics" "崩溃报告"

# 禁止项
check "$forbid_file" "禁止" "禁止项存在"
check "$forbid_file" "force unwrap" "强制解包禁止"
check "$forbid_file" "try!" "强制 try 禁止"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: ios 语义约束校验通过"
echo "检查项数: ${checks}"
