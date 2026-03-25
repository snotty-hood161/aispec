# rules/go-server/profiles/microservice/containerization.md

## 文档目标
1. 定义微服务容器化部署、Docker 镜像构建、Kubernetes 运行约束。
2. 非容器化部署的项目可跳过本文件。

---

## Docker 镜像规范（MUST）

1. 必须使用多阶段构建（Multi-Stage Build），最终镜像基于最小基础镜像（如 `alpine`、`distroless`、`scratch`）。
2. 禁止在最终镜像中包含构建工具链（Go 编译器、`git`、`make` 等）。
3. 二进制必须静态编译（`CGO_ENABLED=0`），确保在最小镜像中可运行。
4. 镜像标签必须包含版本号或 Git commit hash，禁止仅使用 `latest`。
5. Dockerfile 必须纳入版本控制，与服务代码同仓管理。
6. 镜像构建必须在 CI 中自动执行，禁止依赖开发者本地构建并手动推送。

### SHOULD
1. 定期扫描镜像漏洞（如 `trivy`、`grype`），高危漏洞阻断发布。
2. 基础镜像定期更新，跟进安全补丁。

检查方式：Dockerfile 审查 + CI 构建验证
阻断级别：阻断合并

---

## Kubernetes 运行约束（MUST）

### 探针配置
1. 必须配置 `livenessProbe`（存活探针）：检测进程是否死锁/卡住，失败则重启容器。
2. 必须配置 `readinessProbe`（就绪探针）：检测服务是否可接受流量，失败则摘除流量。
3. 推荐配置 `startupProbe`（启动探针）：初始化慢的服务使用，避免存活探针误判。
4. 探针端点必须绑定管理端口，与业务端口分离。
5. 探针超时和间隔必须合理配置（建议：`initialDelaySeconds` ≥ 5s，`periodSeconds` 5-10s，`timeoutSeconds` 3-5s）。

### 资源限制
1. 每个容器必须设置 `resources.requests` 和 `resources.limits`（CPU + 内存）。
2. `requests` 与 `limits` 的比值建议 1:2 至 1:4，禁止设置过大的 limits 导致节点资源碎片。
3. Go 服务建议设置 `GOMEMLIMIT` 为容器内存 limits 的 80%-90%，防止 OOM Kill。
4. 禁止以 root 用户运行容器（`runAsNonRoot: true`）。

### 副本与调度
1. 生产环境必须至少 2 个副本，禁止单实例部署。
2. 必须配置 `podAntiAffinity`，确保同一服务的副本分布在不同节点。
3. 必须配置 `PodDisruptionBudget`（PDB），确保滚动更新或节点维护时至少有一个副本可用。

检查方式：K8s 配置审查
阻断级别：阻断合并

---

## 优雅停机与 K8s 集成（MUST）

1. `terminationGracePeriodSeconds` 必须 ≥ 应用优雅停机超时（参见 `common/concurrency-and-resource.md`）。
2. 容器收到 `SIGTERM` 后，应用必须执行优雅停机流程（停止接收新请求 → 排空在途请求 → 释放资源）。
3. `preStop` hook 推荐 sleep 3-5 秒，等待 Service Endpoint 摘除完成后再开始停机。

检查方式：K8s 配置审查 + 集成测试
阻断级别：阻断合并
