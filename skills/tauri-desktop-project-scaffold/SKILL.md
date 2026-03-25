---
name: tauri-desktop-project-scaffold
description: 根据前端框架自动初始化 Rust + Tauri 桌面应用项目结构。用于新项目启动时，输入前端框架（vue / react / svelte / solid）后自动读取对应规则，生成 Rust 后端与前端目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# Tauri 桌面应用项目脚手架

## 域参数

- **domain**: tauri-desktop
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 前端框架
- **supported_modes**:
  - `vue` — Vue 3 + TypeScript + Vite
  - `react` — React + TypeScript + Vite
  - `svelte` — Svelte + TypeScript + Vite
  - `solid` — SolidJS + TypeScript + Vite

## 资源
1. 脚手架映射：`references/scaffold-map.md`
