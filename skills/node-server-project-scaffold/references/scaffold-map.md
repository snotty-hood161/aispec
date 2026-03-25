# 脚手架映射表（部署模式 → 规则与模板文件）

本文件定义每种部署模式初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认部署模式后，按下表加载对应文件。
2. "通用必读"对所有模式生效。
3. "专项文件"仅对特定模式生效。

---

## 一、通用必读（所有部署模式）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/node-server/common/baseline.md` | Node.js 版本、模块管理、TypeScript 要求 |
| `rules/node-server/common/code-style.md` | 命名、注释、分层编码 |
| `rules/node-server/common/component-initialization.md` | 依赖注入、生命周期、健康检查 |
| `rules/node-server/common/configuration.md` | 配置文件组织、环境变量 |
| `rules/node-server/common/error-handling.md` | 异常分类与传播 |
| `rules/node-server/common/security.md` | 输入校验、鉴权基线 |
| `rules/node-server/common/observability.md` | 结构化日志、指标 |
| `rules/node-server/common/testing-and-release.md` | 测试要求与质量门禁 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/node-server/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、monolith 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/node-server/profiles/monolith/project-structure.md` | 单体应用目录结构与模块边界 |

### 技术栈
- 运行时：Node.js ≥ 18 LTS
- 语言：TypeScript（strict 模式）
- 框架：NestJS / Express / Fastify
- ORM：TypeORM / Prisma / Knex
- 配置：@nestjs/config / dotenv + joi
- 日志：winston / pino

---

## 三、microservice 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/node-server/profiles/microservice/project-structure.md` | 微服务目录结构 |
| `rules/node-server/profiles/microservice/communication-and-contracts.md` | 契约治理与协议选型 |
| `rules/node-server/profiles/microservice/service-discovery.md` | 服务注册与发现 |
| `rules/node-server/profiles/microservice/resilience.md` | 限流、熔断、降级 |
| `rules/node-server/profiles/microservice/messaging.md` | 消息队列与异步通信 |
| `rules/node-server/profiles/microservice/containerization.md` | Docker 镜像与 K8s 资源限制 |
| `rules/node-server/profiles/microservice/config-center.md` | 配置中心与动态配置 |

### 技术栈
- 运行时：Node.js ≥ 18 LTS
- 语言：TypeScript（strict 模式）
- 框架：NestJS Microservice / Express / Fastify
- RPC：gRPC + protobuf / @nestjs/microservices
- ORM：TypeORM / Prisma / Knex
- 消息：Bull/BullMQ / RabbitMQ / Kafka（KafkaJS）
- 容器：Docker + Kubernetes
- 配置中心：Nacos / Consul / etcd

---

## 四、生成产物清单（通用）

每种部署模式初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `package.json` + 锁文件 | `common/baseline.md` |
| `tsconfig.json` | `common/baseline.md` |
| `.eslintrc.js` + `.prettierrc` | `common/code-style.md` |
| `config/` 配置目录或 `.env` + `.env.example` | `common/configuration.md` |
| `src/main.ts` 入口 | `common/component-initialization.md` |
| `.gitignore` | `common/security.md` |
| `Dockerfile`（微服务模式） | `profiles/microservice/containerization.md` |
