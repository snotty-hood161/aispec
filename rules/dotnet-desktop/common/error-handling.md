# rules/dotnet-desktop/common/error-handling.md

## 异常分类
1. 异常必须区分业务异常（如数据校验失败、业务规则违反）与系统异常（如网络超时、文件系统错误、内存不足）。
2. 业务异常使用自定义异常类型，携带错误码和用户友好的消息。
3. 系统异常由全局异常处理器统一捕获，向用户展示通用错误提示，详细信息记录到日志。

## 全局异常处理（MUST）

1. 必须在应用启动阶段注册全局异常处理器，确保所有未捕获异常都能被记录和妥善处理。
2. 必须注册以下异常处理入口：
   - **UI 线程异常**：`Application.Current.DispatcherUnhandledException`（WPF）/ `Application.ThreadException`（WinForms）。
   - **非 UI 线程异常**：`AppDomain.CurrentDomain.UnhandledException`。
   - **Task 未观察异常**：`TaskScheduler.UnobservedTaskException`。
3. 全局异常处理器职责：
   - 记录完整异常信息到日志（堆栈、内部异常、上下文）。
   - 向用户展示友好的错误提示（禁止展示原始堆栈或技术细节）。
   - 判断异常严重程度：可恢复的继续运行，不可恢复的安全退出。
   - 触发崩溃报告上报（参见 `common/observability.md`）。

### WPF 全局异常处理示例
```csharp
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        // UI 线程异常
        DispatcherUnhandledException += (s, args) =>
        {
            _logger.LogError(args.Exception, "UI 线程未处理异常");
            ShowErrorDialog("应用遇到错误，请重试。");
            args.Handled = true; // 可恢复场景
        };

        // 非 UI 线程异常
        AppDomain.CurrentDomain.UnhandledException += (s, args) =>
        {
            var ex = args.ExceptionObject as Exception;
            _logger.LogCritical(ex, "非 UI 线程未处理异常，应用即将退出");
            // 不可恢复，记录后退出
        };

        // Task 异常
        TaskScheduler.UnobservedTaskException += (s, args) =>
        {
            _logger.LogError(args.Exception, "Task 未观察异常");
            args.SetObserved();
        };

        base.OnStartup(e);
    }
}
```

## 异常传播规则（MUST）

1. ViewModel 中的命令（Command）异常必须在命令执行器中捕获并处理，禁止异常逃逸到框架层。
2. Service 层异常向上传播时必须保留根因（`throw` 而非 `throw ex`）。
3. 远程 API 调用异常必须转换为业务可理解的异常或错误状态，禁止将 `HttpRequestException` 直接传递到 ViewModel。
4. 数据访问层异常必须包装并携带操作上下文（如"保存用户失败"），禁止将 SQLite/EF Core 原始异常直接暴露。

## 用户错误反馈（MUST）

1. 错误信息必须对用户友好，使用中文描述问题和建议操作（如"网络连接失败，请检查网络后重试"）。
2. 禁止向用户展示原始异常消息、堆栈跟踪或技术术语。
3. 可恢复错误（网络超时、文件占用）必须提供重试选项。
4. 不可恢复错误必须安全保存用户数据后提示重启。
5. 错误提示方式应统一：推荐使用应用内通知栏（Snackbar/InfoBar）处理非阻塞错误，对话框处理需要用户确认的严重错误。

## ViewModel 层错误状态管理（MUST）

1. ViewModel 必须暴露错误状态属性（如 `HasError`、`ErrorMessage`），View 通过数据绑定展示错误状态。
2. 推荐使用 `INotifyDataErrorInfo` 实现表单验证错误展示。
3. 异步操作的加载状态、成功状态、错误状态必须在 ViewModel 中明确建模，禁止仅依赖 try-catch 弹窗。
4. 示例：
   ```csharp
   public partial class UserListViewModel : ObservableObject
   {
       [ObservableProperty] private bool _isLoading;
       [ObservableProperty] private string? _errorMessage;
       [ObservableProperty] private ObservableCollection<UserDto> _users = new();

       [RelayCommand]
       private async Task LoadUsersAsync()
       {
           try
           {
               IsLoading = true;
               ErrorMessage = null;
               var users = await _userService.GetUsersAsync();
               Users = new ObservableCollection<UserDto>(users);
           }
           catch (BusinessException ex)
           {
               ErrorMessage = ex.Message;
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "加载用户列表失败");
               ErrorMessage = "加载失败，请重试";
           }
           finally
           {
               IsLoading = false;
           }
       }
   }
   ```
