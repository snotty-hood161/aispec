# rules/dotnet-server/common/forbidden.md

## 禁止事项
1. 禁止在 Controller/Endpoint 中直接操作 `DbContext`。
2. 禁止吞异常（空 `catch` 块），除显式注释说明的可忽略场景。
3. 禁止新增无上限缓存（`IMemoryCache` 未设 `SizeLimit`）、无上限队列或无超时外部调用。
4. 禁止未评审的破坏性接口变更和数据库结构变更。
5. 禁止将业务实体放入通用共享类库后被跨服务直接复用。
6. 禁止将系统异常（数据库驱动异常、RPC 原始异常、未处理异常堆栈）原样返回给调用方。
7. 禁止在多个 Controller 中分散实现异常到响应的映射逻辑，必须走统一异常处理中间件。
8. 禁止在共享类库中定义带业务语义的异常（如 `UserException`、`OrderException`）。
9. 禁止硬编码数据库、Redis、MinIO 等外部依赖地址和凭据。
10. 禁止在 CORS 中间件中硬编码域名白名单。
11. 禁止将统计分析投影 DTO 用于常规 CRUD 查询与写入。
12. 禁止使用静态类/静态属性持有 `DbContext`、Redis 连接等有状态组件实例。
13. 禁止使用 Service Locator 模式（直接调用 `IServiceProvider.GetService`）替代构造函数注入。
14. 禁止在 Controller/Service 内直接构造基础组件客户端（`new DbContext()`、`new HttpClient()`），必须通过 DI 注入。
15. 禁止对失败请求统一返回 `200` 并仅依赖响应体业务 `code` 区分错误。
16. 禁止在异步上下文中使用 `.Result`、`.Wait()`、`.GetAwaiter().GetResult()` 阻塞调用。
17. 禁止使用 `async void`（事件处理器除外）。
18. 禁止每次请求 `new HttpClient()`，必须通过 `IHttpClientFactory` 管理。
19. 禁止将 `Console.WriteLine` 等调试打印提交到主分支。
20. 禁止在 `IQueryable` 上执行 `ToList()` 后再进行内存过滤（应在数据库端完成过滤）。
