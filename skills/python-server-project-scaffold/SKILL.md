---
name: python-server-project-scaffold
description: 根据部署模式自动初始化 Python 服务端项目结构。用于新项目启动时，输入部署模式（monolith / microservice）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# Python 服务端项目脚手架

## 域参数

- **domain**: python-server
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 部署模式
- **supported_modes**:
  - `monolith` — 单体应用（FastAPI/Django/Flask HTTP API + Celery 任务 + Worker）
  - `microservice` — 微服务（FastAPI/Django HTTP + gRPC + 消息消费 + 独立部署）

## 资源
1. 脚手架映射：`references/scaffold-map.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
