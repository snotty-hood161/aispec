# rules/database/index.md

## 目的
1. 统一数据库 Schema 初始化、迁移脚本、种子数据的管理规范。
2. 数据库规则在跨域冲突中拥有最高优先级。

## 适用范围
1. 适用于所有项目的数据库 Schema 管理、迁移脚本、种子数据。
2. 本规则默认高于各技术栈域内的数据库相关约定；若需例外，必须在评审中记录原因、边界、回收时间。

## 规则组成
1. `database.md`：Schema 初始化与迁移脚本规范（主规则）。
2. `data-migration.md`：数据迁移与种子数据规范。

## 适用方式
1. 所有项目：`database.md`（Schema 初始化与迁移脚本规范）。
2. 涉及数据迁移或种子数据：同时加载 `data-migration.md`。

## Skill 协作（推荐）
1. 编写数据库相关代码时优先使用 `$database-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 数据库规则维护优先使用 `$database-rules-maintainer`。
4. Schema 变更影响 API 时优先使用 `$frontend-backend-coding-guide`。

## 冲突优先级
1. 数据库规则在跨域冲突中拥有最高优先级。
2. 前后端协作相关条款以 `rules/frontend-backend-collaboration.md` 为准。
3. 当规则冲突无法消解时，以"更严格、更可验证"的规则为准。

## 目录索引

### 主规则
1. `database.md` — Schema 全量初始化、迁移脚本命名与管理、严禁修改历史脚本

### 数据迁移
2. `data-migration.md` — 数据迁移策略、种子数据管理、环境隔离

### 跨端协作
3. `rules/frontend-backend-collaboration.md` — Schema 变更影响 API 时的协作流程

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/database/pr-review-checklist.md` — 数据库 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
