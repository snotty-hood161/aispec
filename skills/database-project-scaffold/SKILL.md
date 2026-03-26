---
name: database-project-scaffold
description: 初始化数据库层项目结构。用于新项目启动时，根据后端技术栈自动生成 schema.sql、迁移目录、种子数据结构和 PR 评审清单，确保数据库层从第一天就符合规范。
workflow: _templates/project-scaffold-workflow.md
---

# 数据库项目脚手架

## 域参数

- **domain**: database
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 初始化场景
- **supported_modes**:
  - `standalone` — 独立数据库（单一服务对应单一数据库）
  - `shared` — 共享数据库（多个服务共享一个数据库，按 schema/前缀隔离）
  - `multi-tenant` — 多租户数据库（租户隔离策略：schema 级 / 行级 / 库级）

## 资源
1. 脚手架映射：`references/scaffold-map.md`
2. 规则文件：`rules/database/database.md`、`rules/database/data-migration.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
