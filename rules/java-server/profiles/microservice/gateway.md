# rules/java-server/profiles/microservice/gateway.md

## 文档目标
1. 定义 API 网关的职责边界与约束。仅在架构包含网关层时启用本文件。

---

## 网关选型（MUST）

| 方案 | 适用场景 | 特点 |
|------|---------|------|
| **Spring Cloud Gateway** | Spring Cloud 生态原生 | 非阻塞（WebFlux）、Filter 链、与注册中心集成 |
| **Kong** | 通用网关、多语言 | 插件丰富、OpenResty 基础、性能优秀 |
| **APISIX** | 高性能通用网关 | 基于 OpenResty、动态路由、丰富插件 |

1. Java 微服务生态推荐使用 **Spring Cloud Gateway**。
2. 已有 Kong/APISIX 基础设施的团队可继续使用，禁止同一项目混用多套网关。
3. 网关选型必须在架构设计阶段确定并记录。

检查方式：架构评审
阻断级别：阻断合并

---

## 网关职责（MUST）

1. 网关必须且仅承担以下职责：
   - **路由转发**：请求路由到目标服务（通过服务发现自动路由）。
   - **协议转换**：HTTP ↔ gRPC（若需要）。
   - **鉴权**：统一认证，JWT Token 校验（在 Gateway Filter 中实现）。
   - **限流**：全局/接口级限流（Spring Cloud Gateway + Sentinel / Redis RateLimiter）。
   - **日志与追踪**：注入 `traceId`、`requestId`，记录访问日志。
   - **跨域处理**：统一 CORS 配置。
2. 网关禁止包含业务逻辑（数据聚合、字段转换、业务校验、数据库操作）。
3. 网关路由配置必须版本化，与服务契约保持同步。
4. 网关 Filter 执行顺序必须明确（通过 `@Order` 或 `Ordered` 接口），禁止隐式依赖。

### Spring Cloud Gateway 路由配置示例

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/v1/orders/**
          filters:
            - StripPrefix=0
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 100
                redis-rate-limiter.burstCapacity: 200
```

---

## 网关部署（MUST）

1. 网关必须高可用部署（至少 2 实例），并配置健康检查。
2. 网关必须注册到服务注册中心（Nacos/Consul），与后端服务共享注册中心。
3. Spring Cloud Gateway 基于 WebFlux（非阻塞），禁止在 Gateway Filter 中使用阻塞操作（`Thread.sleep()`、同步 HTTP 调用等）。
4. 网关必须配置全局超时（`spring.cloud.gateway.httpclient.connect-timeout`、`response-timeout`）。

### SHOULD
1. 网关配置通过配置中心管理（Nacos），支持动态更新路由规则而不重启。
2. 网关指标（QPS、延迟、错误率）纳入 Micrometer 统一监控。
3. 网关访问日志独立存储，便于审计和排查。

检查方式：架构评审
阻断级别：阻断合并

---

## 网关安全（MUST）

1. 网关必须统一校验 JWT Token，校验通过后将用户信息（userId、roles）通过 Header 传递给下游服务。
2. 下游服务信任网关传递的 Header（内部网络），禁止外部请求伪造这些 Header（网关层必须清洗）。
3. 网关必须配置 HTTPS（面向外部），内部通信可根据安全策略决定是否加密。
4. 网关层必须限制请求体大小（`spring.codec.max-in-memory-size`），防止大请求攻击。
5. 敏感接口（登录、支付）的限流阈值必须独立配置，比普通接口更严格。

检查方式：安全审查
阻断级别：阻断合并
