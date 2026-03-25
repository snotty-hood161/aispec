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
