---
name: electron-desktop-project-scaffold
description: 根据渲染进程前端框架自动初始化 Electron 桌面应用项目结构。用于新项目启动时，输入前端框架（react / vue）后自动读取对应规则，生成主进程、preload、渲染进程目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# Electron 桌面应用项目脚手架

## 域参数

- **domain**: electron-desktop
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 前端框架
- **supported_modes**:
  - `react` — React + TypeScript + Vite
  - `vue` — Vue 3 + TypeScript + Vite

## 资源
1. 脚手架映射：`references/scaffold-map.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
