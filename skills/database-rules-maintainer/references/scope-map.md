# 主题落点映射（需求 -> 规则条款）

用此表将用户需求映射到 `database/database.md` 中的具体条款。

## 主题映射

| 主题 | 定义位置 | 关键约束 |
| --- | --- | --- |
| Schema 初始化 | `database/database.md` §1 | schema.sql 为全量初始化脚本 |
| 迁移脚本管理 | `database/database.md` §2 | 新增脚本到 docs/migrations，命名 yyyyMMdd_版本号_变更说明.sql |
| 历史脚本保护 | `database/database.md` §3 | 严禁修改已存在的 SQL 脚本 |
| 数据迁移与种子数据 | `database/data-migration.md` | 迁移策略、种子数据管理、环境隔离 |
| 跨端影响 | `rules/frontend-backend-collaboration.md` | API 契约变更需联动评审 |
| PR 评审清单 | `rules/templates/database/pr-review-checklist.md` | 数据库变更 PR 评审标准 |
| 规范例外申请 | `rules/templates/exception-request-template.md` | 规范例外流程 |

## 冲突决策
1. 数据库规则在跨域冲突仲裁中拥有最高优先级。
2. 与任何域的规则冲突时，以 `database/database.md` 为准。
