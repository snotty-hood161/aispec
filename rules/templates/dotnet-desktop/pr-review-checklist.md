# C#/.NET 桌面应用 PR 评审清单模板

## 文档目标
1. 用于 C#/.NET 桌面应用 PR 评审，评审人逐项核对，确保代码质量达标。
2. 默认适用 `common` 全量规则，评审前先标注框架类型。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 C#/.NET 桌面应用 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 前提
1. 评审前先标注框架类型：`wpf` / `maui` / `winforms`。
2. 每项必须给出结果：`[x]` 通过 / `[ ]` 不通过（需写阻塞原因）。
3. 如有例外，必须在 PR 说明中记录：原因、边界、回收时间。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。
3. 评审结论遵循：任一 `P0` 未通过则 `Request Changes`。

---

## PR 基本信息
- [ ] [P0] 已标注适用框架：`wpf` / `maui` / `winforms`
- [ ] [P0] 已说明变更目的、影响范围、测试结果
- [ ] [P0] 已附关键场景测试结果（含截图如涉及 UI 变更）

## 架构与分层
- [ ] [P0] 依赖方向符合 `View → ViewModel/Presenter → Service → Repository`，无反向依赖
- [ ] [P0] Code-Behind / Form 中无业务逻辑（仅纯 UI 逻辑）
- [ ] [P0] ViewModel/Presenter 未引用 UI 框架类型（`Window`、`Control`、`Page`、`Form`）
- [ ] [P0] Service 层未依赖 ViewModel/Presenter 或 UI 框架
- [ ] [P0] 对话框、文件选择等 UI 交互通过接口抽象（`IDialogService` 等）

## 依赖注入
- [ ] [P0] 组件通过 DI 注入，未在 ViewModel/Presenter 中直接 `new` 基础组件
- [ ] [P0] 无静态类持有有状态组件实例
- [ ] [P0] 无 Service Locator 模式（`IServiceProvider.GetService` 直接调用）
- [ ] [P0] ViewModel/Form 未直接 `new` 其他 ViewModel/Form

## 线程与异步
- [ ] [P0] 全链路 async/await，无 `.Result` / `.Wait()` 阻塞调用
- [ ] [P0] UI 线程无耗时操作（文件 I/O、网络请求、数据库查询）
- [ ] [P0] 后台线程更新 UI 通过 Dispatcher / MainThread 回到 UI 线程
- [ ] [P0] `CancellationToken` 正确传递，页面离开/窗口关闭时取消进行中的操作
- [ ] [P0] 无 `async void`（事件处理器除外）
- [ ] [P0] 无 fire-and-forget 后台任务

## 错误处理
- [ ] [P0] 全局异常处理器已注册（UI 线程 + 非 UI 线程 + Task 异常）
- [ ] [P0] 异常未原样展示给用户（无堆栈、SQL、内部路径泄露）
- [ ] [P0] ViewModel 暴露错误状态属性（`HasError`/`ErrorMessage`），View 通过绑定展示
- [ ] [P0] 重新抛出异常使用 `throw` 而非 `throw ex`
- [ ] [P1] 可恢复错误提供重试选项

## 数据访问
- [ ] [P0] 数据库操作在后台线程执行（async）
- [ ] [P0] `HttpClient` 通过 `IHttpClientFactory` 管理，无每次请求 `new HttpClient()`
- [ ] [P0] API 调用配置了超时和重试策略
- [ ] [P0] 本地数据库文件存储在用户数据目录，非程序安装目录

## 安全
- [ ] [P0] 敏感数据未以明文存储在本地文件中
- [ ] [P0] 凭据使用系统安全存储（PasswordVault / DPAPI / SecureStorage）
- [ ] [P0] 日志和错误提示中无敏感信息
- [ ] [P0] API 通信使用 HTTPS，无 SSL 证书校验绕过
- [ ] [P0] 应用未请求不必要的管理员权限

## 配置与设置
- [ ] [P0] 应用配置使用 Options Pattern，无直接读取 `IConfiguration` 键值
- [ ] [P0] 用户设置持久化到用户数据目录，设置文件损坏时回退默认值不崩溃
- [ ] [P0] 无硬编码 API 地址、密钥、凭据

## 内存与性能
- [ ] [P0] 事件订阅在对象销毁时取消（`-=` 或弱事件）
- [ ] [P0] `IDisposable` 对象正确释放
- [ ] [P0] 长列表使用虚拟化，大数据集分页/增量加载
- [ ] [P1] 大图片设置 `DecodePixelWidth`/`DecodePixelHeight`
- [ ] [P1] 应用冷启动 <= 3 秒可见主窗口

## 可观测性
- [ ] [P0] 使用 `ILogger<T>` 结构化日志，无 `Console.WriteLine` 调试代码
- [ ] [P0] 日志文件配置滚动策略，写入用户数据目录
- [ ] [P1] 崩溃报告收集机制可用

## 测试
- [ ] [P0] 通过 `dotnet build --warnaserrors` + `dotnet test`
- [ ] [P0] ViewModel/Presenter 关键命令和状态变更有单元测试
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] API 客户端有 Mock HTTP 集成测试
- [ ] [P0] 无 `Console.WriteLine`、`Debugger.Break()`、调试用 `MessageBox.Show` 残留

## XAML 质量（WPF/MAUI）
- [ ] [P0] 无硬编码颜色/字体/间距魔法值（已定义为资源）
- [ ] [P1] 样式和模板定义在资源字典中，无内联重复定义
- [ ] [P1] 用户可见字符串提取到资源文件

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
