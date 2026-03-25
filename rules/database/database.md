# rules/database/database.md

## Skill 协作
1. 编写数据库相关代码时优先使用 `$database-coding-guide`，自动加载本规则。
2. 跨域业务任务使用 `$task-router` 自动路由。
3. 规则维护使用 `$database-rules-maintainer`。

##	schema.sql 是全量初始化脚本
1. 包含：所有表结构、索引、菜单、权限初始化数据
2. 必须保证可在生产环境直接执行完成数据库初始化

## 所有后续结构或数据变更必须新增迁移脚本
1. 迁移脚本目录：docs/migrations
2. 文件命名格式：yyyyMMdd_版本号_变更说明.sql
- 示例：
    20251230_01_add_channel_partner_admin_menu.sql
    20251230_02_add_channel_onboarding_admin_menu.sql
	
## 严禁修改任何已存在的 SQL 脚本
1. 包括 schema.sql 和所有历史 migration
2. 数据库变更必须通过新增脚本完成
