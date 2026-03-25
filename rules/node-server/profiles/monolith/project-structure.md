# rules/node-server/profiles/monolith/project-structure.md

## 适用场景
1. 单进程部署的 NestJS 应用，含管理后台 API、业务 API、任务调度等。
2. 默认采用"模块化单体（Modular Monolith）"而非脚手架式平铺目录。

---

## 推荐目录结构

```text
.
├── src/
│   ├── main.ts                            # 应用入口：仅启动和依赖组装
│   ├── app.module.ts                      # 根模块：导入所有业务模块和基础设施模块
│   ├── common/                            # 跨模块共享能力（无业务语义）
│   │   ├── decorators/                    # 自定义装饰器（CurrentUser、Roles 等）
│   │   ├── filters/                       # 全局异常过滤器
│   │   │   └── global-exception.filter.ts
│   │   ├── guards/                        # 通用守卫（JwtAuthGuard、RolesGuard）
│   │   ├── interceptors/                  # 通用拦截器（响应包装、日志、超时）
│   │   │   ├── response-transform.interceptor.ts
│   │   │   └── logging.interceptor.ts
│   │   ├── pipes/                         # 通用管道（ValidationPipe 配置）
│   │   ├── middleware/                    # 通用中间件（RequestId、Helmet）
│   │   ├── constants/                     # 全局常量、缓存键、错误码
│   │   │   ├── error-codes.ts
│   │   │   └── cache-keys.ts
│   │   ├── interfaces/                    # 通用类型定义
│   │   │   ├── api-response.interface.ts
│   │   │   └── pagination.interface.ts
│   │   └── utils/                         # 纯工具函数（日期格式化、加密辅助等）
│   ├── config/                            # 配置定义
│   │   ├── app.config.ts                  # 应用配置命名空间
│   │   ├── database.config.ts             # 数据库配置命名空间
│   │   ├── redis.config.ts                # Redis 配置命名空间
│   │   ├── jwt.config.ts                  # JWT 配置命名空间
│   │   └── env.validation.ts             # 环境变量 Schema 校验
│   ├── infra/                             # 基础设施模块
│   │   ├── database/                      # 数据库模块
│   │   │   ├── database.module.ts
│   │   │   └── prisma.service.ts          # PrismaClient 封装
│   │   ├── cache/                         # 缓存模块
│   │   │   ├── cache.module.ts
│   │   │   └── redis.service.ts           # ioredis 封装
│   │   ├── storage/                       # 对象存储模块
│   │   │   ├── storage.module.ts
│   │   │   └── storage.service.ts
│   │   ├── queue/                         # 消息队列模块
│   │   │   └── queue.module.ts
│   │   ├── logger/                        # 日志模块
│   │   │   └── logger.module.ts
│   │   └── health/                        # 健康检查模块
│   │       ├── health.module.ts
│   │       └── health.controller.ts
│   └── modules/                           # 业务模块（按业务域划分）
│       ├── user/
│       │   ├── user.module.ts             # 模块定义
│       │   ├── user.controller.ts         # 路由与请求处理
│       │   ├── user.service.ts            # 业务逻辑编排
│       │   ├── user.repository.ts         # 数据访问封装
│       │   ├── dto/                       # 请求/响应 DTO
│       │   │   ├── create-user.dto.ts
│       │   │   ├── update-user.dto.ts
│       │   │   └── user-response.dto.ts
│       │   ├── entities/                  # 数据库实体（Prisma Schema 或 TypeORM Entity）
│       │   │   └── user.entity.ts
│       │   ├── errors/                    # 模块业务异常
│       │   │   └── user.errors.ts
│       │   └── guards/                    # 模块专属守卫（如有）
│       └── order/
│           ├── order.module.ts
│           ├── order.controller.ts
│           ├── order.service.ts
│           ├── order.repository.ts
│           ├── dto/
│           ├── entities/
│           ├── errors/
│           │   └── order.errors.ts
│           └── processors/               # BullMQ 任务处理器
│               └── order-notification.processor.ts
├── prisma/                                # Prisma Schema 和迁移
│   ├── schema.prisma
│   └── migrations/
├── test/                                  # 端到端测试
│   ├── app.e2e-spec.ts
│   └── jest-e2e.json
├── configs/                               # 环境配置文件
│   ├── .env.example
│   ├── .env.development
│   └── .env.staging
├── scripts/                               # 脚本工具
├── docs/                                  # 项目文档
│   └── api/                              # OpenAPI 导出
├── tsconfig.json
├── tsconfig.build.json
├── package.json
├── pnpm-lock.yaml
├── .eslintrc.js
├── .prettierrc
├── .editorconfig
└── .gitignore
```

---

## 模块边界规则（MUST）

1. 模块内依赖只允许 `controller → service → repository`，禁止反向依赖。
2. `entities` 不反向依赖外层实现细节。
3. 模块之间禁止直接调用对方 `repository`，必须通过 `service` 接口。
4. 跨模块协作通过导入对方 `Module` 并注入对方 `Service` 实现，禁止直接导入对方内部文件。
5. `modules/<module>/errors` 是私有业务异常，不用于跨服务共享。

### SHOULD
1. 推荐模块间通信优先使用事件（EventEmitter2 或 BullMQ），减少直接依赖。
2. 推荐大模块内部进一步按子域拆分子目录。

---

## 基础设施组织规则（MUST）

1. `infra/` 只放基础设施模块封装，禁止承载业务逻辑。
2. 每个基础设施能力封装为独立 NestJS Module（如 `DatabaseModule`、`CacheModule`、`StorageModule`）。
3. 基础设施模块使用 `@Global()` 或在 `AppModule` 中全局导入，业务模块无需重复导入。
4. 基础设施模块必须导出 Service（如 `PrismaService`、`RedisService`），业务模块通过 DI 注入。

---

## 通用能力组织规则（MUST）

1. `common/` 只放跨模块可复用的技术能力，禁止放入业务实体或业务逻辑。
2. 全局 Filter、Guard、Interceptor、Pipe 放在 `common/` 对应目录。
3. 业务模块专属的 Guard、Interceptor 放在模块目录内部（如 `modules/user/guards/`）。
4. 常量和枚举按职责拆分文件（`error-codes.ts`、`cache-keys.ts`），禁止所有常量放入 `constants.ts` 一个文件。
5. `common/utils/` 仅放纯函数工具，禁止放入有状态或依赖 DI 的代码。

---

## 配置组织规则（MUST）

1. 配置按领域拆分为独立文件（`app.config.ts`、`database.config.ts` 等），使用 `@nestjs/config` 的 `registerAs` 注册命名空间。
2. 环境变量校验逻辑放在 `config/env.validation.ts`，启动时校验并快速失败。
3. `.env` 文件放在项目根目录的 `configs/` 目录下，`.env.example` 必须纳入版本控制。

---

## 测试组织规则（MUST）

1. 单元测试与被测文件放在同目录，使用 `*.spec.ts` 后缀。
2. 端到端测试放在项目根目录的 `test/` 目录。
3. 测试夹具和工厂放在 `test/fixtures/` 或 `test/factories/`。

---

## 额外约束

1. `main.ts` 只做应用创建、全局配置（Helmet/CORS/ValidationPipe/Swagger）和启动，不写业务判断。
2. 系统错误必须由全局 `ExceptionFilter` 统一映射为业务错误响应，禁止直接返回原始错误。
3. 新增模块必须创建独立的 `*.module.ts` 并在 `AppModule` 中导入注册。
