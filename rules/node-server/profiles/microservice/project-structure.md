# rules/node-server/profiles/microservice/project-structure.md

## 适用场景
1. 基于 NestJS 微服务架构的分布式系统，每个服务独立部署、独立数据库。
2. 服务间通过 HTTP/gRPC/消息队列通信，采用 API Gateway 统一入口。

---

## 单个微服务目录结构

```text
services/user-service/
├── src/
│   ├── main.ts                            # 微服务入口
│   ├── app.module.ts                      # 根模块
│   ├── common/                            # 服务内共享能力
│   │   ├── decorators/
│   │   ├── filters/
│   │   │   └── global-exception.filter.ts
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── middleware/
│   │   ├── constants/
│   │   │   ├── error-codes.ts
│   │   │   └── cache-keys.ts
│   │   └── interfaces/
│   │       ├── api-response.interface.ts
│   │       └── service-response.interface.ts
│   ├── config/
│   │   ├── app.config.ts
│   │   ├── database.config.ts
│   │   ├── redis.config.ts
│   │   ├── grpc.config.ts                 # gRPC 连接配置
│   │   └── env.validation.ts
│   ├── infra/
│   │   ├── database/
│   │   │   ├── database.module.ts
│   │   │   └── prisma.service.ts
│   │   ├── cache/
│   │   │   └── cache.module.ts
│   │   ├── queue/
│   │   │   └── queue.module.ts
│   │   ├── logger/
│   │   │   └── logger.module.ts
│   │   ├── health/
│   │   │   ├── health.module.ts
│   │   │   └── health.controller.ts
│   │   └── clients/                       # 其他微服务客户端
│   │       ├── order-client.module.ts
│   │       └── order-client.service.ts    # 封装调用 order-service 的逻辑
│   ├── modules/
│   │   └── user/
│   │       ├── user.module.ts
│   │       ├── user.controller.ts         # HTTP 端点
│   │       ├── user.grpc.controller.ts    # gRPC 端点（如使用 gRPC）
│   │       ├── user.service.ts
│   │       ├── user.repository.ts
│   │       ├── dto/
│   │       ├── entities/
│   │       ├── errors/
│   │       ├── events/                    # 领域事件定义
│   │       │   └── user-created.event.ts
│   │       └── processors/
│   └── proto/                             # gRPC Proto 文件（或从共享仓库引用）
│       └── user.proto
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── test/
├── configs/
├── Dockerfile
├── tsconfig.json
├── package.json
└── pnpm-lock.yaml
```

---

## Monorepo 整体结构（推荐）

```text
.
├── apps/                                  # 各微服务
│   ├── api-gateway/                       # API 网关
│   │   ├── src/
│   │   │   ├── main.ts
│   │   │   ├── app.module.ts
│   │   │   └── routes/                    # 路由转发配置
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── user-service/                      # 用户服务
│   │   └── (同上述单个微服务结构)
│   ├── order-service/                     # 订单服务
│   └── notification-service/             # 通知服务
├── packages/                              # 共享包
│   ├── shared-types/                      # 共享类型定义
│   │   ├── src/
│   │   │   ├── dto/                       # 服务间通信 DTO
│   │   │   ├── events/                    # 共享事件定义
│   │   │   └── interfaces/               # 共享接口
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── shared-utils/                      # 共享工具函数
│   │   └── package.json
│   └── proto/                             # 共享 Proto 文件
│       ├── user.proto
│       └── order.proto
├── docker-compose.yml                     # 本地开发编排
├── pnpm-workspace.yaml
├── turbo.json                             # Turborepo 配置（推荐）
├── tsconfig.base.json
└── package.json
```

---

## 服务边界规则（MUST）

1. 每个微服务拥有独立的数据库，禁止跨服务直接访问其他服务的数据库。
2. 服务间通信必须通过明确的接口（HTTP API / gRPC / 消息队列），禁止共享数据库表或内存状态。
3. 每个服务必须独立部署、独立版本管理，一个服务的发布不应要求其他服务同步发布。
4. 共享类型/DTO 必须放在 `packages/shared-types` 中，禁止跨服务直接 import 对方的内部类型。
5. 服务间调用的 DTO 必须与内部 DTO 分离，使用独立的 `ServiceRequestDto` / `ServiceResponseDto`。

### SHOULD
1. 推荐使用 gRPC 进行服务间同步通信（低延迟、强类型）。
2. 推荐使用消息队列（BullMQ/RabbitMQ/Kafka）进行服务间异步通信和事件驱动。
3. 推荐采用最终一致性（Saga/事件驱动）替代分布式事务。

---

## API Gateway 规则（MUST）

1. API Gateway 负责：路由转发、认证鉴权、限流、请求日志、协议转换。
2. API Gateway 禁止承载业务逻辑，仅做请求路由和横切关注点处理。
3. API Gateway 必须实现统一的错误格式转换，将下游服务错误映射为标准响应结构。
4. API Gateway 必须配置超时和熔断，防止下游服务故障拖垮网关。
5. API Gateway 推荐使用 NestJS + `@nestjs/microservices` 或独立网关（Kong/APISIX）。

---

## 服务间通信规则（MUST）

1. 同步调用（HTTP/gRPC）必须设置超时（推荐 5-10 秒），禁止无限等待。
2. 同步调用必须实现重试策略（推荐 3 次指数退避），但必须确保被调用方幂等。
3. 必须实现熔断器（Circuit Breaker），下游服务连续失败超过阈值后熔断，返回降级响应。
4. 异步消息（事件/命令）必须定义明确的 Schema 和版本，在 `packages/shared-types/events` 中集中管理。
5. 消息消费者必须实现幂等性，同一消息重复消费不产生副作用。
6. 服务调用必须传播追踪上下文（traceId/spanId），确保分布式链路完整。

### SHOULD
1. 推荐使用 `@nestjs/microservices` 的 `ClientProxy` 封装服务间调用。
2. 推荐为关键链路实现 Fallback 降级策略。

---

## 服务客户端封装规则（MUST）

1. 调用其他微服务必须通过独立的 Client Module 封装（如 `infra/clients/order-client.module.ts`），禁止在业务 service 中直接构造 HTTP/gRPC 客户端。
2. Client Service 必须封装重试、超时、错误转换逻辑，对业务层暴露语义化方法。
3. Client Module 必须支持配置化（目标服务地址、超时、重试次数从配置加载）。
4. 服务端返回的错误必须在 Client Service 中转换为本服务的异常类型，禁止透传原始错误。

---

## 数据一致性规则（MUST）

1. 跨服务数据一致性推荐使用 Saga 模式（编排式或协调式），禁止使用分布式事务（2PC）。
2. Saga 步骤必须设计补偿操作（rollback），步骤失败时执行反向补偿。
3. 事件驱动架构中，事件发布必须与本地数据库事务绑定（Transactional Outbox 模式），禁止事务提交后再发事件（可能丢失）。
4. 消息投递必须至少一次（at-least-once），消费者必须实现幂等。

### SHOULD
1. 推荐使用 Outbox 模式：将事件写入本地数据库 `outbox` 表，由独立进程/任务轮询发送。
2. 推荐为关键业务流程（如下单→支付→发货）建立 Saga 状态机。

---

## 部署与容器化规则（MUST）

1. 每个微服务必须有独立的 `Dockerfile`，采用多阶段构建（build → production）。
2. Docker 镜像必须使用 `node:xx-alpine` 精简基础镜像，仅包含生产依赖。
3. 必须配置健康检查（`HEALTHCHECK` 指令或 K8s Probe）。
4. 必须设置资源限制（CPU、内存），避免单个服务耗尽集群资源。
5. 日志必须输出到 stdout/stderr，由容器运行时收集。

### SHOULD
1. 推荐使用 `docker-compose.yml` 编排本地开发环境（含数据库、Redis、消息队列）。
2. 推荐使用 Helm Chart 管理 K8s 部署配置。

---

## 额外约束

1. Monorepo 管理推荐使用 `pnpm workspace` + `Turborepo`，确保构建缓存和任务并行。
2. 共享包版本变更必须遵循语义化版本，破坏性变更需协调所有消费方升级。
3. 本地开发必须能通过一条命令启动所有依赖服务（`docker-compose up` + `pnpm dev`）。
