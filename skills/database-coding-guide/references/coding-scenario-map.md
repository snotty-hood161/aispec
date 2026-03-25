# 数据库编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/database/database.md`

---

## A. 新建表（初始化 Schema）
- 主文件：`rules/database/database.md`
- 要点：schema.sql 必须包含所有表结构、索引、初始化数据，可在生产环境直接执行
- 跨域：新表影响 API → 触发 `$frontend-backend-coding-guide`

## B. 新增迁移脚本（字段变更 / 索引变更 / 数据变更）
- 主文件：`rules/database/database.md`
- 要点：
  - 文件命名：`yyyyMMdd_版本号_变更说明.sql`
  - 放置目录：`docs/migrations`
  - 严禁修改任何已存在的 SQL 脚本
- 跨域：字段变更影响 API → 触发 `$frontend-backend-coding-guide`
- 跨域：字段变更影响数据模型 → 通知对应服务端 coding-guide

## C. 审计已有脚本
- 主文件：`rules/database/database.md`
- 要点：检查是否有历史脚本被修改（严禁）

---

## 冲突优先级
1. 数据库规则在所有跨域冲突中拥有最高优先级。
2. 迁移脚本格式和命名以 `rules/database/database.md` 为唯一标准。
