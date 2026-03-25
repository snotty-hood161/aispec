# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── electron-desktop.md                      # 兼容入口（指向 electron-desktop/index.md）
└── electron-desktop/
    ├── index.md                             # 规则总入口
    ├── common/
    │   ├── baseline.md                      # 技术基线与 TypeScript 工具链
    │   ├── code-style.md                    # 主进程/preload 代码风格
    │   ├── architecture.md                  # 主进程/渲染进程分层与 IPC 设计
    │   ├── error-handling.md                # 主进程错误处理与渲染进程错误边界
    │   ├── security.md                      # contextIsolation/nodeIntegration/CSP/沙箱
    │   ├── ipc-communication.md             # 进程间通信（IPC）设计规范
    │   ├── configuration.md                 # 配置/用户设置/凭据管理
    │   ├── observability.md                 # 日志与崩溃报告
    │   ├── performance.md                   # 启动/内存/IPC 性能优化
    │   ├── auto-update.md                   # electron-updater 自动更新
    │   ├── testing-and-release.md           # 测试/CI/CD/发布
    │   └── forbidden.md                     # 禁止项（反模式）
    └── profiles/
        └── electron-v30/
            └── project-structure.md         # Electron v30+ 项目结构
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `electron-desktop/` 的格式（如 `common/architecture.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
