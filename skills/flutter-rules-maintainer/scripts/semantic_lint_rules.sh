#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

COMMON_DIR="$RULES_ROOT/flutter/common"
PROFILE_MOBILE="$RULES_ROOT/flutter/profiles/mobile/project-structure.md"

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

baseline_file="$COMMON_DIR/baseline.md"
style_file="$COMMON_DIR/code-style.md"
arch_file="$COMMON_DIR/architecture.md"
err_file="$COMMON_DIR/error-handling.md"
sec_file="$COMMON_DIR/security.md"
data_file="$COMMON_DIR/data-access.md"
cfg_file="$COMMON_DIR/configuration.md"
obs_file="$COMMON_DIR/observability.md"
perf_file="$COMMON_DIR/performance.md"
test_file="$COMMON_DIR/testing-and-release.md"
ui_file="$COMMON_DIR/ui-framework.md"
device_file="$COMMON_DIR/device-adaptation.md"
forbid_file="$COMMON_DIR/forbidden.md"

require_file "$baseline_file"
require_file "$style_file"
require_file "$arch_file"
require_file "$err_file"
require_file "$sec_file"
require_file "$data_file"
require_file "$cfg_file"
require_file "$obs_file"
require_file "$perf_file"
require_file "$test_file"
require_file "$ui_file"
require_file "$device_file"
require_file "$forbid_file"
require_file "$PROFILE_MOBILE"

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

# 技术基线
check "$baseline_file" "Flutter SDK" "Flutter SDK 版本要求"
check "$baseline_file" "Dart" "Dart 版本要求"
check "$baseline_file" "pubspec.yaml" "依赖管理文件"

# 编码风格
check "$style_file" "dart format" "代码格式化工具"
check "$style_file" "dart analyze" "静态分析工具"
check "$style_file" "命名" "命名规范"

# 架构与状态管理
check "$arch_file" "状态管理" "状态管理方案"
check "$arch_file" "依赖注入" "依赖注入策略"
check "$arch_file" "分层" "分层架构"

# 错误处理
check "$err_file" "异常" "异常处理策略"
check "$err_file" "try" "异常捕获规范"

# 安全
check "$sec_file" "存储" "安全存储要求"
check "$sec_file" "禁止" "安全禁止项"

# 数据访问
check "$data_file" "网络请求" "网络请求规范"

# 配置
check "$cfg_file" "环境" "多环境配置"
check "$cfg_file" "签名" "应用签名管理"

# 可观测性
check "$obs_file" "日志" "日志规范"
check "$obs_file" "崩溃" "崩溃报告"

# 性能
check "$perf_file" "Widget" "Widget 优化"
check "$perf_file" "内存" "内存管理"

# 测试与发布
check "$test_file" "单元测试" "单元测试要求"
check "$test_file" "CI" "CI/CD 流程"

# UI 框架
check "$ui_file" "主题" "主题管理"
check "$ui_file" "导航" "导航管理"

# 设备适配
check "$device_file" "适配" "设备适配策略"

# 禁止项
check "$forbid_file" "禁止" "禁止事项"

# Profile 关键章节
check "$PROFILE_MOBILE" "目录结构" "移动端目录结构"
check "$PROFILE_MOBILE" "lib/" "lib 目录组织"

if (( errors > 0 )); then
  echo "失败: 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: flutter 语义约束校验通过"
echo "检查项数: ${checks}"
