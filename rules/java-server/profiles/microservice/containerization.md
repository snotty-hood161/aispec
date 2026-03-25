# rules/java-server/profiles/microservice/containerization.md

## 文档目标
1. 定义微服务容器化部署、Docker 镜像构建、Kubernetes 运行约束。
2. 非容器化部署的项目可跳过本文件。

---

## Docker 镜像规范（MUST）

1. 必须使用多阶段构建（Multi-Stage Build）：第一阶段使用 Maven/Gradle 构建 JAR；第二阶段使用 JRE 基础镜像运行。
2. 最终镜像基于轻量 JRE 镜像（推荐 `eclipse-temurin:{version}-jre-alpine` 或 `amazoncorretto:{version}-alpine`），禁止使用完整 JDK 镜像。
3. 禁止在最终镜像中包含构建工具链（Maven、Gradle、JDK 编译器、Git 等）。
4. 镜像标签必须包含版本号或 Git Commit Hash，禁止仅使用 `latest`。
5. Dockerfile 必须纳入版本控制，与服务代码同仓管理。
6. 镜像构建必须在 CI 中自动执行，禁止依赖开发者本地构建并手动推送。
7. 推荐使用 Spring Boot 的分层 JAR（Layered JAR）优化 Docker 缓存，减少镜像重建时间。

### Dockerfile 示例

```dockerfile
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./mvnw -DskipTests clean package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/target/*.jar app.jar
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### SHOULD
1. 定期扫描镜像漏洞（如 `trivy`、`grype`），高危漏洞阻断发布。
2. 基础镜像定期更新，跟进安全补丁。
3. 使用 `jib-maven-plugin` 或 `jib-gradle-plugin` 免 Dockerfile 构建镜像，提升构建效率。

检查方式：Dockerfile 审查 + CI 构建验证
阻断级别：阻断合并

---

## Kubernetes 运行约束（MUST）

### 探针配置
1. 必须配置 `livenessProbe`（存活探针）：检测进程是否死锁/卡住，失败则重启容器。使用 `/actuator/health/liveness`。
2. 必须配置 `readinessProbe`（就绪探针）：检测服务是否可接受流量，失败则摘除流量。使用 `/actuator/health/readiness`。
3. 推荐配置 `startupProbe`（启动探针）：Spring Boot 应用启动较慢时使用，避免存活探针误判。
4. 探针端点必须绑定管理端口（`management.server.port`），与业务端口分离。
5. 探针超时和间隔必须合理配置：
   - `startupProbe`：`initialDelaySeconds` ≥ 10s，`periodSeconds` 5s，`failureThreshold` 30（允许最长 150s 启动）。
   - `livenessProbe`：`periodSeconds` 10s，`timeoutSeconds` 3s，`failureThreshold` 3。
   - `readinessProbe`：`periodSeconds` 5s，`timeoutSeconds` 3s，`failureThreshold` 3。

### 探针配置示例

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8081
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 3
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8081
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
startupProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8081
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 30
```

### 资源限制
1. 每个容器必须设置 `resources.requests` 和 `resources.limits`（CPU + 内存）。
2. `requests` 与 `limits` 的比值建议 1:2 至 1:4，禁止设置过大的 limits 导致节点资源碎片。
3. Java 应用 `-Xmx` 建议为容器内存 limits 的 70%-80%，预留内存给 Metaspace、线程栈、DirectBuffer 等。
4. JDK 10+ 默认支持 `-XX:+UseContainerSupport`，可自动感知容器内存限制。
5. 禁止以 root 用户运行容器（`runAsNonRoot: true`，`securityContext.runAsUser`）。

### 资源配置示例

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "2000m"
    memory: "1024Mi"
env:
  - name: JAVA_OPTS
    value: "-Xms512m -Xmx768m -XX:MaxMetaspaceSize=256m -XX:+UseG1GC"
```

### 副本与调度
1. 生产环境必须至少 2 个副本，禁止单实例部署。
2. 必须配置 `podAntiAffinity`，确保同一服务的副本分布在不同节点。
3. 必须配置 `PodDisruptionBudget`（PDB），确保滚动更新或节点维护时至少有一个副本可用。

检查方式：K8s 配置审查
阻断级别：阻断合并

---

## 优雅停机与 K8s 集成（MUST）

1. `terminationGracePeriodSeconds` 必须 ≥ Spring Boot 优雅停机超时（`spring.lifecycle.timeout-per-shutdown-phase`）+ 5s 缓冲。
2. 容器收到 `SIGTERM` 后，Spring Boot 自动执行优雅停机流程（`server.shutdown=graceful`）：停止接收新请求 → 排空在途请求 → 释放资源。
3. `preStop` hook 推荐 sleep 3-5 秒，等待 K8s Service Endpoint 摘除完成后再开始停机。

### preStop 配置示例

```yaml
lifecycle:
  preStop:
    exec:
      command: ["sh", "-c", "sleep 5"]
```

检查方式：K8s 配置审查 + 集成测试
阻断级别：阻断合并

---

## 日志采集（MUST）

1. 容器化应用日志必须输出到 stdout/stderr（Spring Boot 默认行为），由 K8s 日志采集器（Fluentd / Fluent Bit / Filebeat）统一收集。
2. 禁止在容器内写日志文件到本地磁盘（容器重启后丢失），如需持久化须挂载外部卷。
3. 日志格式必须为 JSON（配合 `logback-spring.xml` 配置 `LogstashEncoder`），便于日志平台解析。

检查方式：日志配置审查
阻断级别：阻断合并
