# rules/node-server/common/component-initialization.md

## 目标
1. 统一 Node.js 服务端组件初始化方案，避免隐藏依赖、全局单例滥用和启动顺序漂移。
2. 覆盖常见基础组件：日志、数据库（Prisma/TypeORM）、Redis、对象存储（MinIO/OSS）、JWT、消息队列（BullMQ）。

---

## DI 总体策略（MUST）

1. NestJS 项目必须使用框架内建的依赖注入容器，所有依赖通过构造函数注入。
2. Express/Fastify 项目推荐使用 `tsyringe`、`inversify` 或手动构造函数注入，禁止隐式全局获取。
3. 组装根（Composition Root）必须位于应用入口（`main.ts` 或 `bootstrap.ts`）。
4. `main.ts` 仅负责：加载配置、构建应用实例、注册模块、启动服务、绑定优雅退出。
5. 禁止在业务模块中直接 `new` 基础设施客户端（如 `new PrismaClient()`、`new Redis()`），必须通过 DI 注入。

### SHOULD
1. NestJS 项目推荐使用 `@Global()` 模块封装基础设施（如 `DatabaseModule`、`CacheModule`），避免重复注册。
2. 推荐将基础设施组件封装为独立模块（`InfraModule`、`ConfigModule`），与业务模块解耦。

检查方式：代码审查 + 架构评审
阻断级别：阻断合并

---

## 初始化与生命周期（MUST）

1. 推荐初始化顺序：`config → logger → metrics/tracing → database → redis → object-storage → jwt → queue → service → controller`。
2. 组件初始化失败的默认策略是快速失败（fail fast）；可选组件需明确定义降级策略并记录日志。
3. NestJS 项目必须使用 `OnModuleInit`、`OnModuleDestroy`、`OnApplicationShutdown` 生命周期钩子管理资源。
4. Express/Fastify 项目必须在启动函数中按序初始化，并注册 `SIGTERM`/`SIGINT` 信号处理器。
5. 所有可关闭组件（数据库连接、Redis 连接、消息队列）必须在应用停机时按初始化逆序关闭。
6. 进程退出时必须有超时控制（推荐 10-30 秒），避免阻塞在资源回收阶段。

检查方式：代码审查
阻断级别：阻断合并

---

## 健康检查与就绪检查（MUST）

1. 服务必须提供存活探针与就绪探针（NestJS 推荐 `@nestjs/terminus`，其他框架手动实现 `/healthz` 和 `/readyz`）。
2. 存活探针仅反映进程可运行状态，不应依赖慢速外部依赖检查。
3. 就绪探针必须反映关键依赖可用性（数据库、Redis、关键消息队列）。
4. 非关键可选依赖故障时可继续就绪，但必须有降级标识和告警日志。
5. 探针结果必须可观测：失败原因应写入结构化日志并附带 `requestId`/`traceId`。

### SHOULD
1. 推荐就绪探针包含数据库 ping、Redis ping、消息队列连通性检查。
2. 推荐使用 `@nestjs/terminus` 的 `HealthIndicator` 抽象，统一健康检查实现模式。

检查方式：接口测试 + 部署验证
阻断级别：阻断部署

---

## 组件接口约束（MUST）

1. 每个基础设施模块至少提供：配置类型定义、工厂方法/Provider、关闭方法（如适用）、健康检查方法（如适用）。
2. 禁止在业务代码中直接构造第三方客户端，必须通过 Provider 或工厂函数注入。
3. 组件日志必须脱敏，禁止打印密钥、令牌、连接串完整内容。
4. 基础设施模块必须导出类型声明（interface 或 abstract class），业务层依赖抽象而非具体实现。

---

## 重点组件规则（MUST）

1. **数据库组件**：Prisma 必须通过 `PrismaService` 封装并注入，TypeORM 必须通过 `DataSource` 注入；禁止在业务代码中直接实例化。
2. **Redis 组件**：必须使用 `ioredis` 并配置超时、重试和连接池；禁止使用默认无限制配置。
3. **对象存储组件**：必须显式配置 endpoint、bucket、TLS 策略与超时。
4. **JWT 组件**：必须显式配置签名算法、密钥来源、过期策略，禁止硬编码密钥。
5. **日志组件**：必须优先初始化，保证后续组件初始化失败可被记录。
6. **消息队列组件**：BullMQ 必须通过 `@nestjs/bullmq` 或统一 Provider 注入，禁止在 service 中直接 `new Queue()`。

---

## 可测试性要求（MUST）

1. 使用方依赖接口（或注入 token）而非具体客户端类型，便于注入 mock 或 fake。
2. NestJS 测试必须使用 `Test.createTestingModule()` 构建测试模块，覆盖真实 Provider。
3. 禁止在测试中依赖全局可变单例状态或环境变量副作用。

---

## 禁止事项

1. 禁止在模块顶层作用域（文件级）建立数据库、Redis、MinIO 等外部连接。
2. 禁止通过全局变量暴露可变组件实例（如全局 `prisma`、全局 `redis`）。
3. 禁止在 controller/service 中直接 `new PrismaClient()`、`new Redis()`、`new S3Client()` 等。
4. 禁止在 NestJS Guard/Interceptor 中直接构造基础组件，必须通过 DI 注入。
