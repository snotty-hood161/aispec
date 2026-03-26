---
name: flutter-project-scaffold
description: 根据目标平台自动初始化 Flutter 项目结构。用于新项目启动时，输入目标平台（mobile）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# Flutter 项目脚手架

## 域参数

- **domain**: flutter
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 目标平台
- **supported_modes**:
  - `mobile` — 移动端应用（Android + iOS）

## 资源
1. 脚手架映射：`references/scaffold-map.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
