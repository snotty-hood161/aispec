# rules/python-server/profiles/microservice/containerization.md

## 文档目标
1. 定义微服务容器化部署、Docker 镜像构建、Kubernetes 运行约束。
2. 非容器化部署的项目可跳过本文件。

---

## Docker 镜像规范（MUST）

1. 必须使用多阶段构建（Multi-Stage Build），最终镜像基于最小基础镜像（如 `python:3.12-slim` 或 `python:3.12-alpine`）。
2. 禁止在最终镜像中包含构建工具链（编译器、`gcc`、`make`、开发头文件等），仅保留运行时依赖。
3. 依赖安装 MUST 使用 lockfile 确保可复现构建（`poetry install --no-dev` / `pip install -r requirements.txt` / `uv sync --no-dev`）。
4. 镜像标签必须包含版本号或 Git commit hash，禁止仅使用 `latest`。
5. Dockerfile 必须纳入版本控制，与服务代码同仓管理。
6. 镜像构建必须在 CI 中自动执行，禁止依赖开发者本地构建并手动推送。
7. 应用代码 MUST 由非 root 用户运行。

### Python 多阶段 Dockerfile 示例
```dockerfile
# 构建阶段
FROM python:3.12-slim AS builder
WORKDIR /build
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && poetry install --no-dev --no-interaction

# 运行阶段
FROM python:3.12-slim
RUN groupadd -r app && useradd -r -g app app
WORKDIR /app
COPY --from=builder /build/.venv /app/.venv
COPY app/ ./app/
COPY alembic/ ./alembic/
COPY alembic.ini ./
ENV PATH="/app/.venv/bin:$PATH"
USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### SHOULD
1. 定期扫描镜像漏洞（如 `trivy`、`grype`），高危漏洞阻断发布。
2. 基础镜像定期更新，跟进安全补丁。
3. 使用 `.dockerignore` 排除不必要的文件（`__pycache__`、`.git`、`tests/`、`.env`）。

检查方式：Dockerfile 审查 + CI 构建验证
阻断级别：阻断合并

---

## Kubernetes 运行约束（MUST）

### 探针配置
1. 必须配置 `livenessProbe`（存活探针）：检测进程是否死锁/卡住，失败则重启容器。
2. 必须配置 `readinessProbe`（就绪探针）：检测服务是否可接受流量，失败则摘除流量。
3. 推荐配置 `startupProbe`（启动探针）：Python 服务启动较慢时使用，避免存活探针误判。
4. 探针端点必须使用应用提供的 `/healthz` 和 `/readyz`。
5. 探针超时和间隔必须合理配置（建议：`initialDelaySeconds` ≥ 10s，`periodSeconds` 5-10s，`timeoutSeconds` 3-5s）。

### K8s 探针配置示例
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 3
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /readyz
    port: 8000
  initialDelaySeconds: 15
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

startupProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 12
```

### 资源限制
1. 每个容器必须设置 `resources.requests` 和 `resources.limits`（CPU + 内存）。
2. `requests` 与 `limits` 的比值建议 1:2 至 1:4，禁止设置过大的 limits 导致节点资源碎片。
3. Python 服务内存 limits 必须考虑 Worker 进程数（Uvicorn workers × 单 Worker 内存），建议预留 20% 缓冲。
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
2. 容器收到 `SIGTERM` 后，Uvicorn/Gunicorn 必须执行优雅停机流程（停止接收新请求 → 排空在途请求 → 释放资源）。
3. `preStop` hook 推荐 sleep 3-5 秒，等待 Service Endpoint 摘除完成后再开始停机。
4. Celery Worker 容器 MUST 配置 `SIGTERM` 优雅停机：Worker 停止接收新任务，等待正在执行的任务完成。

### K8s 优雅停机配置
```yaml
terminationGracePeriodSeconds: 60
lifecycle:
  preStop:
    exec:
      command: ["sleep", "5"]
```

检查方式：K8s 配置审查 + 集成测试
阻断级别：阻断合并

---

## Celery Worker 容器化（MUST）

1. Celery Worker MUST 作为独立 Deployment 部署，禁止与 Web 服务共享同一容器。
2. Worker 副本数必须根据任务队列积压量可伸缩（推荐使用 KEDA + Redis/RabbitMQ 指标）。
3. Worker 容器必须配置 `time_limit` 和 `soft_time_limit`，防止单个任务无限运行。
4. Worker 健康检查推荐使用 `celery inspect ping` 或自定义 HTTP 端点。

检查方式：K8s 配置审查
阻断级别：阻断合并
