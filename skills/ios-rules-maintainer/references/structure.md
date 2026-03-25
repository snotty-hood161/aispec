# 标准目录结构（当前完整版）

以 `<rules-root>` 表示规则根目录，目标结构如下：

```text
<rules-root>/
├── ios.md                                   # 兼容入口（指向 ios/index.md）
└── ios/
    ├── index.md                             # 规则总入口
    ├── common/
    │   ├── baseline.md                      # 技术基线与 Swift 工具链
    │   ├── code-style.md                    # Swift 命名与静态分析
    │   ├── architecture.md                  # 分层架构与依赖注入
    │   ├── error-handling.md                # 错误建模与异常处理
    │   ├── security.md                      # Keychain/ATS/代码签名
    │   ├── data-access.md                   # 数据持久化与网络请求
    │   ├── configuration.md                 # Xcode 配置与环境管理
    │   ├── observability.md                 # 日志与崩溃报告
    │   ├── performance.md                   # 启动/内存/渲染优化
    │   ├── testing-and-release.md           # 测试策略与发布流程
    │   ├── ui-framework.md                  # HIG 与无障碍
    │   └── forbidden.md                     # 禁止项（反模式）
    └── profiles/
        ├── swiftui/
        │   └── project-structure.md         # SwiftUI 项目结构
        └── uikit/
            └── project-structure.md         # UIKit 项目结构
```

## 归属规则
1. 每个规则主题只能在一个文件中定义。
2. 禁止在 `common` 和 `profiles` 重复粘贴同一规则正文。
3. 共享约束放 `common`，场景差异放 `profiles`。
4. `profile` 对同主题规则可覆盖 `common`，但必须更具体且可验证。

## 索引规则
1. `index.md` 必须列出所有 `common/*.md` 与 `profiles/**/*.md`。
2. 索引项必须唯一，禁止重复路径。
3. 索引路径使用相对 `ios/` 的格式（如 `common/architecture.md`）。
4. 新增规则文件后，必须同步更新 `index.md` 与校验脚本结果。
