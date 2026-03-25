# rules/dotnet-desktop/common/baseline.md

## 技术基线
1. .NET 版本以项目 `TargetFramework` 为准（WPF/WinForms 推荐 .NET 8 LTS 及以上；MAUI 推荐 .NET 8+），升级版本必须单独提交并验证兼容性。
2. 必须使用 SDK-style 项目文件（`.csproj`），禁止使用旧式 `packages.config`。
3. 第三方依赖统一通过 NuGet 管理，禁止复制外部 DLL 或源码进业务目录。
4. 提交前必须确保 `dotnet restore` 后无额外变更。
5. 全局启用 `<Nullable>enable</Nullable>` 和 `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`。

## 依赖安全审查（MUST）

1. CI 流水线必须集成 `dotnet list package --vulnerable`，检测已知漏洞的依赖，发现高危漏洞（CVSS >= 7.0）阻断合并。
2. 新增或升级第三方依赖前，必须确认其许可证兼容项目发布方式（商用项目禁止引入 GPL/AGPL 依赖）。
3. 禁止引入已归档（archived）、超过 12 个月无维护更新的依赖，确需使用须在 PR 中说明风险并附回收计划。
4. 依赖更新必须单独提交（与业务代码分离），便于审查和回滚。
5. 桌面应用需特别注意原生依赖（C++/CLI、P/Invoke 库）的安全性和兼容性。

### SHOULD
1. 定期（每月）执行 `dotnet list package --vulnerable --include-transitive` 全量扫描。
2. 使用 `Directory.Build.props` 和 `Directory.Packages.props`（Central Package Management）统一管理多项目依赖版本。
3. 核心依赖（UI 框架、MVVM 框架、ORM）锁定主版本，升级需经评审。

检查方式：`dotnet list package --vulnerable` + 许可证扫描 + CI 阻断
阻断级别：阻断合并（高危漏洞）/ 告警记录（中低危）

## 基础工程要求
1. 启动入口（`App.xaml.cs` / `Program.cs`）仅做 DI 容器配置、服务注册和应用初始化，不承载业务逻辑。
2. 业务代码必须按分层组织（View → ViewModel → Service → Repository/DataAccess），禁止横向耦合和循环依赖。
3. UI 层（View）禁止包含业务逻辑，仅负责数据绑定、用户交互和视觉呈现。
4. ViewModel 禁止直接操作 UI 控件，必须通过数据绑定和命令模式与 View 交互。
5. 可复用且无业务语义的通用能力放入独立类库项目。
6. 全局异常处理必须在启动阶段注册，确保未捕获异常不会导致应用静默崩溃。
