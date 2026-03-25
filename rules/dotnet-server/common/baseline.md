# rules/dotnet-server/common/baseline.md

## 技术基线
1. .NET 版本以项目 `TargetFramework` 为准（推荐 .NET 8 LTS 及以上），升级 .NET 版本必须单独提交并验证兼容性。
2. 必须使用 SDK-style 项目文件（`.csproj`），禁止使用旧式 `packages.config`。
3. 第三方依赖统一通过 NuGet 管理，禁止复制外部 DLL 或源码进业务目录。
4. 提交前必须确保 `dotnet restore` 后无额外变更；`packages.lock.json` 必须纳入版本控制（启用 `RestorePackagesWithLockFile`）。
5. 全局启用 `<Nullable>enable</Nullable>` 和 `<ImplicitUsings>enable</ImplicitUsings>`，新项目默认启用 `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`。

## 依赖安全审查（MUST）

1. CI 流水线必须集成 `dotnet list package --vulnerable`，检测已知漏洞的依赖，发现高危漏洞（CVSS >= 7.0）阻断合并。
2. 新增或升级第三方依赖前，必须确认其许可证兼容项目发布方式（商用项目禁止引入 GPL/AGPL 依赖）。
3. 禁止引入已归档（archived）、超过 12 个月无维护更新的依赖，确需使用须在 PR 中说明风险并附回收计划。
4. `packages.lock.json` 必须纳入版本控制，禁止在 `.gitignore` 中忽略。
5. 依赖更新必须单独提交（与业务代码分离），便于审查和回滚。

### SHOULD
1. 定期（每月）执行 `dotnet list package --vulnerable --include-transitive` 全量扫描，输出漏洞报告并限时修复。
2. 使用 `dotnet-outdated` 或等效工具检测过期依赖，核心依赖锁定主版本，升级需经评审。
3. 考虑使用 `Directory.Build.props` 和 `Directory.Packages.props`（Central Package Management）统一管理多项目依赖版本。

检查方式：`dotnet list package --vulnerable` + 许可证扫描 + CI 阻断
阻断级别：阻断合并（高危漏洞）/ 告警记录（中低危）

## 基础工程要求
1. 启动入口（`Program.cs`）仅做服务注册、中间件管道配置和生命周期管理，不承载业务逻辑。
2. 业务代码必须按分层组织，禁止横向耦合和循环依赖。
3. 异步方法必须贯穿全链路（async/await），禁止在异步上下文中使用 `.Result` 或 `.Wait()` 阻塞调用。
4. 可复用且无业务语义的通用能力放入独立类库项目（如 `*.Infrastructure`、`*.Shared`）。
5. 带作用域语义的能力按"作用域 + 职责"组织，做到"一文件一责任"。
6. 错误处理必须采用"统一异常处理中间件 + 统一响应结构"模式，禁止在 Controller/Endpoint 中散落式实现。
7. 组件初始化必须遵循 `common/component-initialization.md`，采用 ASP.NET Core 内置 DI 与统一生命周期管理。
