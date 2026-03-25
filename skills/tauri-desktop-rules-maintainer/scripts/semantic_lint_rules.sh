#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/tauri-desktop/common"

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
update_file="$COMMON_DIR/auto-update.md"
forbid_file="$COMMON_DIR/forbidden.md"
baseline_file="$COMMON_DIR/baseline.md"
code_file="$COMMON_DIR/code-style.md"

# 架构
check "$arch_file" "Tauri Command" "IPC Command 定义"
check "$arch_file" "invoke" "前端 IPC 调用"
check "$arch_file" "tauri::State" "状态管理"

# 安全
check "$sec_file" "CSP" "内容安全策略"
check "$sec_file" "Capability" "权限声明"
check "$sec_file" "unsafe-eval" "禁止 unsafe-eval"

# 错误处理
check "$err_file" "thiserror" "Rust 错误类型"
check "$err_file" "AppError" "统一错误枚举"

# 自动更新
check "$update_file" "tauri-plugin-updater" "更新插件"
check "$update_file" "Ed25519" "签名验证"
check "$update_file" "禁止要求用户手动" "禁止手动下载"
check "$update_file" "downloadAndInstall" "下载安装 API"

# 基线
check "$baseline_file" "cargo clippy" "Clippy lint"
check "$baseline_file" "cargo audit" "依赖漏洞检测"

# 代码风格
check "$code_file" "rustfmt" "Rust 格式化"
check "$code_file" "unwrap()" "禁止 unwrap"

# 禁止项
check "$forbid_file" "禁止" "禁止项存在"
check "$forbid_file" "dangerousRemoteDomainIpcAccess" "禁止远程 IPC"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: tauri-desktop 语义约束校验通过"
echo "检查项数: ${checks}"
