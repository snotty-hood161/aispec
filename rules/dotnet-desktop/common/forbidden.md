# rules/dotnet-desktop/common/forbidden.md

## 禁止事项

### 架构与分层
1. 禁止在 Code-Behind 中编写业务逻辑（纯 UI 逻辑如动画触发、焦点管理除外）。
2. 禁止 ViewModel 直接引用或操作 UI 控件（`Window`、`Control`、`Page`、`MessageBox`）。
3. 禁止 ViewModel 直接实例化 View 或持有 View 引用。
4. 禁止 Service 层依赖 ViewModel 或 UI 框架类型。
5. 禁止 Controller/View 直接操作数据库或调用远程 API（必须经过 Service 层）。
6. 禁止在 ViewModel 中直接调用 `MessageBox.Show()`，必须通过 `IDialogService` 抽象。

### 线程与异步
7. 禁止在 UI 线程执行耗时操作（文件 I/O、网络请求、数据库查询、大量计算）。
8. 禁止在异步上下文中使用 `.Result`、`.Wait()`、`.GetAwaiter().GetResult()` 阻塞调用。
9. 禁止使用 `async void`（事件处理器除外）。
10. 禁止在后台线程直接修改 UI 控件或 `ObservableCollection`（必须通过 Dispatcher 回到 UI 线程）。
11. 禁止启动"fire-and-forget"后台任务（`_ = DoSomethingAsync()`），异常会被静默吞掉。

### 依赖注入
12. 禁止使用 Service Locator 模式（直接调用 `IServiceProvider.GetService`）替代构造函数注入。
13. 禁止在 ViewModel/Service 中直接 `new` 基础组件客户端（`new HttpClient()`、`new SqliteConnection()`）。
14. 禁止使用静态类/静态属性持有有状态组件实例。

### 数据与安全
15. 禁止将敏感数据（密码、令牌、密钥）以明文存储在配置文件或本地数据库中。
16. 禁止硬编码 API Key、加密密钥、服务端地址凭据在源码中。
17. 禁止将用户数据文件存储在程序安装目录（应存储在 `LocalApplicationData`）。
18. 禁止在生产版本中禁用 SSL 证书校验。

### 代码质量
19. 禁止将 `Console.WriteLine`、`Debug.WriteLine`、`Debugger.Break()` 等调试代码提交到主分支。
20. 禁止将用于调试的 `MessageBox.Show()` 提交到主分支。
21. 禁止在 XAML 中使用硬编码颜色/字体/间距魔法值（必须定义为资源）。
22. 禁止每次请求 `new HttpClient()`，必须通过 `IHttpClientFactory` 管理。

### 内存管理
23. 禁止事件订阅后不取消（必须在对象销毁时 `-=` 或使用弱事件）。
24. 禁止大图片以原始分辨率加载后缩放显示（必须设置 `DecodePixelWidth`/`DecodePixelHeight`）。
25. 禁止在循环中使用字符串拼接（`+=`），必须使用 `StringBuilder`。

### 发布
26. 禁止分发 Debug 版本到生产环境。
27. 禁止在 Dockerfile 或安装包脚本中硬编码敏感配置。
