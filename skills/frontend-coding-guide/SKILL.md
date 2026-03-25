---
name: frontend-coding-guide
description: 前端编码规范引导。当 AI 编写前端代码（页面、组件、路由、状态管理等）时触发，根据应用类型（admin-console/wechat-h5/miniprogram）和框架（Vue3/React）自动加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# 前端编码引导

在编写前端代码时，按应用类型 + 编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: frontend
- **baseline_files**: `baseline.md`, `naming.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/frontend/index.md`
- **max_load**: 6
- **context**: 应用类型（admin-console / wechat-h5 / miniprogram）+ 框架（Vue3 / React）

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| API 接口调用 | `$frontend-backend-coding-guide` |
| 跨端组件适配 | 加载 `rules/frontend/common/componentization-and-adaptation.md` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/frontend/index.md`
3. 跨域仲裁：`rules/index.md`
