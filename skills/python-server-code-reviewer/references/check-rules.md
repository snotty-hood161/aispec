# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ruff/mypy/pylint）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Python 版本 ≥ 3.10，pyproject.toml 或 setup.cfg 中明确声明 | 静态扫描：检查 pyproject.toml |
| BL-02 | P0 | 所有代码通过 ruff format（或 black）格式化，无手动风格调整 | 静态扫描：ruff format --check |
| BL-03 | P0 | 使用 isort 管理导入，分组排列（标准库 / 第三方 / 内部） | 静态扫描：isort --check-only 或 ruff（isort 规则） |
| BL-04 | P0 | 依赖版本锁定（poetry.lock / requirements.txt），禁止使用无版本约束的依赖 | 静态扫描：检查依赖文件版本约束 |
| BL-05 | P1 | 启用 ruff + mypy 并配置 pyproject.toml，CI 中零告警通过 | 静态扫描：ruff check + mypy |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 公开类和函数必须有 docstring | 静态扫描：ruff（D100-D107 规则） |
| CS-02 | P0 | 模块名、包名使用 snake_case，禁止 camelCase 和大写 | 模式匹配：检查文件名与包名 |
| CS-03 | P1 | 变量/函数命名遵循 PEP 8（snake_case），类名 PascalCase | 静态扫描：ruff（N 规则） |
| CS-04 | P1 | 单个函数体不超过 50 行，圈复杂度 ≤ 15 | 静态扫描：ruff（C901） |
| CS-05 | P0 | 分层架构：router/view → service → repository，禁止跨层调用 | 人工审查：检查 import 依赖方向 |

## 三、组件初始化（common/component-initialization.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CI-01 | P0 | 使用依赖注入（FastAPI Depends / Django AppConfig），禁止在模块顶层初始化业务组件 | 模式匹配：搜索模块级全局可变单例 |
| CI-02 | P0 | 组件生命周期明确：启动顺序可控，关闭时逆序释放资源（lifespan/on_event） | 人工审查：检查启动编排 |
| CI-03 | P1 | 健康检查端点（/healthz, /readyz）已注册并验证依赖可用性 | 模式匹配：搜索健康检查路由注册 |
| CI-04 | P1 | 外部依赖（DB/Redis/MQ）连接在启动时验证，失败则阻止启动 | 人工审查：检查启动流程 |

## 四、API 设计（common/api-design.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AD-01 | P0 | API 路径包含版本号（/api/v1/...），版本变更有迁移方案 | 模式匹配：检查路由注册路径 |
| AD-02 | P0 | 统一响应结构：{code, message, data}，禁止裸返回 | 模式匹配：检查返回格式 |
| AD-03 | P0 | 请求参数使用 Pydantic Model / Django Form 校验，禁止手动解析未校验 | 模式匹配：搜索请求处理是否使用校验模型 |
| AD-04 | P1 | 分页接口使用统一分页结构，默认页大小有上限 | 模式匹配：搜索分页参数定义 |
| AD-05 | P1 | 接口文档（OpenAPI/Swagger）与代码同步，CI 中校验 | 人工审查：检查 OpenAPI schema 是否完整 |

## 五、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 所有异常必须捕获或向上传播，禁止裸 except / except Exception 吞掉异常 | 静态扫描：ruff（E722 / BLE001） |
| EH-02 | P0 | 异常向上传播时必须携带上下文：raise ... from err 或自定义异常包装 | 模式匹配：搜索 raise 语句是否有 from |
| EH-03 | P0 | 业务错误码体系统一定义，禁止硬编码字符串错误 | 模式匹配：搜索 raise 中的硬编码消息 |
| EH-04 | P1 | 全局异常处理器（exception_handler / middleware）覆盖所有未捕获异常 | 人工审查：检查全局异常处理配置 |
| EH-05 | P1 | HTTP 层统一异常响应格式，禁止各 endpoint 自行格式化错误 | 人工审查：检查错误响应一致性 |

## 六、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 日志必须结构化输出（JSON），禁止 print() / logging.basicConfig 裸输出 | 模式匹配：搜索 print() 调用与 basicConfig |
| OB-02 | P0 | 日志必须携带 trace_id / request_id，从请求上下文中提取 | 模式匹配：搜索日志调用是否包含关联 ID |
| OB-03 | P1 | 关键业务操作埋点 metrics（请求量/延迟/错误率） | 人工审查：检查 metrics 注册 |
| OB-04 | P1 | 链路追踪 span 覆盖跨服务调用与数据库操作（OpenTelemetry） | 人工审查：检查 span 创建位置 |
| OB-05 | P1 | 日志级别分层使用（DEBUG/INFO/WARNING/ERROR），错误日志包含堆栈 | 模式匹配：检查日志级别使用合理性 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置（密码/密钥/Token）禁止硬编码或提交到代码仓库 | 静态扫描：搜索硬编码密码/密钥模式 |
| CF-02 | P0 | 配置通过环境变量或配置中心注入，支持多环境切换 | 模式匹配：检查配置加载方式 |
| CF-03 | P1 | 配置使用 Pydantic Settings / django-environ / python-decouple 统一管理 | 模式匹配：搜索配置管理模式 |
| CF-04 | P1 | 配置项有默认值与校验，缺失必要配置时启动失败并输出明确提示 | 人工审查：检查配置校验逻辑 |

## 八、并发与资源管理（common/concurrency-and-resource.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CR-01 | P0 | asyncio 任务必须可控取消，禁止 fire-and-forget 的 create_task 无回收 | 模式匹配：搜索 asyncio.create_task 是否有 await/cancel 管理 |
| CR-02 | P0 | 使用 async with / contextmanager 管理资源生命周期，禁止手动 open/close 不配对 | 模式匹配：搜索资源管理模式 |
| CR-03 | P0 | 优雅停机：监听 SIGTERM/SIGINT，超时强制退出（uvicorn shutdown / Gunicorn graceful） | 模式匹配：搜索信号处理与 shutdown |
| CR-04 | P1 | 连接池（DB/Redis/HTTP Client）有大小限制与超时配置 | 人工审查：检查连接池参数 |
| CR-05 | P1 | 线程安全：共享状态使用 threading.Lock 或 asyncio.Lock 保护 | 模式匹配：搜索共享可变状态访问 |

## 九、数据库访问（common/database-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库操作必须通过 Repository/DAO 层，禁止 view/router 直接拼 SQL | 模式匹配：搜索 view/router 中的 SQL 操作 |
| DA-02 | P0 | 查询必须参数化（ORM 查询或参数化 SQL），禁止字符串拼接 SQL（防注入） | 模式匹配：搜索字符串拼接 SQL 模式 |
| DA-03 | P0 | 事务边界在 service 层控制，Repository 层不自行开启事务 | 人工审查：检查事务管理位置 |
| DA-04 | P1 | 批量操作使用 bulk_create / bulk_update / executemany，禁止循环单条操作 | 模式匹配：搜索循环内的 DB 调用 |
| DA-05 | P1 | 数据库迁移使用版本化工具（Alembic / Django Migrations），禁止手动 DDL | 人工审查：检查迁移文件管理 |
| DA-06 | P1 | 慢查询有监控告警，查询超时有上限配置 | 人工审查：检查慢查询日志配置 |

## 十、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 所有外部输入必须校验与清洗（Pydantic / WTForms / Django Form），禁止直接信任用户输入 | 模式匹配：检查输入处理是否有校验 |
| SC-02 | P0 | 鉴权中间件/装饰器覆盖所有受保护路由，禁止路由遗漏 | 模式匹配：检查路由与鉴权绑定 |
| SC-03 | P0 | 敏感数据（密码/Token）禁止明文日志输出 | 模式匹配：搜索日志中的敏感字段 |
| SC-04 | P1 | CORS 配置白名单化，禁止 allow_origins=["*"] 用于生产 | 模式匹配：搜索 CORS 配置 |
| SC-05 | P1 | 接口限流（Rate Limiting）已配置，防止暴力请求 | 人工审查：检查限流中间件/装饰器 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：pytest --cov |
| TR-02 | P0 | 测试文件命名 test_*.py 或 *_test.py，与被测模块同目录或在 tests/ 下 | 模式匹配：检查测试文件位置 |
| TR-03 | P1 | 使用 pytest 参数化（@pytest.mark.parametrize）覆盖多场景 | 模式匹配：搜索参数化测试用法 |
| TR-04 | P1 | CI 流水线包含 lint → test → build 阶段，质量门禁阻断不合格构建 | 人工审查：检查 CI 配置 |
| TR-05 | P1 | API 接口有集成测试（TestClient / APIClient），覆盖核心业务路径 | 人工审查：检查集成测试存在性 |

## 十二、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P1 | 提供性能分析端点或使用 cProfile / py-spy，生产环境限制访问 | 人工审查：检查 profiling 配置 |
| PF-02 | P1 | 避免在请求处理中执行 CPU 密集计算，使用线程池/进程池卸载 | 模式匹配：搜索 async endpoint 中的同步阻塞调用 |
| PF-03 | P1 | 数据库查询有索引覆盖，禁止全表扫描（EXPLAIN 验证） | 人工审查：检查查询与索引匹配 |
| PF-04 | P1 | N+1 查询问题已处理（select_related / joinedload / prefetch） | 模式匹配：搜索 ORM 延迟加载模式 |

## 十三、缓存（common/caching.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CA-01 | P0 | 缓存键设计包含业务前缀与版本号，避免键冲突 | 模式匹配：检查缓存键构造模式 |
| CA-02 | P0 | 所有缓存必须设置 TTL，禁止无过期时间的缓存 | 模式匹配：搜索 set/setex 调用是否带 TTL 参数 |
| CA-03 | P1 | 缓存穿透/击穿/雪崩有防护措施（分布式锁/空值缓存/随机 TTL） | 人工审查：检查缓存防护策略 |
| CA-04 | P1 | 缓存与数据库一致性策略明确（Cache Aside / Write Through） | 人工审查：检查缓存更新逻辑 |

## 十四、文件存储（common/file-storage.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FS-01 | P0 | 文件上传限制大小与类型，校验 MIME Type（python-magic / filetype） | 模式匹配：检查上传处理中的校验逻辑 |
| FS-02 | P0 | 文件使用流式读写（chunks / streaming），禁止全量加载到内存 | 模式匹配：搜索文件读取是否使用流式 |
| FS-03 | P1 | 文件存储路径使用唯一标识（UUID/Hash），禁止用户原始文件名 | 模式匹配：检查文件存储路径生成 |
| FS-04 | P1 | 对象存储使用预签名 URL 直传，减少服务端中转 | 人工审查：检查上传流程架构 |

## 十五、定时任务（common/scheduled-tasks.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| ST-01 | P0 | Celery 任务必须幂等，重复执行不产生副作用 | 人工审查：检查任务逻辑幂等性 |
| ST-02 | P0 | 多实例部署时使用分布式锁（Redis Lock / celery-once），防止任务重复执行 | 模式匹配：搜索分布式锁获取逻辑 |
| ST-03 | P1 | 任务执行有超时控制（task_time_limit / task_soft_time_limit）与失败重试（autoretry_for） | 模式匹配：搜索超时与重试配置 |
| ST-04 | P1 | 任务执行结果有日志记录与监控告警 | 人工审查：检查任务日志与监控 |

## 十六、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止在生产代码中使用 print() 输出日志 | 静态扫描：ruff（T201） |
| FB-02 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks / detect-secrets |
| FB-03 | P0 | 禁止使用已废弃的标准库模块（如 optparse、imp、distutils） | 静态扫描：ruff / pylint |
| FB-04 | P0 | 禁止裸 except 吞掉异常（except: pass） | 静态扫描：ruff（E722 / BLE001） |
| FB-05 | P0 | 禁止在 view/router 中直接操作数据库，必须经过 service 层 | 模式匹配：搜索 view/router 中的 DB 调用 |

---

## Profile 专项检查

### Monolith 专项（profiles/monolith/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MO-01 | P0 | 模块间通过接口（Protocol / ABC）解耦，禁止直接引用其他模块内部实现 | 模式匹配：检查 import 中的跨模块引用 |
| MO-02 | P1 | 模块边界清晰，每个模块有独立的 router/service/repository 层 | 人工审查：检查目录结构 |
| MO-03 | P1 | 共享组件（中间件/工具函数）集中于 common/ 或 shared/ 目录 | 模式匹配：检查共享代码位置 |
| MO-04 | P1 | 模块间数据传递使用 DTO（Pydantic Schema），禁止直接共享数据库 Model | 模式匹配：搜索跨模块的 model 引用 |

### Microservice 专项（profiles/microservice/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MS-01 | P0 | 服务间通信使用 gRPC/HTTP + 统一序列化，禁止私有协议 | 模式匹配：检查服务间调用方式 |
| MS-02 | P0 | 外部调用有超时、重试与熔断配置（httpx / tenacity / pybreaker） | 模式匹配：搜索 HTTP/gRPC Client 配置 |
| MS-03 | P1 | 服务注册与发现配置正确，健康检查端点可用 | 人工审查：检查服务注册配置 |
| MS-04 | P1 | 分布式事务使用 Saga/TCC 模式，禁止跨服务本地事务 | 人工审查：检查跨服务事务处理 |
| MS-05 | P1 | 服务间通信携带 trace_id，链路追踪完整（OpenTelemetry） | 模式匹配：检查调用链 header 传播 |
