# rules/dotnet-desktop/common/testing-and-release.md

## 测试策略

### 单元测试（MUST）
1. ViewModel 和 Service 层必须有单元测试覆盖：命令执行、状态变更、错误处理。
2. 测试框架推荐 xUnit + FluentAssertions，Mock 框架推荐 Moq 或 NSubstitute。
3. ViewModel 测试通过 Mock 的 Service 接口验证行为，禁止依赖真实 UI 框架。
4. 对话框、导航等 UI 交互通过 Mock 接口（`IDialogService`、`INavigationService`）验证调用。
5. 测试命名规范：`{方法名}_{场景}_{预期结果}`。

### 集成测试（MUST）
1. 数据访问层集成测试使用内存数据库（SQLite In-Memory）或 Testcontainers。
2. API 客户端集成测试使用 `MockHttpMessageHandler`（推荐 `RichardSzalay.MockHttp`）模拟 HTTP 响应。
3. 必须覆盖：正常路径、网络超时、API 错误响应、本地数据库故障。

### UI 测试（SHOULD）
1. 关键用户流程推荐 UI 自动化测试：
   - WPF：`FlaUI` / `Appium WinAppDriver`。
   - MAUI：`Appium` + MAUI 驱动。
   - WinForms：`FlaUI`。
2. UI 测试至少覆盖核心业务流程（登录 → 主要操作 → 退出）。

### 修复与回归
1. 修复缺陷必须补回归测试。
2. 对外行为变化必须有测试覆盖：成功路径、参数错误、下游失败、取消操作。

## 质量门禁（MUST）
1. 合并前必须通过 `dotnet build --warnaserrors` + `dotnet test` + Roslyn 分析器。
2. PR 描述必须包含变更目的、影响范围、测试结果。
3. PR 评审必须附 `templates/dotnet-desktop/pr-review-checklist.md` 的勾选结果。
4. 新增业务代码行覆盖率建议 >= 70%。
5. 无 `Console.WriteLine`、`Debugger.Break()` 等调试代码残留。

## 版本管理（MUST）
1. 应用版本号遵循语义化版本（SemVer）：`Major.Minor.Patch`。
2. 版本号在 `Directory.Build.props` 或 `.csproj` 中统一管理，CI 自动递增。
3. 每个发布版本必须打 Git Tag，与构建产物一一对应。

## 打包与分发（MUST）

| 方式 | 适用场景 | 说明 |
|------|---------|------|
| **MSIX** | Windows 10/11 现代应用 | 推荐首选，支持自动更新、沙盒安装 |
| **Self-Contained** | 离线分发、无 .NET 运行时环境 | 单文件发布（`PublishSingleFile`） |
| **ClickOnce** | 企业内网分发 | 支持自动更新，配置简单 |
| **Installer (MSI/EXE)** | 传统安装包 | WiX Toolset / Inno Setup |

1. 生产发布必须为 Release 配置构建，禁止分发 Debug 版本。
2. 发布产物必须进行数字签名（Authenticode Signing），防止 SmartScreen 警告和篡改。
3. 发布前必须在干净环境（无开发工具）中测试安装和运行。

## 自动更新（SHOULD）
1. 应用推荐支持自动更新机制：
   - MSIX：内置自动更新支持。
   - 非 MSIX：推荐 `Squirrel.Windows` / `AutoUpdater.NET` / 自建更新服务。
2. 更新包必须校验签名或哈希，防止中间人攻击。
3. 更新检查应在后台静默进行，发现更新后通知用户（非强制中断）。
4. 支持增量更新（差异包），减少下载量。
5. 更新失败必须可回滚到上一个版本。

## 发布检查清单
1. 版本号已更新。
2. 发布说明（Changelog）已编写。
3. 数字签名已完成。
4. 干净环境安装测试通过。
5. 自动更新流程验证通过（如适用）。
6. 崩溃报告收集功能验证通过。
