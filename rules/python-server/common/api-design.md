# rules/python-server/common/api-design.md

## API 版本与兼容
1. HTTP API 必须版本化（例如 `/api/v1`），破坏性变更必须升级版本。
2. gRPC/事件契约必须显式版本目录或命名空间（例如 `order.v1`）。
3. 对外字段语义必须稳定，禁止直接透传数据库字段名或内部枚举。

## 文档形式与目录约定
1. HTTP 契约默认使用 OpenAPI 3.x 作为文档标准。
2. FastAPI 项目 MUST 利用框架自动生成 OpenAPI 文档，确保 Pydantic schema 与文档同步。
3. Django 项目 SHOULD 集成 `drf-spectacular` 自动生成 OpenAPI 文档。
4. Flask 项目 SHOULD 集成 `flask-smorest` 或 `apispec` 自动生成 OpenAPI 文档。
5. 同一服务必须明确一种契约主来源（Contract-First 或 Code-First），禁止同一接口双源维护。
6. API 文档必须包含请求/响应示例、错误码说明、鉴权方式。

## Pydantic 数据校验（MUST）
1. 所有 API 请求体和响应体 MUST 使用 Pydantic model 定义，禁止使用裸 `dict`。
2. Pydantic model MUST 使用 Pydantic v2（`BaseModel`），禁止使用已废弃的 v1 API。
3. 字段校验 MUST 使用 `Field()` 约束（`min_length`、`max_length`、`ge`、`le`、`pattern` 等），禁止仅依赖类型注解。
4. 枚举字段 MUST 使用 `Literal` 或 `Enum` 类型约束，禁止接受任意字符串。
5. 嵌套对象 MUST 使用独立的 Pydantic model，禁止内联 `dict` 定义。

### Pydantic 校验示例
```python
from pydantic import BaseModel, Field
from typing import Literal

class CreateUserRequest(BaseModel):
    username: str = Field(min_length=3, max_length=32, pattern=r"^[a-zA-Z0-9_]+$")
    email: str = Field(max_length=255)
    role: Literal["admin", "user", "viewer"] = "user"

class CreateUserResponse(BaseModel):
    id: str
    username: str
    created_at: str
```

## 请求与响应规范
1. 列表接口必须支持分页，并限制 `page_size` 上限（建议 ≤ 100）。
2. 写接口必须定义幂等策略（幂等键、去重窗口或自然幂等）。
3. 响应格式、错误码、字段命名在同一服务内必须统一，并在契约文件中固定。
4. HTTP 响应必须使用统一包结构：`code`、`message`、`data`、`request_id`、`timestamp`。
5. 成功响应中 `code` 使用稳定成功码（如 `"OK"`），失败响应中 `code` 使用业务错误码，禁止返回原始异常文本。
6. 错误响应的 `message` 必须是可控文案，不得包含 SQL、堆栈、内部网络地址、密钥等内部细节。
7. `request_id` 必须由中间件注入并透传到响应，便于日志与链路追踪。
8. 对外时间统一使用 UTC 与明确格式（ISO 8601 或 Unix 时间戳）。
9. 必须采用语义化 HTTP 状态码：`2xx` 成功、`4xx` 客户端/业务可纠正错误、`5xx` 系统级错误。
10. 禁止对失败请求统一返回 `200` 再仅靠业务 `code` 表达错误。
11. 新建资源成功建议返回 `201 Created`，删除成功建议返回 `204 No Content`。

### HTTP 响应示例
```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "id": "u_123"
  },
  "request_id": "req_abc123",
  "timestamp": "2026-02-23T12:34:56Z"
}
```

```json
{
  "code": "USER_NOT_FOUND",
  "message": "user not found",
  "data": null,
  "request_id": "req_abc123",
  "timestamp": "2026-02-23T12:34:56Z"
}
```

### 统一响应结构示例
```python
from pydantic import BaseModel
from typing import Any

class ApiResponse(BaseModel):
    code: str = "OK"
    message: str = "success"
    data: Any = None
    request_id: str
    timestamp: str
```

## 契约治理
1. API 变更必须在同一 PR 同步更新契约文件（OpenAPI 或 Proto）与示例。
2. 若使用 Code-First（FastAPI 自动生成），必须在同一 PR 验证生成产物无漂移。
3. 契约变更需要标记兼容性级别：兼容、条件兼容、破坏性。
4. 禁止未评审发布破坏性变更。
