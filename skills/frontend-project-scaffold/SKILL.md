---
name: frontend-project-scaffold
description: 根据应用类型自动初始化前端项目结构。用于新项目启动时，输入应用类型（admin-console / wechat-h5 / miniprogram）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# 前端项目脚手架

## 域参数

- **domain**: frontend
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 应用类型
- **supported_modes**:
  - `admin-console` — Vue3 + TypeScript + Vite + Element Plus + Tailwind CSS
  - `wechat-h5` — uni-app + Vue3 + TypeScript + UnoCSS + uview-plus
  - `miniprogram` — uni-app + Vue3 + TypeScript + UnoCSS + uview-plus

## 域特有配置

### admin-console
- Tailwind CSS + Element Plus 组合 → `templates/frontend/tailwind-element-plus.md`
- 权限点命名 → `templates/frontend/permission-naming.md`
- ProTable → `templates/frontend/pro-table.md`

### wechat-h5
- 微信授权与分享 → `templates/frontend/wechat-auth-share-flow.md`
- uni.request 封装 → `templates/frontend/uni-request-wrapper.md`
- H5 工具包 → `templates/frontend/wechat-h5-toolkit.md`

### miniprogram
- 审核清单 → `templates/frontend/miniprogram-review-checklist.md`
- CI 检查 → `templates/frontend/miniprogram-ci-checks.md`
- uni.request 封装 → `templates/frontend/uni-request-wrapper.md`

## 资源
1. 脚手架映射：`references/scaffold-map.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
