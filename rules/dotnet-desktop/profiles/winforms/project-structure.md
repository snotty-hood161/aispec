# rules/dotnet-desktop/profiles/winforms/project-structure.md

## 适用场景
1. Windows 桌面应用，使用 WinForms（Windows Forms）框架。
2. 目标框架：`.NET 8` 及以上（新项目禁止使用 .NET Framework WinForms，存量迁移项目除外）。
3. 适用于数据录入工具、管理后台客户端、企业内部工具等场景。

## 推荐解决方案结构
```text
MyWinFormsApp/
├── src/
│   ├── MyWinFormsApp/                            # WinForms 主项目（启动项目）
│   │   ├── Program.cs                            # 入口，DI 配置，全局异常处理
│   │   ├── appsettings.json                      # 应用配置
│   │   ├── Forms/                                # 窗体（视图层）
│   │   │   ├── MainForm.cs                       # 主窗体
│   │   │   ├── MainForm.Designer.cs              # 设计器生成
│   │   │   ├── UserListForm.cs
│   │   │   ├── UserDetailForm.cs
│   │   │   └── Dialogs/
│   │   │       └── ConfirmDialog.cs
│   │   ├── Presenters/                           # Presenter 层（MVP）或 ViewModel 层
│   │   │   ├── MainFormPresenter.cs
│   │   │   ├── UserListPresenter.cs
│   │   │   └── UserDetailPresenter.cs
│   │   ├── Views/                                # View 接口定义
│   │   │   ├── IMainFormView.cs
│   │   │   ├── IUserListView.cs
│   │   │   └── IUserDetailView.cs
│   │   ├── Resources/                            # 资源文件
│   │   │   ├── Icons/
│   │   │   └── Strings.resx                      # 本地化字符串
│   │   └── Hosting/
│   │       └── ServiceExtensions.cs
│   │
│   ├── MyWinFormsApp.Application/                # 应用服务层
│   │   ├── Users/
│   │   │   ├── IUserService.cs
│   │   │   └── UserService.cs
│   │   └── ...
│   │
│   ├── MyWinFormsApp.Domain/                     # 领域层
│   │   ├── Entities/
│   │   ├── Exceptions/
│   │   └── Interfaces/
│   │       ├── IUserRepository.cs
│   │       └── IDialogService.cs
│   │
│   ├── MyWinFormsApp.Infrastructure/             # 基础设施层
│   │   ├── Data/
│   │   │   ├── AppDbContext.cs
│   │   │   └── Repositories/
│   │   ├── ApiClients/
│   │   ├── Services/
│   │   │   ├── WinFormsDialogService.cs
│   │   │   └── WinFormsNavigationService.cs
│   │   └── Extensions/
│   │
│   └── MyWinFormsApp.Shared/
│       └── Options/
│
├── tests/
│   ├── MyWinFormsApp.UnitTests/
│   └── MyWinFormsApp.IntegrationTests/
│
├── Directory.Build.props
└── MyWinFormsApp.sln
```

## MVP 架构规则

### Model-View-Presenter 模式
1. WinForms 推荐使用 **Passive View** 变体的 MVP 模式。
2. **View（Form）**：
   - 实现 View 接口（如 `IUserListView`），暴露 UI 数据属性和用户操作事件。
   - Form 本身不包含业务逻辑，仅负责控件事件转发和数据展示。
   - Designer 生成的代码不手动修改。
3. **Presenter**：
   - 持有 View 接口引用和 Service 引用。
   - 处理用户操作事件、调用 Service、更新 View 状态。
   - 禁止引用具体的 Form 类型，仅依赖 View 接口。
4. **Model/Service**：与通用分层规则一致。

### View 接口示例
```csharp
public interface IUserListView
{
    event EventHandler LoadRequested;
    event EventHandler<int> DeleteRequested;

    bool IsLoading { set; }
    string? ErrorMessage { set; }
    IReadOnlyList<UserDto> Users { set; }
}
```

### Presenter 示例
```csharp
public class UserListPresenter
{
    private readonly IUserListView _view;
    private readonly IUserService _userService;

    public UserListPresenter(IUserListView view, IUserService userService)
    {
        _view = view;
        _userService = userService;
        _view.LoadRequested += async (s, e) => await LoadUsersAsync();
        _view.DeleteRequested += async (s, userId) => await DeleteUserAsync(userId);
    }

    private async Task LoadUsersAsync()
    {
        _view.IsLoading = true;
        _view.ErrorMessage = null;
        try
        {
            var users = await _userService.GetUsersAsync();
            _view.Users = users;
        }
        catch (Exception ex)
        {
            _view.ErrorMessage = "加载失败，请重试";
        }
        finally
        {
            _view.IsLoading = false;
        }
    }
}
```

## DI 配置（MUST）

1. WinForms 项目使用 Generic Host（`Host.CreateDefaultBuilder`）配置 DI，与 WPF/MAUI 保持一致。
2. Form 注册为 `Transient`，Presenter 注册为 `Transient`，Service 按需选择生命周期。
3. 启动入口示例：
   ```csharp
   static class Program
   {
       [STAThread]
       static void Main()
       {
           ApplicationConfiguration.Initialize();

           var host = Host.CreateDefaultBuilder()
               .ConfigureServices((context, services) =>
               {
                   services.AddTransient<MainForm>();
                   services.AddTransient<MainFormPresenter>();
                   services.AddTransient<IUserService, UserService>();
                   // ...
               })
               .Build();

           Application.ThreadException += (s, e) =>
           {
               // 全局 UI 线程异常处理
           };

           var mainForm = host.Services.GetRequiredService<MainForm>();
           Application.Run(mainForm);
       }
   }
   ```

## WinForms 特有约束

### MUST
1. 后台线程更新 UI 必须通过 `Control.InvokeAsync()` 或 `Control.BeginInvoke()` 回到 UI 线程。
2. `DataGridView` 大数据量必须启用虚拟模式（`VirtualMode = true`），禁止一次性绑定全量数据。
3. 长操作必须显示进度（`ProgressBar` 或状态栏文字），并支持取消。
4. Form 关闭时必须释放资源（取消异步操作、断开事件订阅）。
5. Designer 生成的 `.Designer.cs` 文件禁止手动编辑（除非修复设计器 Bug，需注释说明）。

### SHOULD
1. 复杂表单考虑使用 `UserControl` 拆分为独立可复用组件。
2. 使用 `BindingSource` + `INotifyPropertyChanged` 实现数据绑定（替代手动赋值）。
3. 考虑使用第三方 UI 库（DevExpress / Telerik / Syncfusion）提升界面质量和开发效率。

## 从 .NET Framework 迁移注意事项（SHOULD）
1. 迁移工具推荐 `.NET Upgrade Assistant`。
2. 迁移后必须替换 `packages.config` 为 `PackageReference`。
3. 迁移后检查 `Application.SetHighDpiMode(HighDpiMode.PerMonitorV2)` 高 DPI 适配。
4. 逐步引入 DI 和 MVP 架构，允许渐进式改造（不必一次性重构所有 Form）。
