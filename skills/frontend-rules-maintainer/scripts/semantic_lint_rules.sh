#!/usr/bin/env bash
set -euo pipefail

RULES_ROOT="${1:-rules}"
RULES_ROOT="${RULES_ROOT%/}"

FRONT_DIR="$RULES_ROOT/frontend"

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

gov_file="$FRONT_DIR/common/governance.md"
index_file="$FRONT_DIR/index.md"
stack_file="$FRONT_DIR/common/stack-baseline.md"
tool_file="$FRONT_DIR/common/tooling.md"
workflow_file="$FRONT_DIR/common/workflow.md"
naming_file="$FRONT_DIR/common/naming.md"
norm_file="$FRONT_DIR/common/normalization.md"
mini_file="$FRONT_DIR/applications/miniprogram.md"
h5_file="$FRONT_DIR/applications/wechat-h5.md"

require_file "$gov_file"
require_file "$index_file"
require_file "$stack_file"
require_file "$tool_file"
require_file "$workflow_file"
require_file "$naming_file"
require_file "$norm_file"
require_file "$mini_file"
require_file "$h5_file"

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

# 治理约束
check "$gov_file" '每条 `MUST` 规则必须显式标注检查方式' "MUST 检查方式约束"
check "$gov_file" '每条 `MUST` 规则必须声明是否阻断合并' "MUST 阻断级别约束"

# 结构拆分索引
check "$index_file" "project-structure/admin-console.md" "后台结构独立索引"
check "$index_file" "project-structure/wechat-h5.md" "H5 结构独立索引"
check "$index_file" "project-structure/miniprogram.md" "小程序结构独立索引"

# 按需加载与交付
check "$workflow_file" "规则按需加载策略（MUST）" "按需加载章节"
check "$workflow_file" '不得一次性通读 `rules/frontend` 全部文件' "禁止全量通读"
check "$workflow_file" "lint + typecheck + test" "交付最小校验"
check "$workflow_file" '超过 `300` 行必须拆分后再合并' "300 行硬上限"

# 工具链与 CI 门禁
check "$tool_file" '脚本：`lint`、`typecheck`、`test`、`build`' "脚本契约"
check "$tool_file" '`lint` 失败：阻断合并' "lint 阻断"
check "$tool_file" '`typecheck` 失败：阻断合并' "typecheck 阻断"
check "$tool_file" '`test` 失败：阻断合并' "test 阻断"

# 关键技术路线
check "$stack_file" '当前基线不引入 `Taro` 生态依赖' "禁用 Taro"
check "$stack_file" '同一应用如需 H5 与小程序，使用一个 `uni-app` 项目多端编译' "uni-app 多端编译"
check "$stack_file" '通过 `lint + typecheck + test`' "基线质量门禁"

# 命名与规范化
check "$naming_file" "Token 命名规则（MUST）" "Token 命名"
check "$naming_file" "tab-host 命名约束（适用时 MUST）" "tab-host 命名"
check "$norm_file" "Token 优先规则（MUST）" "Token 优先"
check "$norm_file" "tab-host 规范化规则（适用时 MUST）" "tab-host 规范化"

# 小程序硬约束
check "$mini_file" '图标资源禁止使用 `SVG`' "禁 SVG"
check "$mini_file" '主包体积不得大于 `2MB`' "2MB 主包限制"
check "$mini_file" '禁止引入 `Taro` 相关依赖' "小程序禁 Taro"
check "$h5_file" '禁止引入 `Taro` 相关依赖' "H5 禁 Taro"

if (( errors > 0 )); then
  echo "失败: frontend 语义校验未通过 (failed ${errors}/${checks})" >&2
  exit 1
fi

echo "通过: frontend 语义约束校验通过"
echo "检查项数: ${checks}"
