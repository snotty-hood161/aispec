---
name: android-coding-guide
description: Android 移动端编码规范引导。当 AI 编写 Kotlin/Java Android 应用代码时触发，根据 UI 框架（Compose/XML Views）自动加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# Android 编码引导

在编写 Kotlin/Java Android 应用代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: android
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/android/index.md`
- **max_load**: 6
- **context**: UI 框架（Compose / XML Views）

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 远程 API 调用 | `$frontend-backend-coding-guide` |
| 数据库本地存储 | 参考 `rules/database/database.md` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/android/index.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
