# rules/python-server/common/testing-and-release.md

## 测试框架（MUST）
1. Python 服务端项目 MUST 使用 `pytest` 作为测试框架，禁止使用 `unittest`（除非维护遗留项目）。
2. 异步测试 MUST 使用 `pytest-asyncio`，配置 `asyncio_mode = "auto"` 或显式标记 `@pytest.mark.asyncio`。
3. FastAPI 项目 MUST 使用 `httpx.AsyncClient` + `ASGITransport` 进行 API 测试，禁止使用已废弃的 `TestClient` 同步模式测试异步路由。
4. Django 项目使用 `pytest-django`，配合 `django.test.Client` 或 `rest_framework.test.APIClient`。

### FastAPI 测试示例
```python
import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    response = await client.post("/api/v1/users", json={"username": "test", "email": "t@t.com"})
    assert response.status_code == 201
    data = response.json()
    assert data["code"] == "OK"
```

## 测试要求
1. 新增或修改业务逻辑必须配套测试：单元测试优先，必要时补集成测试。
2. 单元测试 MUST 使用参数化（`@pytest.mark.parametrize`）覆盖正常路径、边界条件、异常路径。
3. 修复缺陷必须补回归测试，确保问题可重复验证与防回归。
4. 必须包含至少一项优雅停机验证：停止接收新请求、在途请求可完成、超时后强退行为符合预期。
5. 必须验证健康探针与就绪探针行为：依赖正常时可就绪、关键依赖故障时不可就绪。

## Mock 与 Fixture（MUST）
1. 外部依赖（数据库、Redis、第三方 API）在单元测试中 MUST 使用 mock 或 fake 替代，禁止依赖真实外部服务。
2. 推荐使用 `unittest.mock.AsyncMock` 进行异步 mock。
3. Fixture 应按作用域分层：`session` 级别用于数据库连接、`function` 级别用于事务回滚。
4. 测试数据工厂推荐使用 `factory_boy` 或 `faker`，禁止在测试代码中硬编码大量测试数据。
5. 集成测试 SHOULD 使用 `testcontainers-python` 启动临时容器（数据库、Redis），确保环境隔离。

## 覆盖率要求
1. 新增代码行覆盖率 MUST ≥ 80%，核心业务逻辑覆盖率 SHOULD ≥ 90%。
2. CI 中 MUST 集成覆盖率检查（`pytest-cov`），低于阈值阻断合并。
3. 覆盖率报告必须排除测试代码、迁移脚本、配置文件。

### 覆盖率配置示例
```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = "--cov=app --cov-report=term-missing --cov-fail-under=80"
```

## 质量门禁
1. 合并前必须通过 `ruff check`、`mypy`、`pytest`、覆盖率检查。
2. PR 描述必须包含变更目的、影响范围、回滚方案、测试结果。
3. PR 评审必须附 PR 评审清单的勾选结果，且所有 P0 项必须通过。
4. 涉及 API、配置或数据库变更时，必须同步更新文档。

## 发布要求
1. 生产发布必须支持健康检查、优雅停机、失败回滚。
2. 变更应具备灰度策略或等效风险控制方案。
3. 发布前需演练一次停机流程，确认不会因中断在途请求而产生脏数据。
4. 数据库迁移 MUST 在应用部署前独立执行，禁止在应用启动时自动执行 `alembic upgrade head`。
