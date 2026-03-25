# C#/.NET 服务端 PR 评审清单模板

## 文档目标
1. 用于 C#/.NET 服务端 PR 评审，评审人逐项核对，确保代码质量达标。
2. 默认适用 `common` 全量规则，评审前先标注架构类型。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 C#/.NET 服务端 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 前提
1. 评审前先标注架构类型：`monolith` 或 `microservice`（或混合）。
2. 每项必须给出结果：`[x]` 通过 / `[ ]` 不通过（需写阻塞原因）。
3. 如有例外，必须在 PR 说明中记录：原因、边界、回收时间。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。
3. 评审结论遵循：任一 `P0` 未通过则 `Request Changes`。

---

## PR 基本信息
- [ ] [P0] 已标注适用 profile：`monolith` / `microservice`
- [ ] [P0] 已说明变更目的、影响范围、回滚方案
- [ ] [P0] 已附关键测试结果与验证方式

## 架构与分层
- [ ] [P0] 依赖方向符合 `Controller/Endpoint -> Service -> Repository`，无反向依赖
- [ ] [P0] `Program.cs` 仅做组装，不包含业务逻辑
- [ ] [P0] Controller/Endpoint 未直接访问 DbContext/缓存客户端/对象存储客户端
- [ ] [P0] Service 未直接写 LINQ to SQL / EF Core 查询细节
- [ ] [P0] Repository 未承载业务状态机或流程编排
- [ ] [P0] Domain 层未依赖 Infrastructure 或 Api 层实现

## 组件初始化与生命周期
- [ ] [P0] 组件通过 DI 注入，未在 Controller/Service 直接构造客户端
- [ ] [P0] 无静态类持有有状态组件实例，无 Service Locator 模式
- [ ] [P0] 服务生命周期正确（无 Scoped 被 Singleton 捕获），已启用 `ValidateScopes` + `ValidateOnBuild`
- [ ] [P1] 日志最早阶段配置，初始化失败策略明确（fail-fast/降级）
- [ ] [P0] 提供并验证 `/healthz` 与 `/readyz`（关键依赖故障时不可就绪）

## 配置与环境
- [ ] [P0] 使用 `appsettings.json + appsettings.{Environment}.json` 分层配置
- [ ] [P0] 配置使用 Options Pattern + `ValidateOnStart`，启动校验失败快速退出
- [ ] [P1] 启动日志明确输出生效环境
- [ ] [P0] 数据库/Redis/MinIO 等参数全部配置化，无硬编码
- [ ] [P0] 数据库类型明确为 `mysql` 或 `postgresql`

## API 与契约
- [ ] [P0] API 版本化，契约（OpenAPI/Proto）已同步更新
- [ ] [P0] 响应结构统一：`code/message/data/requestId/timestamp`
- [ ] [P0] HTTP 状态码语义正确（非成功不返回统一 `200`）
- [ ] [P0] 错误响应文案可控，不泄露内部实现细节（无堆栈、SQL、内部路径）
- [ ] [P1] RequestId 注入、透传与日志关联已验证

## 鉴权与安全
- [ ] [P0] Admin 与 Client 认证方案独立，无同 Handler 分支混用
- [ ] [P0] JWT 配置（算法、密钥来源、过期策略）显式且无硬编码
- [ ] [P0] 高风险操作具备权限校验与审计日志
- [ ] [P0] 敏感信息未出现在日志/响应中
- [ ] [P0] 参数校验使用 FluentValidation/DataAnnotations，校验失败返回 400

## 数据访问与模型
- [ ] [P0] 常规 CRUD 使用领域实体 + Repository 模式
- [ ] [P0] 统计/报表查询使用投影 DTO
- [ ] [P0] 投影 DTO 未用于常规写入路径
- [ ] [P0] 查询使用 `.Select()` 投影，无等同 `SELECT *` 的全实体查询（只读场景）
- [ ] [P0] 全部参数化查询，无字符串拼接 SQL
- [ ] [P0] 事务边界在 Service 层，Repository 仅执行数据操作

## 异步编程与并发
- [ ] [P0] 全链路 async/await，无 `.Result` / `.Wait()` / `.GetAwaiter().GetResult()` 阻塞调用
- [ ] [P0] `CancellationToken` 全链路透传
- [ ] [P0] 无 `async void`（事件处理器除外）
- [ ] [P0] `HttpClient` 通过 `IHttpClientFactory` 管理，无每次请求 `new HttpClient()`
- [ ] [P0] `IDisposable` / `IAsyncDisposable` 对象正确释放

## 错误处理与可观测性
- [ ] [P0] 系统异常被记录，未原样返回给调用方
- [ ] [P0] 异常映射集中在统一中间件（`IExceptionHandler` 或自定义中间件），非散落式实现
- [ ] [P0] 重新抛出异常使用 `throw` 而非 `throw ex`
- [ ] [P1] 结构化日志（Serilog / NLog）、核心指标（QPS/错误率/P95/P99）与追踪可用
- [ ] [P1] 下游依赖成功率与耗时指标已覆盖

## 测试与发布门禁
- [ ] [P0] 通过 `dotnet build --warnaserrors` + `dotnet test` + Roslyn 分析器
- [ ] [P1] 新增代码覆盖率 >= 80%
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] 验证优雅停机：停接新流量、排空在途请求、超时强退
- [ ] [P0] 涉及 API/配置/数据库变更时文档已同步更新
- [ ] [P0] 无 `Console.WriteLine` 等调试代码残留

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
