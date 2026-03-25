# rules/node-server/profiles/microservice/resilience.md

## Skill 协作
1. `$node-server-coding-guide` 在识别到限流、熔断、降级场景时加载本规则。
2. `$task-router` 在服务韧性与容错任务中路由到本规则。

---

## 文档目标
1. 定义微服务场景下的限流、熔断、降级约束。

---

## 限流（MUST）

1. 面向外部流量的 API 必须配置限流。
2. 限流算法推荐：**令牌桶**（平滑突发）或 **滑动窗口**（精确计数）。
3. 限流维度必须可配置：全局 / 接口级 / 用户级 / IP 级。
4. 限流触发后返回标准响应（HTTP `429 Too Many Requests`），包含 `Retry-After` 提示。
5. 限流阈值必须可配置，禁止硬编码。
6. Node.js 项目推荐使用 `@nestjs/throttler`（NestJS）、`express-rate-limit`（Express）、`@fastify/rate-limit`（Fastify）或 Redis + Lua 脚本实现分布式限流。

### NestJS 限流示例
```typescript
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 100,
    }]),
  ],
  providers: [{
    provide: APP_GUARD,
    useClass: ThrottlerGuard,
  }],
})
export class AppModule {}
```

### Express 限流示例
```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);
```

检查方式：架构评审 + 集成测试
阻断级别：阻断合并

---

## 熔断（MUST）

1. 服务间调用必须配置熔断器。
2. 熔断器支持三态：**关闭** → **打开** → **半开**。
3. 触发条件可配置：错误率阈值（如 > 50%）、慢调用率阈值（如 > 70%）、最小样本数。
4. 熔断打开期间必须执行降级策略，禁止直接抛异常给调用方。
5. 半开阶段允许少量探测请求，探测成功则恢复，失败则重新打开。
6. Node.js 项目推荐使用 `opossum`（Circuit Breaker 库）或自定义熔断逻辑。

### opossum 使用示例
```typescript
import CircuitBreaker from 'opossum';

const options = {
  timeout: 5000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
};

const breaker = new CircuitBreaker(callUserService, options);

breaker.fallback((userId: string) => {
  logger.warn(`user_service_circuit_open userId=${userId}`);
  return { id: userId, username: 'unknown', _degraded: true };
});

async function callUserService(userId: string): Promise<UserDto> {
  const { data } = await httpClient.get(`/api/v1/users/${userId}`);
  return data;
}

async function getUserWithBreaker(userId: string): Promise<UserDto> {
  return breaker.fire(userId);
}
```

检查方式：集成测试（熔断触发与恢复）
阻断级别：阻断合并

---

## 降级（MUST）

1. 核心链路必须定义降级策略：
   - **静态降级**：返回预设默认值或缓存数据。
   - **功能降级**：关闭非核心功能，保障核心流程。
   - **流量降级**：拒绝低优先级请求，保障高优先级。
2. 降级触发和恢复必须有日志和指标记录。
3. 熔断器打开时的 fallback 函数必须有独立实现，禁止在 fallback 中再次调用故障服务。

### 降级 fallback 示例
```typescript
async function getUserWithFallback(userId: string): Promise<UserDto> {
  try {
    return await breaker.fire(userId);
  } catch (error) {
    if (error instanceof CircuitBreaker.OpenCircuitError) {
      logger.warn(`user_service_circuit_open userId=${userId}`);
      const cached = await redis.get(`user:profile:${userId}`);
      if (cached) {
        return JSON.parse(cached);
      }
      return { id: userId, username: 'unknown', _degraded: true };
    }
    throw error;
  }
}
```

### SHOULD
1. 限流、熔断、降级配置优先通过配置中心动态下发，支持运行时调整。
2. 相关指标纳入监控仪表盘，实时可观测。

检查方式：架构评审
阻断级别：阻断合并
