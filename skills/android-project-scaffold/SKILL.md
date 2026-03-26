---
name: android-project-scaffold
description: 根据 UI 框架自动初始化 Android 应用项目结构。用于新项目启动时，输入 UI 框架（compose / xml-views）后自动读取对应规则，生成标准目录结构、Gradle 配置、Hilt 模块、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# Android 应用项目脚手架

## 域参数

- **domain**: android
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: UI 框架
- **supported_modes**:
  - `compose` — Jetpack Compose + Kotlin + Material 3
  - `xml-views` — XML Views + ViewBinding + Kotlin

## 资源
1. 脚手架映射：`references/scaffold-map.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
