# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── database/
│   ├── index.md                              # 数据库规则总入口
│   ├── database.md                           # Schema 全量初始化与迁移脚本规范
│   └── data-migration.md                     # 数据迁移与种子数据规范
├── go-server.md                         # 兼容入口（指向 go-server/index.md）
└── go-server/
    ├── index.md                             # 规则总入口
    ├── common/
    │   ├── baseline.md
    │   ├── code-style.md
    │   ├── component-initialization.md
    │   ├── api-design.md
    │   ├── error-handling.md
    │   ├── observability.md
    │   ├── configuration.md
    │   ├── concurrency-and-resource.md
    │   ├── database-access.md
    │   ├── security.md
    │   ├── testing-and-release.md
    │   ├── performance.md
    │   ├── caching.md
    │   ├── file-storage.md
    │   ├── scheduled-tasks.md
    │   └── forbidden.md
    └── profiles/
        ├── monolith/
        │   └── project-structure.md
        └── microservice/
            ├── project-structure.md
            ├── communication-and-contracts.md
            ├── service-discovery.md
            ├── resilience.md
            ├── messaging.md
            ├── gateway.md
            ├── security-communication.md
            ├── deployment-and-release.md
            ├── config-center.md
            └── containerization.md
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `go-server/` 的格式（如 `common/api-design.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
