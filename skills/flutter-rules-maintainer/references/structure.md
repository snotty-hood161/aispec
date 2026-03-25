# Flutter 规则目录结构标准

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── database/
│   └── database.md                          # 数据库迁移总规则
└── flutter/
    ├── index.md                             # 规则总入口与索引
    ├── common/                              # 13 个通用规则文件
    │   ├── baseline.md
    │   ├── code-style.md
    │   ├── architecture.md
    │   ├── error-handling.md
    │   ├── security.md
    │   ├── data-access.md
    │   ├── configuration.md
    │   ├── observability.md
    │   ├── performance.md
    │   ├── testing-and-release.md
    │   ├── ui-framework.md
    │   ├── device-adaptation.md
    │   └── forbidden.md
    └── profiles/
        └── mobile/
            └── project-structure.md         # 移动端项目结构
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `flutter/` 的格式（如 `common/architecture.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
