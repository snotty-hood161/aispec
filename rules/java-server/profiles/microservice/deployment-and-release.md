# rules/java-server/profiles/microservice/deployment-and-release.md

## 文档目标
1. 定义微服务版本管理与灰度发布约束。

---

## 版本管理（MUST）

1. 服务版本号遵循语义化版本（SemVer：`MAJOR.MINOR.PATCH`）。
2. 版本号在 `pom.xml` / `build.gradle` 中维护，构建产物（JAR/Docker Image）必须携带版本号。
3. 多版本共存期间，服务注册信息中必须携带版本号（Nacos 元数据），消费方可按版本路由。
4. 接口废弃必须走 Deprecation 流程：标记 `@Deprecated` → 通知消费方 → 观察调用量 → 下线。
5. 每次发布必须打 Git Tag（`v{MAJOR}.{MINOR}.{PATCH}`），便于回溯和回滚。

检查方式：发布流程审查
阻断级别：阻断合并

---

## CI/CD 流水线（MUST）

1. 代码合并到主分支后必须触发 CI 流水线：编译 → 单元测试 → 集成测试 → 代码质量检查 → 构建镜像 → 推送镜像仓库。
2. 禁止本地构建 Docker 镜像并手动推送，必须由 CI 自动执行。
3. 构建产物必须可追溯：Docker Image Tag 包含 Git Commit Hash 或版本号。
4. CD 部署使用 GitOps（ArgoCD / Flux）或 CI 工具触发 K8s 滚动更新，禁止手动 `kubectl apply`。
5. 生产环境部署必须有审批流程（至少一人审批），禁止自动部署到生产。

### SHOULD
1. CI 流水线执行时间控制在 10 分钟以内，超过需优化（并行测试、增量构建）。
2. 构建缓存（Maven Local Repository / Gradle Build Cache）纳入 CI 加速。

检查方式：CI/CD 配置审查
阻断级别：阻断合并

---

## 灰度发布（SHOULD）

1. 推荐策略：
   - **金丝雀发布**：新版本接收小比例流量（如 5%），观察指标后逐步放量。通过 Nacos 元数据 + 网关路由或 K8s Ingress 权重实现。
   - **蓝绿部署**：新旧版本并存，通过流量切换完成发布。
2. 灰度期间必须配置核心指标告警（错误率、延迟），异常自动回滚或人工介入。
3. Spring Cloud Gateway 或 Nginx Ingress 支持按权重/Header/Cookie 路由，实现灰度流量切分。

### SHOULD
1. 发布前完成压力测试，对比性能基线（参见 `common/performance.md`）。
2. 回滚方案必须预先制定并验证可执行性（K8s `kubectl rollout undo` 或 ArgoCD 回滚）。
3. 发布后 30 分钟内持续观察核心指标。

检查方式：发布流程审查
阻断级别：告警记录

---

## 滚动更新（MUST）

1. K8s 滚动更新必须配置 `maxUnavailable` 和 `maxSurge`，保证更新期间服务可用。
2. 更新期间必须依赖就绪探针（`readinessProbe`）判断新实例是否可接受流量。
3. 旧实例必须执行优雅停机（参见 `common/concurrency-and-resource.md`），确保在途请求完成。
4. Spring Boot 应用启动时间建议控制在 30 秒以内；启动慢的服务必须配置 `startupProbe`。
5. 数据库 Schema 变更必须兼容新旧版本并存（Expand-Contract 模式），禁止在滚动更新期间出现 Schema 不兼容。

检查方式：K8s 配置审查 + 集成测试
阻断级别：阻断合并
