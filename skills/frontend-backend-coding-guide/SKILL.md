---
name: frontend-backend-coding-guide
description: 前后端协作编码规范引导。当 AI 编写涉及前后端交互的代码（API 调用、契约定义、错误码映射、联调准备）时触发，自动加载跨端协作规范和对应域的接口相关规则来约束代码输出。
workflow: _templates/coding-guide-workflow.md
---

# 前后端协作编码引导

在编写涉及前后端交互的代码时，自动加载跨端协作规范，确保前后端契约一致性。

## 域参数

- **domain**: frontend-backend
- **baseline_files**: `frontend-backend-collaboration.md`（始终加载 `rules/frontend-backend-collaboration.md`）
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/frontend-backend-collaboration.md`
- **max_load**: 6

## 域特有说明

- 契约一致性检查：前端请求参数与服务端接口定义一致；错误码语义前后端统一；时间格式、枚举值与服务端保持一致。
- 按场景加载涉及的前端和/或服务端规则文件，不重复加载已被其他域 coding-guide 加载的文件。
- 需要联调时提示使用配套模板（`rules/templates/frontend-backend/`）。

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 前端侧 | `$frontend-coding-guide` |
| 服务端侧 | 对应域 coding-guide |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 协作主规则：`rules/frontend-backend-collaboration.md`
3. 配套模板：`rules/templates/frontend-backend/`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
