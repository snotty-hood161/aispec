# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── tauri-desktop.md                         # 兼容入口（指向 tauri-desktop/index.md）
└── tauri-desktop/
    ├── index.md                             # 规则总入口
    ├── common/
    │   ├── baseline.md                      # 技术基线与 Rust 工具链
    │   ├── code-style.md                    # Rust/前端代码风格
    │   ├── architecture.md                  # 前后端分层与 IPC 设计
    │   ├── error-handling.md                # Rust 错误处理与前端错误边界
    │   ├── security.md                      # 权限模型/CSP/文件系统隔离
    │   ├── data-access.md                   # 本地数据库与远程 API
    │   ├── configuration.md                 # 配置/用户设置/凭据管理
    │   ├── observability.md                 # 日志与崩溃报告
    │   ├── performance.md                   # 启动/内存/IPC 性能优化
    │   ├── auto-update.md                   # Tauri Updater 自动更新
    │   ├── testing-and-release.md           # 测试/CI/CD/发布
    │   └── forbidden.md                     # 禁止项（反模式）
    └── profiles/
        └── tauri-v2/
            └── project-structure.md         # Tauri v2 项目结构
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `tauri-desktop/` 的格式（如 `common/architecture.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
