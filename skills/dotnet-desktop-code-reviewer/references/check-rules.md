# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（Roslyn analyzers/.editorconfig）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | .NET SDK 版本符合基线要求 | 静态扫描：检查 global.json / .csproj TargetFramework |
| BL-02 | P0 | C# 语言版本固定 | 静态扫描：检查 .csproj LangVersion |
| BL-03 | P0 | Nullable reference types 全局启用 | 静态扫描：检查 .csproj Nullable 设置 |
| BL-04 | P0 | 导出 API 有 XML 文档注释 | 静态扫描：Roslyn CS1591 |

## 二、命名与代码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 类/方法/属性使用 PascalCase | 静态扫描：.editorconfig naming rules |
| CS-02 | P0 | 局部变量/参数使用 camelCase | 静态扫描：.editorconfig naming rules |
| CS-03 | P0 | 无 Console.WriteLine / Debug.WriteLine / TODO 遗留 | 模式匹配：关键词扫描 |
| CS-04 | P0 | 公共类/方法有 XML 文档注释 | 静态扫描：Roslyn analyzers |
| CS-05 | P0 | 代码格式化通过 dotnet format 检查 | 静态扫描：dotnet format --verify-no-changes |

## 三、架构（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AR-01 | P0 | View 层无业务逻辑（仅 UI 绑定与交互转发） | 人工审查 |
| AR-02 | P0 | ViewModel 不引用 View 类型 | 模式匹配：ViewModel 文件中无 System.Windows.Controls / UI 命名空间 using |
| AR-03 | P0 | 依赖注入容器统一注册 | 模式匹配：检查 DI 注册文件完整性 |
| AR-04 | P0 | Model/DTO 不包含 UI 逻辑 | 人工审查 |
| AR-05 | P1 | 服务接口与实现分离（面向接口编程） | 人工审查 |

## 四、异常处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 全局异常处理已注册 | 模式匹配：DispatcherUnhandledException / UnhandledException 注册检查 |
| EH-02 | P0 | 禁止空 catch 吞异常 | 静态扫描：Roslyn CA1031 / .editorconfig |
| EH-03 | P0 | 用户可见错误提供友好提示 | 人工审查 |
| EH-04 | P0 | 异常日志包含上下文信息（操作、参数、堆栈） | 人工审查 |

## 五、线程与 UI（common/threading-and-ui.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TU-01 | P0 | 后台线程不直接操作 UI 控件 | 模式匹配：非 Dispatcher 上下文中的 UI 属性赋值 |
| TU-02 | P0 | 耗时操作使用 async/await 不阻塞 UI 线程 | 模式匹配：.Result / .Wait() / .GetAwaiter().GetResult() 在 UI 上下文中的误用 |
| TU-03 | P0 | UI 更新通过 Dispatcher.Invoke / MainThread.BeginInvokeOnMainThread | 模式匹配 |
| TU-04 | P1 | 后台任务支持取消（CancellationToken） | 人工审查 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库访问通过 Repository/DAL 层 | 模式匹配：ViewModel 中无直接 DbContext 调用 |
| DA-02 | P0 | 远程 API 调用通过 Service 层封装 | 模式匹配：ViewModel 中无 HttpClient 直接调用 |
| DA-03 | P0 | 数据库连接 / HTTP 连接正确释放 | 模式匹配：IDisposable / using 语句检查 |
| DA-04 | P1 | 离线场景有降级处理 | 人工审查 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置不硬编码 | 模式匹配：密码/密钥/连接字符串关键词扫描 |
| CF-02 | P0 | 配置文件使用强类型绑定（IOptions<T>） | 模式匹配：IOptions / IConfiguration 使用检查 |
| CF-03 | P0 | 用户设置与应用配置分离 | 人工审查 |

## 八、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 凭据使用 DPAPI / CredentialManager 存储 | 模式匹配：密码明文存储检查 |
| SC-02 | P0 | 用户输入有校验（路径遍历/SQL 注入） | 人工审查 |
| SC-03 | P0 | 禁止硬编码密钥/连接字符串 | 模式匹配：secret/password/connectionString 关键词扫描 |
| SC-04 | P0 | 依赖包无已知漏洞 | 静态扫描：dotnet list package --vulnerable |

## 九、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 使用结构化日志框架（Serilog / NLog） | 模式匹配：日志框架引用检查 |
| OB-02 | P0 | 崩溃报告自动收集并上报 | 人工审查 |
| OB-03 | P0 | 日志不包含敏感信息（密码、Token） | 人工审查 |
| OB-04 | P1 | 关键业务操作有遥测埋点 | 人工审查 |

## 十、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 启动时间 ≤ 3 秒（冷启动） | 人工审查：启动流程检查 |
| PF-02 | P0 | 大数据集合使用虚拟化（VirtualizingPanel）或分页 | 人工审查 |
| PF-03 | P0 | 事件处理器正确解绑防止内存泄漏 | 模式匹配：+= / -= 配对检查 |
| PF-04 | P0 | IDisposable 对象正确释放 | 静态扫描：CA2000 / using 检查 |
| PF-05 | P1 | UI 渲染无卡顿（避免同步大量数据绑定） | 人工审查 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | ViewModel / Service 有单元测试 | 模式匹配：对应 .Tests 项目中测试文件存在 |
| TR-02 | P0 | 核心覆盖率 ≥ 80% | 静态扫描：覆盖率报告 |
| TR-03 | P0 | 打包配置正确（签名/版本号） | 人工审查 |
| TR-04 | P0 | 测试无外部依赖（Mock 隔离） | 人工审查 |

## 十二、自动更新（common/auto-update.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AU-01 | P0 | 使用 Velopack 集成自动更新 | 模式匹配：Velopack NuGet 引用与初始化检查 |
| AU-02 | P0 | 更新通知有用户交互确认 | 人工审查 |
| AU-03 | P0 | 更新失败有回退机制 | 人工审查 |

## 十三、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止生产代码中 Thread.Sleep | 模式匹配：Thread.Sleep 关键词扫描 |
| FB-02 | P0 | 禁止在 UI 线程执行同步网络请求 | 模式匹配：UI 上下文中同步 HTTP 调用检查 |
| FB-03 | P0 | 禁止使用过时 API（[Obsolete] 标记） | 静态扫描：Roslyn CS0612 / CS0618 |

---

## 十四、框架专项检查

### WPF 追加项（profiles/wpf/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| WPF-01 | P0 | 项目结构符合 WPF 标准模板（Views/ViewModels/Models/Services） | 人工审查 |
| WPF-02 | P0 | XAML 数据绑定使用 {Binding} / {x:Bind}，禁止 code-behind 直接赋值 | 模式匹配 |
| WPF-03 | P0 | 样式/模板定义在 ResourceDictionary 中统一管理 | 人工审查 |

### MAUI 追加项（profiles/maui/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MAUI-01 | P0 | 项目结构符合 MAUI 标准模板 | 人工审查 |
| MAUI-02 | P0 | 平台特定代码在 Platforms/ 目录下隔离 | 模式匹配：非 Platforms/ 目录中无平台条件编译 |
| MAUI-03 | P0 | 依赖注入在 MauiProgram.cs 统一注册 | 模式匹配：检查 MauiProgram.cs 注册完整性 |

### WinForms 追加项（profiles/winforms/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| WF-01 | P0 | 项目结构符合 WinForms 标准模板 | 人工审查 |
| WF-02 | P0 | 业务逻辑不在 Form 代码后置中（MVP 分离） | 模式匹配：.Designer.cs 外的 Form 文件中无业务调用 |
| WF-03 | P0 | 控件事件正确解绑（Dispose 中 -= 取消订阅） | 模式匹配：+= / -= 配对检查 |
