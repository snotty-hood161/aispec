#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/dotnet-desktop/common"

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
thread_file="$COMMON_DIR/threading-and-ui.md"
err_file="$COMMON_DIR/error-handling.md"
update_file="$COMMON_DIR/auto-update.md"
forbid_file="$COMMON_DIR/forbidden.md"
perf_file="$COMMON_DIR/performance.md"
sec_file="$COMMON_DIR/security.md"

# 架构
check "$arch_file" "MVVM" "MVVM 架构模式"
check "$arch_file" "IDialogService" "对话框抽象接口"
check "$arch_file" "依赖注入" "DI 容器"

# 线程模型
check "$thread_file" "Dispatcher" "UI 线程调度"
check "$thread_file" "async/await" "异步编程"
check "$thread_file" "CancellationToken" "取消令牌"

# 错误处理
check "$err_file" "全局异常" "全局异常处理"
check "$err_file" "ViewModel" "ViewModel 错误状态"

# 自动更新
check "$update_file" "Velopack" "更新框架"
check "$update_file" "禁止要求用户手动" "禁止手动下载"
check "$update_file" "进度" "下载进度展示"

# 禁止项
check "$forbid_file" "禁止" "禁止项存在"

# 性能
check "$perf_file" "虚拟化" "列表虚拟化"
check "$perf_file" "启动" "启动性能"

# 安全
check "$sec_file" "DPAPI" "凭据安全存储"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: dotnet-desktop 语义约束校验通过"
echo "检查项数: ${checks}"
