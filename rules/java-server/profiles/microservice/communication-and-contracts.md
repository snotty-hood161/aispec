# rules/java-server/profiles/microservice/communication-and-contracts.md

## 文档目标
1. 定义微服务间契约治理、通信协议选型、同步调用规范。
2. 异步通信参见 `messaging.md`；限流熔断参见 `resilience.md`；服务注册参见 `service-discovery.md`。

---

## 1. 契约治理（MUST）

1. 每个服务只维护一套对外契约源（OpenAPI 或 Proto），多调用方复用同一契约。
2. 契约必须版本化（如 `v1`、`v2`），破坏性变更必须升级大版本。
3. 契约变更发布前必须完成兼容性检查和消费方影响评估。
4. 禁止跨服务共享 JPA Entity、MyBatis Model 或数据库表结构对象。
5. 契约文件必须纳入版本控制，与服务代码同仓管理（`api/openapi/` 或 `api/proto/`）。
6. 契约变更必须附变更日志（CHANGELOG），说明新增、废弃、删除的字段和接口。

检查方式：人工审查 + 契约兼容性检查工具（如 `openapi-diff`、`buf breaking`）
阻断级别：阻断合并

---

## 2. 通信协议选型（MUST）

### 选型矩阵

| 场景 | 推荐协议 | Java 生态方案 |
|------|---------|-------------|
| 服务间内部同步调用 | **HTTP/JSON**（Spring Cloud） | OpenFeign / RestTemplate / WebClient |
| 高性能内部调用（跨语言） | **gRPC**（Proto3） | grpc-spring-boot-starter |
| 对外 API（面向前端/第三方） | **HTTP/JSON**（RESTful） | Spring MVC / WebFlux |
| 文件上传/下载 | **HTTP** | MultipartFile / StreamingResponseBody |

### MUST
1. 微服务间 HTTP 同步调用推荐使用 **OpenFeign**（声明式客户端），需要更高性能时使用 **gRPC**。
2. 对外 API（面向浏览器/小程序/第三方）使用 **HTTP/JSON（RESTful）**。
3. 同一服务可同时提供 gRPC 和 HTTP 端口，但两者必须共享同一套 `Service` 层，禁止 Controller/gRPC Handler 层存在逻辑分叉。
4. 协议选型必须在服务设计阶段确定并记录，禁止开发过程中随意切换。

### 多语言服务协作（MUST）
1. 跨语言服务间通信必须使用 **gRPC + Proto3** 作为统一协议，禁止依赖语言特定的序列化格式（如 Java `Serializable`、Go 的 `gob`）。
2. Proto 文件作为跨语言唯一契约源，由服务提供方维护。
3. Proto 文件推荐独立仓库管理，各服务通过 Maven/Gradle 插件生成代码。
4. 禁止手写跨语言客户端代码，必须通过 Proto 代码生成工具自动生成。

### SHOULD
1. 服务间 Feign 调用优先使用 HTTP/JSON；高频高性能场景考虑迁移到 gRPC。
2. Proto 文件使用 `buf` 工具链管理（lint、breaking change 检测、代码生成）。

检查方式：架构评审 + Proto lint
阻断级别：阻断合并

---

## 3. 同步调用规范（MUST）

1. 必须配置超时、重试、熔断、限流，且参数可配置。
2. Feign 超时配置必须显式声明（`connectTimeout`、`readTimeout`），禁止使用默认无限超时。
3. 重试必须幂等，非幂等接口（POST 写入）不得无条件重试。
4. 重试策略必须包含：最大重试次数（建议 ≤ 3）、退避策略（指数退避 + 随机抖动）、可重试状态码白名单。
5. Feign Client 必须配置降级（`fallback` / `fallbackFactory`），下游不可用时执行降级策略。
6. 服务间调用必须透传 trace 上下文（通过 `traceparent` Header）和请求标识（`requestId`）。Feign Interceptor 自动注入。
7. 下游不可用时必须有降级策略或显式失败策略，禁止无限等待。
8. 超时设置分层：全局默认 → 服务级 → 接口级，接口级优先。
9. 调用方必须处理所有 HTTP 状态码 / gRPC 状态码，禁止只处理成功和超时。

### 超时传播（MUST）
1. 上游传入的 deadline 必须向下游传播，禁止下游超时比上游更长。
2. 调用链每一跳必须预留处理时间。
3. 使用 `FeignRequestInterceptor` 或 `ClientHttpRequestInterceptor` 传播超时 Header。

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 4. 数据一致性策略（MUST）

1. 跨服务禁止依赖本地数据库事务保证一致性。
2. 优先使用最终一致性方案（事件驱动、补偿事务、Outbox）。
3. 必须明确写入顺序、重试语义、补偿边界与失败回滚策略。
4. Outbox 模式：业务写入与 Outbox 消息在同一本地事务中（`@Transactional`）；独立调度器轮询投递；消费方幂等。
5. Saga 模式：每个参与方提供正向+补偿操作；补偿必须幂等；必须定义超时和人工介入机制。

### SHOULD
1. 分布式事务框架推荐 Seata（AT/TCC 模式），仅在强一致性场景使用。
2. 优先 Saga/Outbox 模式而非 2PC/XA，降低耦合和性能损耗。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并
