# rules/java-server/profiles/microservice/service-discovery.md

## 文档目标
1. 定义微服务注册与发现、负载均衡的约束。

---

## 注册中心选型（MUST）

| 注册中心 | 适用场景 | 特点 |
|---------|---------|------|
| **Nacos** | Spring Cloud Alibaba 生态 | 配置+注册一体、AP/CP 可切换、对 Java 生态友好 |
| **Eureka** | Spring Cloud Netflix 生态（维护模式） | 简单易用、AP 模式、社区活跃度下降 |
| **Consul** | 通用微服务 | 健康检查丰富、KV 存储、多数据中心 |
| **Kubernetes Service** | 全容器化部署 | 零额外组件、DNS 服务发现 |

1. 项目必须选定唯一的服务注册与发现方案，禁止混用多套注册中心。
2. 新项目推荐 **Nacos**（Spring Cloud Alibaba），已有 K8s 基础设施可使用 K8s Service。
3. 选型必须在架构设计阶段确定并记录，变更需经架构评审。
4. 全容器化且使用 Kubernetes 的项目，允许使用 K8s Service + DNS 作为服务发现方案。
5. 禁止使用已进入维护模式的 Eureka 作为新项目的注册中心。

检查方式：架构评审
阻断级别：阻断合并

---

## 注册与注销（MUST）

1. 服务必须引入对应的 Spring Cloud 注册客户端（如 `spring-cloud-starter-alibaba-nacos-discovery`）。
2. 服务注册信息必须包含：服务名（`spring.application.name`）、实例地址、端口、协议类型、版本号、健康检查端点。
3. 服务启动时自动注册（Spring Cloud 默认行为），停止时必须主动注销（优雅停机阶段执行）。
4. 服务消费方禁止硬编码目标服务地址，必须通过服务发现获取实例列表。
5. 服务名命名规范：小写字母 + 短横线分隔，如 `order-service`、`user-service`。

### SHOULD
1. 注册信息中携带元数据标签（如 `env=prod`、`region=cn-east`），支持按标签路由。
2. 服务实例列表变更通过 watch/subscribe 实时感知（Nacos 默认支持）。

检查方式：集成测试（注册/注销验证）
阻断级别：阻断合并

---

## 健康检查（MUST）

1. 必须配置两类检查：
   - **存活检查（Liveness）**：进程存活，失败则重启（`/actuator/health/liveness`）。
   - **就绪检查（Readiness）**：可接受流量，失败则摘除流量（`/actuator/health/readiness`）。
2. 健康检查端点必须绑定在管理端口（`management.server.port`），与业务端口分离。
3. 就绪检查必须验证核心依赖可用性（数据库、Redis、消息队列）。
4. 注册中心的健康检查间隔必须合理配置（建议 5-10s），避免频繁检查或延迟摘除。
5. Nacos 注册时必须配置心跳间隔和超时（`spring.cloud.nacos.discovery.heart-beat-interval`）。

检查方式：集成测试
阻断级别：阻断合并

---

## 负载均衡（MUST）

1. 客户端负载均衡使用 Spring Cloud LoadBalancer（推荐）或 Ribbon（Spring Cloud 2020 前）。
2. 必须支持至少一种策略（Round Robin / 加权轮询 / 随机）。
3. Feign Client 默认集成 Spring Cloud LoadBalancer，禁止绕过负载均衡直连单实例。
4. 故障实例必须自动摘除：健康检查失败的实例在超时窗口后不再接收流量。
5. gRPC 客户端必须启用客户端负载均衡，禁止所有请求打到同一实例。

### SHOULD
1. 多机房/多可用区部署时，优先路由到同区实例（亲和性路由），可通过 Nacos 集群配置实现。
2. 灰度发布场景通过元数据标签实现流量染色路由。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并
