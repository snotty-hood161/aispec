# rules/java-server/profiles/microservice/resilience.md

## 文档目标
1. 定义微服务场景下的限流、熔断、降级约束。
2. 推荐方案：Sentinel（Spring Cloud Alibaba 生态）或 Resilience4j（Spring Cloud 生态）。

---

## 框架选型（MUST）

| 框架 | 适用场景 | 特点 |
|------|---------|------|
| **Sentinel** | Spring Cloud Alibaba 生态 | 功能全面、控制台可视化、规则动态推送 |
| **Resilience4j** | 轻量级 Spring Cloud 生态 | 函数式 API、与 Spring Boot 深度集成、无外部依赖 |

1. 项目必须选定 Sentinel 或 Resilience4j 作为限流熔断框架，禁止混用。
2. 选型必须在架构设计阶段确定并记录。
3. 已使用 Spring Cloud Alibaba 的项目推荐 Sentinel；纯 Spring Cloud 项目推荐 Resilience4j。

---

## 限流（MUST）

1. 面向外部流量的 API 必须配置限流。
2. 限流算法推荐：**令牌桶**（平滑突发）或 **滑动窗口**（精确计数）。
3. 限流维度必须可配置：全局 / 接口级 / 用户级 / IP 级。
4. 限流触发后返回标准响应（HTTP `429 Too Many Requests`），包含 `Retry-After` Header。
5. 限流阈值必须可配置（通过配置文件或配置中心），禁止硬编码。
6. Sentinel 限流规则推荐通过 Nacos 动态推送，支持运行时调整。
7. Resilience4j 限流使用 `@RateLimiter` 注解，配置通过 `application.yml` 管理。

### 限流配置示例（Resilience4j）

```yaml
resilience4j:
  ratelimiter:
    instances:
      orderApi:
        limit-for-period: 100
        limit-refresh-period: 1s
        timeout-duration: 500ms
```

检查方式：架构评审 + 集成测试
阻断级别：阻断合并

---

## 熔断（MUST）

1. 服务间调用必须配置熔断器。
2. 熔断器支持三态：**关闭** → **打开** → **半开**。
3. 触发条件可配置：错误率阈值（如 > 50%）、慢调用率阈值（如 > 70%）、最小样本数。
4. 熔断打开期间必须执行降级策略（返回默认值或缓存数据），禁止直接抛异常给调用方。
5. 半开阶段允许少量探测请求，探测成功则恢复，失败则重新打开。
6. Feign Client 配合 Sentinel 或 Resilience4j 实现自动熔断。
7. Resilience4j 使用 `@CircuitBreaker` 注解，Sentinel 使用 `@SentinelResource` 注解。

### 熔断配置示例（Resilience4j）

```yaml
resilience4j:
  circuitbreaker:
    instances:
      userServiceClient:
        sliding-window-type: COUNT_BASED
        sliding-window-size: 10
        failure-rate-threshold: 50
        slow-call-rate-threshold: 70
        slow-call-duration-threshold: 2s
        wait-duration-in-open-state: 30s
        permitted-number-of-calls-in-half-open-state: 3
        minimum-number-of-calls: 5
```

检查方式：集成测试（熔断触发与恢复）
阻断级别：阻断合并

---

## 降级（MUST）

1. 核心链路必须定义降级策略：
   - **静态降级**：返回预设默认值或缓存数据（Feign `fallback`）。
   - **功能降级**：关闭非核心功能，保障核心流程。
   - **流量降级**：拒绝低优先级请求，保障高优先级。
2. 降级触发和恢复必须有日志和指标记录。
3. Feign Client 必须实现 `fallback` 或 `fallbackFactory`，提供降级响应。
4. `fallbackFactory` 优先于 `fallback`，可获取异常信息用于日志记录和区分降级原因。

### 降级实现示例

```java
@FeignClient(name = "user-service", fallbackFactory = UserServiceFallbackFactory.class)
public interface UserServiceClient {
    @GetMapping("/api/v1/users/{id}")
    UserVO getUser(@PathVariable Long id);
}

@Component
public class UserServiceFallbackFactory implements FallbackFactory<UserServiceClient> {
    @Override
    public UserServiceClient create(Throwable cause) {
        return id -> {
            log.warn("user-service 降级，原因: {}", cause.getMessage());
            return UserVO.defaultValue();
        };
    }
}
```

### SHOULD
1. 限流、熔断、降级配置优先通过配置中心动态下发，支持运行时调整。
2. 相关指标纳入 Micrometer 监控仪表盘，实时可观测。
3. 定期进行故障注入测试（如 Chaos Monkey for Spring Boot），验证降级策略有效性。

检查方式：架构评审
阻断级别：阻断合并
