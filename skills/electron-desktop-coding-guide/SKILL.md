---
name: electron-desktop-coding-guide
description: Electron 桌面应用编码规范引导。当 AI 编写 Electron 主进程/preload 代码时触发，自动按编码场景加载对应的规则文件子集来约束代码输出。渲染进程前端部分遵循 `rules/frontend` 规范，本 skill 仅约束 Electron 主进程与 preload 特有部分。
workflow: _templates/coding-guide-workflow.md
---

# Electron 桌面编码引导

在编写 Electron 桌面应用主进程或 preload 代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: electron-desktop
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/electron-desktop/index.md`
- **max_load**: 6

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 远程 API 调用 | `$frontend-backend-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/electron-desktop/index.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
