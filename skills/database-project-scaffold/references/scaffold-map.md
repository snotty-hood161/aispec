# 脚手架映射表（初始化场景 → 规则与模板文件）

本文件定义每种数据库初始化场景需要读取的规则文件与模板文件。

## 使用方式
1. 确认初始化场景后，按下表加载对应文件。
2. "通用必读"对所有场景生效。
3. "专项文件"仅对特定场景生效。

---

## 一、通用必读（所有初始化场景）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/database/database.md` | schema.sql 规范、迁移脚本命名与目录、严禁修改历史脚本 |
| `rules/database/data-migration.md` | 迁移脚本分类与结构、种子数据规范、备份恢复、数据脱敏 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/database/pr-review-checklist.md` | 数据库 PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

### 跨域规则（按需加载）
| 文件 | 触发条件 |
|------|---------|
| `rules/frontend-backend-collaboration.md` | Schema 变更影响 API 接口时 |
| `rules/security/security-baseline.md` | 涉及敏感数据存储时 |

---

## 二、standalone 专项（独立数据库）

### 要点
- 一个服务对应一个数据库，无需 schema/前缀隔离。
- schema.sql 直接创建所有表。
- 迁移脚本按时间顺序编号。

### 生成产物
| 产出物 | 来源 |
|--------|------|
| `schema.sql`（含 `_migration_history` 表） | `rules/database/database.md` |
| `docs/migrations/README.md` | `rules/database/data-migration.md` |
| `docs/migrations/_example_migration.sql` | `rules/database/data-migration.md`（UP/DOWN 模板） |
| `docs/seeds/README.md` | `rules/database/data-migration.md`（种子数据规范） |

---

## 三、shared 专项（共享数据库）

### 要点
- 多个服务共享一个数据库，按 schema 或表名前缀隔离。
- schema.sql 中使用 `CREATE SCHEMA IF NOT EXISTS` 做命名空间隔离。
- 迁移脚本需标注所属服务（命名中包含服务标识）。

### 额外生成产物
| 产出物 | 说明 |
|--------|------|
| schema 命名空间定义 | 在 schema.sql 中按服务划分 schema |
| 迁移脚本命名扩展 | `yyyyMMdd_VV_{service}_变更说明.sql` |

---

## 四、multi-tenant 专项（多租户数据库）

### 要点
- 需在 schema.sql 中体现租户隔离策略。
- 行级隔离：所有业务表包含 `tenant_id` 字段 + 复合索引。
- Schema 级隔离：提供租户 schema 创建模板脚本。
- 库级隔离：提供租户库创建与路由配置模板。

### 额外生成产物
| 产出物 | 说明 |
|--------|------|
| 租户隔离基础结构 | 根据隔离策略在 schema.sql 中体现 |
| 租户初始化脚本模板 | 新租户开通时执行的初始化脚本 |

---

## 五、生成产物清单（通用）

每种初始化场景完成后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| `schema.sql`（全量初始化脚本） | `rules/database/database.md` |
| `docs/migrations/` 目录 + README | `rules/database/data-migration.md` |
| `docs/migrations/_example_migration.sql` | `rules/database/data-migration.md`（UP/DOWN 模板） |
| `docs/seeds/` 目录 + README | `rules/database/data-migration.md`（种子数据规范） |
| `docs/seeds/dev/` 占位 | 开发环境种子数据 |
| `docs/seeds/staging/` 占位 | 预发布环境种子数据 |
| 数据库 PR 评审清单 | `rules/templates/database/pr-review-checklist.md` |
