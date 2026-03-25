---
name: react-native-coding-guide
description: React Native 跨平台编码规范引导。当 AI 编写 React Native + TypeScript 应用代码时触发，自动按编码场景加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# React Native 编码引导

在编写 React Native + TypeScript 跨平台移动应用代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: react-native
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/react-native/index.md`
- **max_load**: 6

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 远程 API 调用 | `$frontend-backend-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/react-native/index.md`
