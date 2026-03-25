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
| `rules/python-server/common/baseline.md` | Python 版本、包管理、格式化要求 |
| `rules/python-server/common/code-style.md` | 命名、注释、分层编码 |
| `rules/python-server/common/component-initialization.md` | 依赖注入、生命周期、健康检查 |
| `rules/python-server/common/configuration.md` | 配置文件组织、环境变量 |
| `rules/python-server/common/error-handling.md` | 异常分类与传播 |
| `rules/python-server/common/security.md` | 输入校验、鉴权基线 |
| `rules/python-server/common/observability.md` | 结构化日志、指标 |
| `rules/python-server/common/testing-and-release.md` | 测试要求与质量门禁 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/python-server/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、monolith 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/python-server/profiles/monolith/project-structure.md` | 单体应用目录结构与模块边界 |

### 技术栈
- 语言：Python ≥ 3.10
- Web：FastAPI / Django / Flask
- ORM：SQLAlchemy / Django ORM
- 异步任务：Celery + Redis/RabbitMQ
- 配置：Pydantic Settings / django-environ / python-decouple
- 日志：structlog / loguru（结构化 JSON 输出）
- 服务器：Uvicorn（ASGI）/ Gunicorn（WSGI）

---

## 三、microservice 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/python-server/profiles/microservice/project-structure.md` | 微服务目录结构 |
| `rules/python-server/profiles/microservice/communication-and-contracts.md` | 契约治理与协议选型 |
| `rules/python-server/profiles/microservice/service-discovery.md` | 服务注册与发现 |
| `rules/python-server/profiles/microservice/resilience.md` | 限流、熔断、降级 |
| `rules/python-server/profiles/microservice/messaging.md` | 消息队列与异步通信 |
| `rules/python-server/profiles/microservice/containerization.md` | Docker 镜像与 K8s 资源限制 |
| `rules/python-server/profiles/microservice/config-center.md` | 配置中心与动态配置 |

### 技术栈
- 语言：Python ≥ 3.10
- Web：FastAPI（推荐）/ Django REST Framework
- RPC：gRPC + protobuf（grpcio / grpclib）
- ORM：SQLAlchemy / Tortoise ORM
- 消息：RabbitMQ（pika/aio-pika）/ Kafka（confluent-kafka/aiokafka）
- 异步任务：Celery / Dramatiq / arq
- 容器：Docker + Kubernetes
- 配置中心：Nacos / Consul
- 链路追踪：OpenTelemetry

---

## 四、生成产物清单（通用）

每种部署模式初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `pyproject.toml` | `common/baseline.md` |
| `Makefile` | `common/baseline.md` + `common/testing-and-release.md` |
| ruff 配置（pyproject.toml [tool.ruff]） | `common/code-style.md` |
| `config/` 或 `.env` 配置目录 | `common/configuration.md` |
| `main.py` / `manage.py` 入口 | `common/component-initialization.md` |
| `.gitignore` | `common/security.md` |
| `Dockerfile` + `docker-compose.yml`（微服务） | `profiles/microservice/containerization.md` |
