# rules/python-server/common/forbidden.md

## 禁止事项

### 代码质量禁令
1. 禁止使用裸 `except:`，必须指定具体异常类型；确需捕获所有异常时使用 `except Exception:`。
2. 禁止使用 `except Exception: pass`（吞异常），必须记录日志或重新抛出。
3. 禁止使用 `print()` / `pprint()` 输出日志，必须通过结构化日志组件。
4. 禁止将 `breakpoint()` / `pdb.set_trace()` / `ipdb` 等调试代码提交到主分支。
5. 禁止使用 `import *`（通配符导入），除 `__init__.py` 的显式重导出场景。
6. 禁止使用可变对象作为函数默认参数（如 `def foo(items: list = [])`），必须使用 `None` 并在函数内初始化。
7. 禁止在异步上下文中调用同步阻塞函数（`time.sleep()`、`requests.get()`、同步文件 I/O）。

### 安全禁令
8. 禁止字符串拼接 SQL（`f"SELECT * FROM users WHERE id = {user_id}"`），必须使用参数化查询。
9. 禁止硬编码数据库、Redis、MinIO 等外部依赖地址和凭据，必须通过配置注入。
10. 禁止在代码中硬编码密钥、令牌、密码，必须通过环境变量或密钥管理服务获取。
11. 禁止在 CORS 中间件中硬编码域名白名单，必须从配置加载。
12. 禁止生产环境开启 `DEBUG = True`（Django）或 `debug=True`（FastAPI/Flask）。
13. 禁止在 API 响应中返回原始异常堆栈、SQL 语句、内部网络地址、密钥。

### 架构禁令
14. 禁止在 router/view 中直接操作数据库，必须经由 service 层调用。
15. 禁止在 router/service 中直接构造基础组件客户端（`create_engine()`、`Redis()`、`boto3.client()`），必须通过依赖注入。
16. 禁止通过模块级全局变量暴露可变组件实例（如全局 `db`、全局 `redis_client`），必须通过依赖注入获取。
17. 禁止将业务实体放入通用共享目录后被跨服务直接复用。
18. 禁止将 ORM model 直接作为 API 响应返回，必须通过 Pydantic schema 转换。
19. 禁止将统计分析临时读模型用于常规 CRUD 查询与写入。
20. 禁止对失败请求统一返回 `200` 并仅依赖响应体业务 `code` 区分错误。

### 依赖与配置禁令
21. 禁止在 `.gitignore` 中忽略 lockfile（`poetry.lock` / `uv.lock` / `requirements.txt`）。
22. 禁止直接调用 `os.getenv()` 读取配置，必须通过 `pydantic-settings` 配置类统一管理。
23. 禁止在生产代码中使用 `eval()` / `exec()` / `__import__()`，存在代码注入风险。
24. 禁止使用已废弃的 Pydantic v1 API（如 `class Config:`、`validator`），MUST 使用 Pydantic v2。
25. 禁止使用 `typing.Optional` / `typing.List` / `typing.Dict`（Python 3.10+ 项目），使用内置语法 `X | None`、`list[X]`、`dict[K, V]`。

### 测试禁令
26. 禁止在测试中依赖外部真实服务（数据库、Redis、第三方 API），必须使用 mock 或 testcontainers。
27. 禁止提交无断言的测试用例（仅调用不验证结果）。
28. 禁止在应用启动时自动执行数据库迁移（`alembic upgrade head`），迁移必须独立执行。
