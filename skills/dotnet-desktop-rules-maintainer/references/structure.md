# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── dotnet-desktop.md                          # 兼容入口（指向 dotnet-desktop/index.md）
└── dotnet-desktop/
    ├── index.md                               # 规则总入口
    ├── common/
    │   ├── baseline.md                        # 技术基线
    │   ├── code-style.md                      # 代码风格
    │   ├── architecture.md                    # MVVM/MVP 架构
    │   ├── error-handling.md                  # 异常处理
    │   ├── threading-and-ui.md                # UI 线程与异步
    │   ├── data-access.md                     # 数据访问
    │   ├── configuration.md                   # 配置与设置
    │   ├── security.md                        # 安全
    │   ├── observability.md                   # 日志与崩溃报告
    │   ├── performance.md                     # 性能
    │   ├── testing-and-release.md             # 测试与发布
    │   ├── auto-update.md                     # 自动更新
    │   └── forbidden.md                       # 禁止项
    └── profiles/
        ├── wpf/
        │   └── project-structure.md           # WPF 项目结构与 MVVM
        ├── maui/
        │   └── project-structure.md           # MAUI 项目结构与 Shell 导航
        └── winforms/
            └── project-structure.md           # WinForms 项目结构与 MVP
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `dotnet-desktop/` 的格式（如 `common/architecture.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
