---
name: database-coding-guide
description: 数据库编码规范引导。当 AI 编写数据库相关代码（建表、迁移脚本、Schema 变更）时触发，自动加载数据库规范来约束代码输出。数据库规则在跨域冲突中拥有最高优先级。
workflow: _templates/coding-guide-workflow.md
---

# 数据库编码引导

在编写数据库相关代码时，加载数据库规范约束代码输出。

## 域参数

- **domain**: database
- **baseline_files**: `database.md`（始终加载 `rules/database/database.md`；涉及数据迁移或种子数据时同时加载 `rules/database/data-migration.md`）
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/database/index.md`
- **max_load**: 6

## 域特有说明

- `schema.sql` 是全量初始化脚本，必须可在生产环境直接执行。
- 所有后续变更必须新增迁移脚本，严禁修改已有脚本。
- 迁移脚本命名：`yyyyMMdd_版本号_变更说明.sql`。
- 数据库规则在跨域冲突中拥有最高优先级。

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 新增/修改表结构影响 API | `$frontend-backend-coding-guide` |
| 涉及服务端数据模型 | 通知对应服务端 coding-guide |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则文件：`rules/database/database.md`、`rules/database/data-migration.md`
