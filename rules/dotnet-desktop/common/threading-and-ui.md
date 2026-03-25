# rules/dotnet-desktop/common/threading-and-ui.md

## UI 线程模型（MUST）

1. UI 控件只能在 UI 线程（主线程 / Dispatcher 线程）上访问和修改，禁止在后台线程直接操作 UI。
2. 后台线程完成后需要更新 UI 时，必须通过 Dispatcher 回到 UI 线程：
   - WPF：`Application.Current.Dispatcher.InvokeAsync()` 或 `DispatcherQueue`。
   - MAUI：`MainThread.InvokeOnMainThreadAsync()`。
   - WinForms：`Control.InvokeAsync()` 或 `SynchronizationContext.Post()`。
3. 使用 MVVM 数据绑定时，绑定的属性变更通知（`INotifyPropertyChanged`）会自动 Marshal 到 UI 线程（WPF/MAUI），但 `ObservableCollection<T>` 的集合变更必须在 UI 线程执行。
4. 禁止在 UI 线程执行耗时操作（> 50ms），包括文件 I/O、网络请求、数据库查询、大量计算。

## 异步编程（MUST）

1. 所有 I/O 操作必须使用 `async/await`，禁止使用 `.Result`、`.Wait()`、`.GetAwaiter().GetResult()` 阻塞 UI 线程（会导致界面冻结甚至死锁）。
2. ViewModel 的 Command 必须支持异步执行（`IAsyncRelayCommand` / `AsyncRelayCommand`）。
3. 异步方法必须支持取消（`CancellationToken`），用户离开页面或取消操作时能立即响应。
4. 禁止使用 `async void`（事件处理器除外），所有异步方法必须返回 `Task` 或 `ValueTask`。
5. `Task.Run` 仅用于将 CPU 密集型工作卸载到线程池，禁止用于包装 I/O 操作。

### 异步命令示例（CommunityToolkit.Mvvm）
```csharp
[RelayCommand(IncludeCancelCommand = true)]
private async Task SaveAsync(CancellationToken cancellationToken)
{
    IsLoading = true;
    try
    {
        await _userService.SaveUserAsync(_currentUser, cancellationToken);
        _notificationService.ShowSuccess("保存成功");
    }
    catch (OperationCanceledException)
    {
        // 用户主动取消，忽略
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "保存用户失败");
        ErrorMessage = "保存失败，请重试";
    }
    finally
    {
        IsLoading = false;
    }
}
```

## 后台任务（MUST）

1. 长时间运行的后台任务必须在 UI 上展示进度（进度条或不确定进度指示器）。
2. 后台任务必须支持取消，用户关闭窗口或切换页面时应取消正在执行的任务。
3. 后台任务完成后更新 UI 必须回到 UI 线程。
4. 禁止启动"fire-and-forget"后台任务（`_ = DoSomethingAsync()`），异常会被静默吞掉。所有异步任务必须被 `await` 或通过 `UnobservedTaskException` 监控。
5. 需要在应用生命周期内持续运行的后台任务（如自动保存、心跳检测），使用 `IHostedService` / `BackgroundService`（搭配 Generic Host）。

## 并发控制（MUST）

1. 命令执行期间禁止重复触发（按钮防抖），`AsyncRelayCommand` 默认支持 `IsRunning` 属性自动禁用。
2. 并发写共享状态必须使用同步机制（`SemaphoreSlim` 用于异步锁，`lock` 仅用于同步代码）。
3. 避免在 `lock` 中执行 `await`（会阻塞线程池），应使用 `SemaphoreSlim` 替代。
4. `ObservableCollection<T>` 的修改必须在 UI 线程执行，若在后台线程需要批量更新集合，应收集结果后一次性回到 UI 线程更新。

## 应用生命周期（MUST）

1. 应用启动时必须有序初始化：配置 → 日志 → DI 容器 → 数据库迁移/检查 → 主窗口。
2. 应用关闭时必须有序清理：取消进行中的异步操作 → 保存未保存数据 → 释放资源 → 关闭日志。
3. 关闭确认：若有未保存的更改，必须提示用户确认（保存/放弃/取消）。
4. 异常关闭（崩溃）时必须尽力保存用户数据到临时文件，下次启动时尝试恢复。
