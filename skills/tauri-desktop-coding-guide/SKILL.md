---
name: tauri-desktop-coding-guide
description: Tauri 桌面应用编码规范引导。当 AI 编写 Rust + Tauri 桌面应用代码时触发，自动按编码场景加载对应的规则文件子集来约束代码输出。Tauri 前端部分遵循 `rules/frontend` 规范，本 skill 仅约束 Tauri 特有部分。
workflow: _templates/coding-guide-workflow.md
---

# Tauri 桌面编码引导

在编写 Rust + Tauri 桌面应用代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: tauri-desktop
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/tauri-desktop/index.md`
- **max_load**: 6

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| Tauri 前端代码 | `$frontend-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/tauri-desktop/index.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
