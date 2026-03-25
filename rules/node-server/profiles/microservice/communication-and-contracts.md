# rules/node-server/profiles/microservice/communication-and-contracts.md

## Skill 协作
1. `$node-server-coding-guide` 在识别到微服务间通信、契约定义、gRPC/HTTP 调用场景时加载本规则。
2. `$task-router` 在跨服务通信任务中路由到本规则。

---

## 文档目标
1. 定义微服务间契约治理、通信协议选型、同步调用规范。
2. 异步通信参见 `messaging.md`；限流熔断参见 `resilience.md`；服务注册参见 `service-discovery.md`。

---

## 1. 契约治理（MUST）

1. 每个服务只维护一套对外契约源（OpenAPI 或 Proto），多调用方复用同一契约。
2. 契约必须版本化（如 `v1`、`v2`），破坏性变更必须升级大版本。
3. 契约变更发布前必须完成兼容性检查和消费方影响评估。
4. 禁止跨服务共享 ORM model（Prisma model / TypeORM entity）或数据库表结构对象。
5. 契约文件必须纳入版本控制，与服务代码同仓管理。
6. 契约变更必须附变更日志（CHANGELOG），说明新增、废弃、删除的字段和接口。
7. NestJS 服务的 Swagger 文档必须保持与代码同步，CI 中 SHOULD 校验 OpenAPI spec 无漂移。
8. 共享契约类型（DTO/Event）MUST 放在 `packages/shared-types` 中，禁止跨服务直接 import 对方的内部类型。

检查方式：人工审查 + 契约兼容性检查工具（如 `oasdiff`、`buf breaking`）
阻断级别：阻断合并

---

## 2. 通信协议选型（MUST）

### 选型矩阵

| 场景 | 推荐协议 | 原因 |
|------|---------|------|
| 服务间内部同步调用 | **gRPC**（Proto3） | 高性能、强类型、跨语言代码生成 |
| 对外 API（面向前端/第三方） | **HTTP/JSON**（RESTful） | 生态兼容性好、调试便捷 |
| 需要浏览器直接调用内部服务 | **HTTP 网关** 或 **gRPC-Web** | 浏览器不支持原生 gRPC |
| 文件上传/下载 | **HTTP** | gRPC 不适合大文件流式传输 |
| 服务间通信（NestJS 微服务模式） | **NestJS Transport**（TCP/Redis/NATS/RMQ） | 框架内置支持，开发效率高 |

### MUST
1. 微服务间内部通信推荐使用 **gRPC + Proto3**（推荐 `@grpc/grpc-js` + `@grpc/proto-loader` 或 NestJS `@nestjs/microservices` gRPC transport），或 **HTTP/JSON**（推荐 `axios` / `undici`）。
2. 对外 API（面向浏览器/小程序/第三方）使用 **HTTP/JSON（RESTful）**。
3. 同一服务可同时提供 gRPC 和 HTTP 端口，但两者必须共享同一套 `service` 层，禁止 transport 层存在逻辑分叉。
4. 协议选型必须在服务设计阶段确定并记录，禁止开发过程中随意切换。

### 多语言服务协作（MUST）
1. 跨语言服务间通信必须使用 **gRPC + Proto3** 作为统一协议，禁止依赖语言特定的序列化格式。
2. Proto 文件作为跨语言唯一契约源，由服务提供方维护，消费方通过代码生成获取客户端。
3. 禁止手写跨语言客户端代码，必须通过 Proto 代码生成工具自动生成。
4. Node.js gRPC 服务推荐使用 `@grpc/grpc-js` + `@grpc/proto-loader`，或 `ts-proto` 生成类型安全的 TypeScript 客户端。

### SHOULD
1. 服务间 HTTP 调用推荐使用 `axios`（拦截器丰富）或 `undici`（高性能），配合 DTO class 或 `zod` schema 进行响应校验。
2. Proto 文件使用 `buf` 工具链管理（lint、breaking change 检测、代码生成）。
3. NestJS 项目推荐使用 `@nestjs/swagger` 自动生成 OpenAPI 文档。

检查方式：架构评审 + Proto lint（`buf lint`）
阻断级别：阻断合并

---

## 3. 同步调用规范（MUST）

1. 必须配置超时、重试、熔断、限流，且参数可配置（熔断/限流细则参见 `resilience.md`）。
2. 重试必须幂等，非幂等接口不得无条件重试。
3. 重试策略必须包含：最大重试次数（建议 ≤ 3）、退避策略（指数退避 + 随机抖动）、可重试状态码白名单。
4. 服务间调用必须透传 trace 上下文（`traceparent` Header / gRPC metadata）和请求标识（`requestId`）。
5. 下游不可用时必须有降级策略或显式失败策略，禁止无限等待。
6. 超时设置分层：全局默认 → 服务级 → 接口级，接口级优先。
7. HTTP 客户端调用必须设置 `timeout`，禁止使用默认无超时。

### axios 重试与超时示例
```typescript
import axios, { AxiosInstance } from 'axios';
import axiosRetry from 'axios-retry';

const userServiceClient: AxiosInstance = axios.create({
  baseURL: 'http://user-svc:3000',
  timeout: 5000,
});

axiosRetry(userServiceClient, {
  retries: 3,
  retryDelay: axiosRetry.exponentialDelay,
  retryCondition: (error) =>
    axiosRetry.isNetworkOrIdempotentRequestError(error) ||
    error.response?.status === 503,
});

async function getUser(userId: string): Promise<UserDto> {
  const { data } = await userServiceClient.get(`/api/v1/users/${userId}`);
  return data;
}
```

### 超时传播（MUST）
1. 上游传入的 deadline 必须向下游传播，禁止下游超时比上游更长。
2. 调用链每一跳必须预留处理时间。

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 4. 数据一致性策略（MUST）

1. 跨服务禁止依赖本地数据库事务保证一致性。
2. 优先使用最终一致性方案（事件驱动、补偿事务、Outbox）。
3. 必须明确写入顺序、重试语义、补偿边界与失败回滚策略。
4. Outbox 模式：业务写入与 Outbox 消息在同一本地事务中；独立调度器轮询投递；消费方幂等。
5. Saga 模式：每个参与方提供正向+补偿操作；补偿必须幂等；必须定义超时和人工介入机制。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并
