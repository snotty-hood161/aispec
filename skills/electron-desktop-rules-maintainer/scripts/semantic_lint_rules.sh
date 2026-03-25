#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/electron-desktop/common"
PROFILE_V30="$RULES_ROOT/electron-desktop/profiles/electron-v30/project-structure.md"

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

arch_file="$COMMON_DIR/architecture.md"
security_file="$COMMON_DIR/security.md"
ipc_file="$COMMON_DIR/ipc-communication.md"
forbid_file="$COMMON_DIR/forbidden.md"
test_file="$COMMON_DIR/testing-and-release.md"

require_file "$arch_file"
require_file "$security_file"
require_file "$ipc_file"
require_file "$forbid_file"
require_file "$test_file"
require_file "$PROFILE_V30"

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

check "$security_file" "contextIsolation" "contextIsolation 安全约束"
check "$security_file" "nodeIntegration" "nodeIntegration 安全约束"
check "$security_file" "sandbox" "沙箱安全约束"

check "$ipc_file" "ipcMain" "主进程 IPC 通信"
check "$ipc_file" "ipcRenderer" "渲染进程 IPC 通信"

check "$arch_file" "主进程" "主进程分层"
check "$arch_file" "渲染进程" "渲染进程分层"

check "$forbid_file" "禁止" "禁止项存在"

check "$test_file" '所有 `P0` 必须通过' "P0 门禁"

check "$PROFILE_V30" "目录结构" "Electron v30 项目结构"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: electron-desktop 语义约束校验通过"
echo "检查项数: ${checks}"
