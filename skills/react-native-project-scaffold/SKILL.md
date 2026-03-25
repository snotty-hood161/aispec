---
name: react-native-project-scaffold
description: 根据工作流模式自动初始化 React Native 项目结构。用于新项目启动时，输入工作流模式（expo / bare）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# React Native 项目脚手架

## 域参数

- **domain**: react-native
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 工作流模式
- **supported_modes**:
  - `expo` — Expo managed workflow（推荐新项目使用）
  - `bare` — Bare workflow（需要自定义原生代码时使用）

## 资源
1. 脚手架映射：`references/scaffold-map.md`
