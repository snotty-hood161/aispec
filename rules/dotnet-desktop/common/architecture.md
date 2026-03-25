# rules/dotnet-desktop/common/architecture.md

## 架构模式选型

| 框架 | 推荐架构 | MVVM 框架推荐 |
|------|---------|-------------|
| **WPF** | MVVM | CommunityToolkit.Mvvm / Prism / ReactiveUI |
| **.NET MAUI** | MVVM | CommunityToolkit.Mvvm / ReactiveUI |
| **WinForms** | MVP / MVVM（搭配绑定库） | CommunityToolkit.Mvvm + 手动绑定 |

1. WPF 和 MAUI 项目必须采用 MVVM 架构，禁止在 Code-Behind 中编写业务逻辑。
2. WinForms 项目推荐 MVP 模式，允许使用 MVVM（需搭配数据绑定基础设施）。
3. 必须选定一个 MVVM/MVP 框架并在项目中统一使用，禁止同一项目混用多个框架。

## 分层规则

### MUST
1. 分层依赖必须单向：`View → ViewModel → Service → Repository/DataAccess`，禁止反向依赖。
2. **View（视图层）**：
   - 只负责 UI 呈现和用户交互。
   - 通过数据绑定连接 ViewModel，禁止直接调用 Service 或操作数据。
   - Code-Behind 仅处理纯 UI 逻辑（如动画触发、焦点管理、拖放），不包含业务逻辑。
3. **ViewModel（视图模型层）**：
   - 负责 UI 状态管理、命令处理、数据转换。
   - 调用 Service 层完成业务逻辑，禁止直接操作数据库或文件系统。
   - 禁止引用任何 UI 框架类型（`Window`、`Control`、`Page`、`MessageBox`）。
   - 需要用户交互（如弹窗确认、文件选择）时，必须通过接口抽象（如 `IDialogService`、`IFileDialogService`）。
4. **Service（服务/应用层）**：
   - 负责业务逻辑编排、数据校验、业务规则。
   - 不依赖 UI 框架类型和 ViewModel。
5. **Repository / DataAccess（数据访问层）**：
   - 负责本地数据库操作、远程 API 调用、文件读写。
   - 不承载业务决策。

### 分层边界细则
1. View 禁止直接实例化 ViewModel（应通过 DI 注入或 ViewModelLocator）。
2. ViewModel 禁止持有 View 的引用。
3. Service 禁止依赖 ViewModel 或 View。
4. Repository 返回领域模型或 DTO，禁止返回 UI 框架类型。

## 依赖注入

### MUST
1. 桌面应用必须使用 DI 容器管理依赖（推荐 `Microsoft.Extensions.DependencyInjection`）。
2. ViewModel、Service、Repository 通过构造函数注入依赖，禁止使用 Service Locator 模式。
3. DI 容器在应用启动时配置，ViewModel 注册为 `Transient`（每次导航创建新实例）或按需选择生命周期。
4. 需要在非 DI 管理的地方（如 XAML DataTemplate）解析 ViewModel 时，使用 ViewModelLocator 模式或 `DataTemplateSelector`，禁止直接 `new ViewModel()`。

### 配置示例（WPF + Microsoft.Extensions.DependencyInjection）
```csharp
public partial class App : Application
{
    private readonly IHost _host;

    public App()
    {
        _host = Host.CreateDefaultBuilder()
            .ConfigureServices((context, services) =>
            {
                // 基础服务
                services.AddSingleton<IDialogService, DialogService>();
                services.AddSingleton<INavigationService, NavigationService>();

                // 数据访问
                services.AddSingleton<IUserRepository, UserRepository>();
                services.AddHttpClient<IApiClient, ApiClient>();

                // 业务服务
                services.AddTransient<IUserService, UserService>();

                // ViewModel
                services.AddTransient<MainWindowViewModel>();
                services.AddTransient<UserListViewModel>();

                // View
                services.AddTransient<MainWindow>();
            })
            .Build();
    }

    protected override async void OnStartup(StartupEventArgs e)
    {
        await _host.StartAsync();
        var mainWindow = _host.Services.GetRequiredService<MainWindow>();
        mainWindow.Show();
        base.OnStartup(e);
    }

    protected override async void OnExit(ExitEventArgs e)
    {
        await _host.StopAsync();
        _host.Dispose();
        base.OnExit(e);
    }
}
```

## 导航与页面管理

### MUST
1. 多页面应用必须使用统一的导航服务（`INavigationService`），禁止在 ViewModel 中直接实例化或操作 Window/Page。
2. 导航服务负责页面创建（通过 DI）、页面切换、参数传递和页面生命周期管理。
3. 导航参数通过强类型对象传递，禁止使用 `object` 或 `Dictionary<string, object>` 作为参数载体。
4. 页面离开时必须支持清理逻辑（取消进行中的异步操作、释放资源）。

## 对话框与用户交互抽象

### MUST
1. 对话框（确认框、文件选择器、消息提示）必须通过接口抽象，禁止在 ViewModel 中直接调用 `MessageBox.Show` 或 `OpenFileDialog`。
2. 推荐定义的抽象接口：
   - `IDialogService`：确认框、消息框。
   - `IFileDialogService`：文件打开/保存对话框。
   - `INotificationService`：Toast 通知 / Snackbar。
3. 接口实现注册到 DI 容器，测试时可替换为 Mock 实现。

## 模型与 DTO 约束
1. 领域模型用于表达业务语义，ViewModel 使用展示模型（Display Model）或直接绑定领域模型。
2. API 响应 DTO 仅用于数据传输层，禁止直接绑定到 UI（应在 Service 或 ViewModel 中转换）。
3. 持久化实体（本地数据库模型）仅用于数据访问层，禁止直接暴露到 ViewModel。
