---
name: go-server-coding-guide
description: Go 服务端编码规范引导。当 AI 编写 Go 服务端代码（新增接口、修改模型、添加定时任务等）时触发，自动按编码场景加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# Go 服务端编码引导

在编写 Go 服务端代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: go-server
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/go-server/index.md`
- **max_load**: 6
- **context**: 部署模式（monolith / microservice）

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| API 契约变更 | `$frontend-backend-coding-guide` |
| 数据库 schema 变更 | `$database-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/go-server/index.md`
3. 跨域仲裁：`rules/index.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
