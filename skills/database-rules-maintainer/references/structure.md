# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
└── database/
    ├── index.md                            # 数据库规则总入口
    ├── database.md                         # 数据库 Schema 与迁移规则
    └── data-migration.md                   # 数据迁移与种子数据规范
```

## 归属规则
1. 数据库规则仅在 `database/database.md` 中定义。
2. 所有跨域文件仅引用，不重复粘贴规则正文。
3. 数据库规则在跨域冲突中拥有最高优先级。

## 索引规则
1. `rules/index.md` 必须列出 `database/database.md`。
2. 新增规则条款后，必须同步更新校验脚本。
