# rules/dotnet-server/profiles/microservice/project-structure.md

## 适用场景
1. 独立部署、独立伸缩、独立发布的 .NET 微服务。
2. 每个服务仓库或每个服务目录都应作为独立可交付单元。

## 推荐解决方案结构
```text
OrderService/
├── src/
│   ├── OrderService.Api/                       # Web API / gRPC 启动项目
│   │   ├── Program.cs                          # 仅启动、DI 注册和中间件管道
│   │   ├── appsettings.json
│   │   ├── appsettings.Development.json
│   │   ├── appsettings.Production.json
│   │   ├── Controllers/                        # HTTP Controller / Minimal API
│   │   │   └── OrderController.cs
│   │   ├── GrpcServices/                       # gRPC 服务（可选）
│   │   │   └── OrderGrpcService.cs
│   │   ├── Consumers/                          # 消息消费者（可选，或独立 Worker 项目）
│   │   │   └── OrderEventConsumer.cs
│   │   ├── Middlewares/
│   │   │   ├── GlobalExceptionHandler.cs
│   │   │   └── RequestIdMiddleware.cs
│   │   ├── Auth/
│   │   │   ├── AdminAuthHandler.cs
│   │   │   └── ClientAuthHandler.cs
│   │   └── Dto/
│   │       ├── Requests/
│   │       └── Responses/
│   │           └── ApiResponse.cs
│   │
│   ├── OrderService.Application/               # 应用服务层
│   │   ├── IOrderService.cs
│   │   ├── OrderService.cs
│   │   └── Validators/
│   │       └── CreateOrderValidator.cs
│   │
│   ├── OrderService.Domain/                    # 领域层
│   │   ├── Entities/
│   │   │   └── Order.cs
│   │   ├── Events/                             # 领域事件
│   │   │   └── OrderCreatedEvent.cs
│   │   ├── Exceptions/
│   │   │   ├── BusinessException.cs
│   │   │   └── OrderException.cs
│   │   ├── ErrorCodes/
│   │   │   └── OrderErrorCodes.cs
│   │   └── Interfaces/
│   │       └── IOrderRepository.cs
│   │
│   ├── OrderService.Infrastructure/            # 基础设施层
│   │   ├── Data/
│   │   │   ├── OrderDbContext.cs
│   │   │   ├── Configurations/
│   │   │   │   └── OrderConfiguration.cs
│   │   │   ├── Repositories/
│   │   │   │   └── OrderRepository.cs
│   │   │   ├── Queries/
│   │   │   │   └── OrderStatDto.cs
│   │   │   └── Migrations/
│   │   ├── Caching/
│   │   │   ├── CacheKeys.cs
│   │   │   └── RedisCacheService.cs
│   │   ├── Clients/                            # 外部服务客户端
│   │   │   └── UserServiceClient.cs            # 调用 UserService 的客户端
│   │   ├── Messaging/                          # 消息发布
│   │   │   └── OrderEventPublisher.cs
│   │   └── Extensions/
│   │       ├── DatabaseExtensions.cs
│   │       ├── RedisExtensions.cs
│   │       ├── MessagingExtensions.cs
│   │       └── HealthCheckExtensions.cs
│   │
│   └── OrderService.Shared/                    # 跨层共享（仅技术组件）
│       └── Options/
│           ├── DatabaseOptions.cs
│           └── RedisOptions.cs
│
├── protos/                                     # gRPC 契约源（proto3）
│   └── order/
│       └── v1/
│           └── order.proto
│
├── tests/
│   ├── OrderService.UnitTests/
│   ├── OrderService.IntegrationTests/
│   └── OrderService.Api.Tests/
│
├── docs/
│   └── api/
├── scripts/
├── Dockerfile
├── Directory.Build.props
├── Directory.Packages.props
└── OrderService.sln
```

## 边界与依赖
1. `Domain` 层仅服务内部使用，禁止被其他服务直接引用。
2. 对外通信契约统一放 `protos/`（gRPC）或通过 OpenAPI 文档暴露。
3. 其他服务只能依赖契约与生成代码，不能依赖本服务内部 Entity 或 DTO。
4. `Program.cs` 只做装配，不承载业务逻辑。

## 服务间通信
1. 同步调用推荐 gRPC（内部）或 HTTP（对外），使用类型化 `HttpClient`（`IHttpClientFactory`）或 gRPC Client。
2. 异步通信推荐消息队列（RabbitMQ / Kafka / Azure Service Bus），消息体使用版本化 DTO。
3. 外部服务客户端封装在 `Infrastructure/Clients/`，业务代码通过接口调用。
4. 服务间调用必须配置超时、重试和熔断（推荐 Polly）。

## 认证中间件组织规则
1. 不同作用域的认证处理器必须独立实现，禁止混合处理。
2. 服务间认证（如 mTLS / API Key / JWT 服务令牌）独立于用户认证配置。

## 错误组织规则
1. 业务异常放在 `Domain/Exceptions/`，错误码放在 `Domain/ErrorCodes/`。
2. 统一异常处理中间件在 `Api/Middlewares/`。

## 数据模型组织规则
1. 领域实体放在 `Domain/Entities/`。
2. 实体配置放在 `Infrastructure/Data/Configurations/`。
3. 投影 DTO 放在 `Infrastructure/Data/Queries/`。
4. 每个服务有独立的 `DbContext`，禁止跨服务共享数据库。

## 组件初始化规则
1. 各基础组件注册封装为独立扩展方法。
2. 消息队列客户端注册和配置放在 `Infrastructure/Extensions/MessagingExtensions.cs`。
3. 外部服务客户端使用 `IHttpClientFactory` + Polly 配置弹性策略。
4. 初始化顺序在 `Program.cs` 中可读可验证。

## 容器化约束
1. Dockerfile 必须使用多阶段构建，最终镜像基于 `mcr.microsoft.com/dotnet/aspnet` 运行时镜像。
2. 必须配置健康检查（`HEALTHCHECK` 指令或 Kubernetes 探针）。
3. 必须配置资源限制（CPU / 内存），容器内存限制应与 `GCHeapHardLimit` 配合。
4. 禁止在 Dockerfile 中硬编码配置或密钥。
