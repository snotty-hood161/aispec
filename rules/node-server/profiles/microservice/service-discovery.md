# rules/node-server/profiles/microservice/service-discovery.md

## Skill 协作
1. `$node-server-coding-guide` 在识别到服务注册、服务发现、负载均衡场景时加载本规则。
2. `$task-router` 在服务注册与发现任务中路由到本规则。

---

## 文档目标
1. 定义微服务注册与发现、负载均衡的约束。

---

## 注册中心选型（MUST）

| 注册中心 | 适用场景 | 特点 |
|---------|---------|------|
| **Consul** | 通用微服务 | 健康检查丰富、KV 存储、多数据中心 |
| **etcd** | Kubernetes 生态 / 已有 etcd 基础设施 | 强一致、轻量、K8s 原生 |
| **Nacos** | 已有 Java/Spring Cloud 生态 | 配置+注册一体、对 Java 生态友好 |
| **Kubernetes Service** | 全容器化部署 | 零额外组件、DNS 服务发现 |

1. 项目必须选定唯一的服务注册与发现方案，禁止混用多套注册中心。
2. 选型必须在架构设计阶段确定并记录，变更需经架构评审。
3. 全容器化且使用 Kubernetes 的项目，允许使用 K8s Service + DNS 作为服务发现方案。
4. Node.js 服务注册推荐使用 `consul`（Consul npm 包）或直接对接 K8s Service DNS。

检查方式：架构评审
阻断级别：阻断合并

---

## 注册与注销（MUST）

1. 服务注册信息必须包含：服务名、实例地址、端口、协议类型（gRPC/HTTP）、版本号、健康检查端点。
2. 服务启动时必须主动注册，停止时必须主动注销（优雅停机阶段执行）。
3. 服务消费方禁止硬编码目标服务地址，必须通过服务发现获取实例列表。
4. NestJS 项目的注册/注销逻辑 MUST 放在 `OnModuleInit` / `OnModuleDestroy` 或 `OnApplicationBootstrap` / `OnApplicationShutdown` 生命周期钩子中，确保生命周期一致。Express/Fastify 项目 MUST 在 `listen` 回调中注册、`SIGTERM` 处理中注销。

### SHOULD
1. 注册信息中携带元数据标签（如 `env=prod`、`region=cn-east`），支持按标签路由。
2. 服务实例列表变更通过 watch/subscribe 实时感知，而非定时轮询。

检查方式：集成测试（注册/注销验证）
阻断级别：阻断合并

---

## 健康检查（MUST）

1. 必须配置两类检查：
   - **存活检查（Liveness）**：进程存活，失败则重启。
   - **就绪检查（Readiness）**：可接受流量，失败则摘除流量。
2. 健康检查端点建议独立（`/healthz`、`/readyz`），与业务路由分离。
3. 就绪检查必须验证核心依赖可用性（数据库、Redis、消息队列）。
4. NestJS 项目 MUST 使用 `@nestjs/terminus` 模块实现健康检查，提供类型安全的健康指示器。

### NestJS 健康检查示例
```typescript
import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck, HealthCheckService,
  PrismaHealthIndicator, MemoryHealthIndicator,
} from '@nestjs/terminus';
import { PrismaService } from '../infra/database/prisma.service';

@Controller()
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prisma: PrismaHealthIndicator,
    private memory: MemoryHealthIndicator,
    private prismaService: PrismaService,
  ) {}

  @Get('healthz')
  @HealthCheck()
  liveness() {
    return this.health.check([
      () => this.memory.checkHeap('memory_heap', 200 * 1024 * 1024),
    ]);
  }

  @Get('readyz')
  @HealthCheck()
  readiness() {
    return this.health.check([
      () => this.prisma.pingCheck('database', this.prismaService),
      () => this.memory.checkHeap('memory_heap', 200 * 1024 * 1024),
    ]);
  }
}
```

### Express 健康检查示例
```typescript
app.get('/healthz', (_req, res) => {
  res.json({ status: 'ok' });
});

app.get('/readyz', async (_req, res) => {
  const errors: string[] = [];
  try {
    await prisma.$queryRaw`SELECT 1`;
  } catch {
    errors.push('database');
  }
  try {
    await redis.ping();
  } catch {
    errors.push('redis');
  }
  if (errors.length > 0) {
    return res.status(503).json({ status: 'error', unavailable: errors });
  }
  res.json({ status: 'ready' });
});
```

检查方式：集成测试
阻断级别：阻断合并

---

## 负载均衡（MUST）

1. 客户端负载均衡必须支持至少一种策略（Round Robin / 加权轮询 / 最少连接）。
2. gRPC 客户端必须启用客户端负载均衡，禁止所有请求打到同一实例。
3. 故障实例必须自动摘除：健康检查失败的实例在超时窗口后不再接收流量。
4. 使用 K8s Service 时，可依赖 K8s 内置的 kube-proxy 负载均衡。

### SHOULD
1. 多机房/多可用区部署时，优先路由到同区实例（亲和性路由）。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并
