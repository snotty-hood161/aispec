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
| `rules/java-server/common/baseline.md` | Java 版本、构建工具、格式化要求 |
| `rules/java-server/common/code-style.md` | 命名、注释、分层编码 |
| `rules/java-server/common/component-initialization.md` | 依赖注入、生命周期、健康检查 |
| `rules/java-server/common/configuration.md` | 配置文件组织、环境变量 |
| `rules/java-server/common/error-handling.md` | 异常分类与传播 |
| `rules/java-server/common/security.md` | 输入校验、鉴权基线 |
| `rules/java-server/common/observability.md` | 结构化日志、指标 |
| `rules/java-server/common/testing-and-release.md` | 测试要求与质量门禁 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/java-server/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、monolith 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/java-server/profiles/monolith/project-structure.md` | 单体应用目录结构与模块边界 |

### 技术栈
- 语言：Java ≥ 17
- 框架：Spring Boot ≥ 3.0
- ORM：Spring Data JPA / MyBatis-Plus
- 配置：application.yml + Spring Profiles
- 日志：SLF4J + Logback
- 构建：Maven / Gradle

---

## 三、microservice 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/java-server/profiles/microservice/project-structure.md` | 微服务目录结构 |
| `rules/java-server/profiles/microservice/communication-and-contracts.md` | 契约治理与协议选型 |
| `rules/java-server/profiles/microservice/service-discovery.md` | 服务注册与发现 |
| `rules/java-server/profiles/microservice/resilience.md` | 限流、熔断、降级 |
| `rules/java-server/profiles/microservice/messaging.md` | 消息队列与异步通信 |
| `rules/java-server/profiles/microservice/containerization.md` | Docker 镜像与 K8s 资源限制 |
| `rules/java-server/profiles/microservice/config-center.md` | 配置中心与动态配置 |

### 技术栈
- 语言：Java ≥ 17
- 框架：Spring Boot ≥ 3.0 + Spring Cloud
- RPC：OpenFeign / gRPC + protobuf
- ORM：Spring Data JPA / MyBatis-Plus
- 消息：RabbitMQ（Spring AMQP）/ Kafka（Spring Kafka）
- 容器：Docker + Kubernetes
- 注册中心：Nacos / Eureka
- 配置中心：Nacos / Apollo
- 网关：Spring Cloud Gateway
- 熔断：Sentinel / Resilience4j

---

## 四、生成产物清单（通用）

每种部署模式初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `pom.xml` / `build.gradle` | `common/baseline.md` |
| `mvnw` / `gradlew` | `common/baseline.md` |
| `checkstyle.xml` | `common/code-style.md` |
| `src/main/resources/` 配置目录 | `common/configuration.md` |
| `Application.java` 入口 | `common/component-initialization.md` |
| `.gitignore` | `common/security.md` |
