---
name: dotnet-desktop-coding-guide
description: .NET 桌面应用编码规范引导。当 AI 编写 WPF/MAUI/WinForms 桌面应用代码时触发，自动按编码场景加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# .NET 桌面编码引导

在编写 C#/.NET 桌面应用代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: dotnet-desktop
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/dotnet-desktop/index.md`
- **max_load**: 6
- **context**: 框架（WPF / MAUI / WinForms）

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 远程 API 调用 | `$frontend-backend-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/dotnet-desktop/index.md`
