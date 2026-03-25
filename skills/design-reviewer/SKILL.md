---
name: design-reviewer
description: 设计走查工具。当需要审查已实现界面的设计还原度时触发。对比设计稿与实际实现，检查视觉一致性、交互完整性、无障碍合规性，输出设计走查报告和修复建议。
---

# 设计走查工具

对比设计稿与已实现界面，检查设计还原度，输出结构化的走查报告。

## 何时使用
1. 前端/客户端开发完成后，需要验证设计还原度。
2. 用户要求进行设计走查或视觉审查。
3. Design Agent 执行 Phase 4 设计验证时。
4. 由 Coordinator 调度 Design Agent 执行 review 类型任务时。

## 外部 MCP 依赖
- **Pencil MCP**（可选）：读取设计稿中的 Token 和布局信息。
- **Playwright MCP**（可选）：截取实际页面进行对比。
- 无 MCP 时退化为基于代码审查的设计走查。

## 执行原则
1. 以 `references/design-review-checklist.md` 为检查清单。
2. 以 `rules/design/` 下的规范文件为走查标准。
3. 每项检查标注：通过 / 不通过 / 不适用。
4. 不通过的项必须附具体位置和修复建议。

## 标准工作流（必须执行）

### 1. 收集设计基准
- 读取设计 Token 定义（CSS 变量或 .pen 文件中的变量）。
- 读取设计稿中的页面清单和组件清单。
- 确定走查范围（全页面 / 特定页面 / PR 变更涉及的页面）。

### 2. 执行走查检查
- 按 `references/design-review-checklist.md` 逐项检查。
- 检查维度：视觉一致性、交互完整性、响应式适配、无障碍合规。
- 每个检查项标注结果和严重度。

### 3. 截图对比（可选）
- 使用 Playwright MCP 截取实际页面。
- 使用 Pencil MCP 截取设计稿对应页面。
- 标注差异区域。

### 4. 输出走查报告
- 走查概览（检查项数量、通过率）。
- 不通过项详情（位置、期望值、实际值、修复建议）。
- 设计还原度评分（A/B/C/D）。
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯（skill 名称、任务类型、加载规则清单、跨域联动）。

## 资源
1. 检查清单：`references/design-review-checklist.md`
2. 设计规范：`rules/design/` 下所有文件
3. Design Agent 定义：`agents/design/agent.md`
