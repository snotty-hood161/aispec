# rules/java-server/common/api-design.md

## API 版本与兼容

### MUST
1. HTTP API 必须版本化（例如 `/api/v1`），破坏性变更必须升级版本。
2. 版本号通过 URL 路径前缀管理（推荐 `/api/v1`），禁止使用 Header 或查询参数传递版本。
3. 对外字段语义必须稳定，禁止直接透传数据库字段名或内部枚举值。
4. gRPC/事件契约必须显式版本目录或命名空间（例如 `order.v1`）。

## 文档与契约（MUST）

1. HTTP API 必须使用 Swagger/OpenAPI 3.x 作为文档标准。
2. 推荐使用 `springdoc-openapi`（Spring Boot 3.x）或 `springfox`（Spring Boot 2.x）自动生成文档。
3. Controller 方法必须标注 `@Operation(summary = "")` 提供接口说明。
4. 请求/响应 DTO 字段必须标注 `@Schema(description = "")` 提供字段说明。
5. 同一服务必须明确一种契约来源（Code-First 或 Contract-First），禁止同一接口双源维护。
6. API 文档端点（`/swagger-ui.html` 或 `/v3/api-docs`）生产环境必须禁用或加鉴权保护。

### SHOULD
1. 使用 `@Tag` 对 Controller 进行分组，提升文档可读性。
2. 示例值通过 `@Schema(example = "")` 提供，便于前端联调。

## 请求与响应规范

### MUST
1. 列表接口必须支持分页，并限制 `pageSize` 上限（建议 ≤ 100）。
2. 写接口必须定义幂等策略（幂等键、去重窗口或自然幂等）。
3. 响应格式、错误码、字段命名在同一服务内必须统一，通过统一响应包装类实现。
4. HTTP 响应必须使用统一包结构：`code`、`message`、`data`、`requestId`、`timestamp`。
5. 成功响应中 `code` 使用稳定成功码（如 `OK`），失败响应中 `code` 使用业务错误码，禁止返回原始系统异常信息。
6. 错误响应的 `message` 必须是可控文案，不得包含 SQL、堆栈、内部网络地址、密钥等内部细节。
7. `requestId` 必须由 Filter/Interceptor 注入并透传到响应，便于日志与链路追踪。
8. 对外时间统一使用 UTC 与明确格式（ISO 8601 或 Unix 时间戳），使用 `java.time` API。
9. 必须采用语义化 HTTP 状态码：`2xx` 成功、`4xx` 客户端/业务可纠正错误、`5xx` 系统级错误。
10. 禁止对失败请求统一返回 `200` 再仅靠业务 `code` 表达错误。
11. 新建资源成功建议返回 `201 Created`，删除成功建议返回 `204 No Content`（无响应体场景）。

### HTTP 响应示例
```json
{
  "code": "OK",
  "message": "success",
  "data": {
    "id": "u_123"
  },
  "requestId": "req_abc123",
  "timestamp": "2026-02-23T12:34:56Z"
}
```

```json
{
  "code": "USER_NOT_FOUND",
  "message": "用户不存在",
  "data": null,
  "requestId": "req_abc123",
  "timestamp": "2026-02-23T12:34:56Z"
}
```

## 请求参数校验（MUST）
1. Controller 方法参数必须使用 `@Valid` / `@Validated` 触发 Bean Validation。
2. DTO 字段必须标注校验注解（`@NotNull`、`@Size`、`@Pattern`、`@Min`、`@Max` 等）。
3. 嵌套对象校验必须使用 `@Valid` 级联。
4. 自定义校验逻辑使用自定义 `ConstraintValidator`，禁止在 Controller 中手写 if-else 校验。
5. 校验失败必须返回 `400 Bad Request`，响应体中列出具体字段和错误信息。

## 契约治理

### MUST
1. API 变更必须在同一 PR 同步更新契约文件（OpenAPI 生成或 Proto）。
2. 若使用 Code-First，必须在 CI 中验证生成的 OpenAPI 文档与代码一致。
3. 契约变更需要标记兼容性级别：兼容、条件兼容、破坏性。
4. 禁止未评审发布破坏性变更。
5. 废弃接口必须标注 `@Deprecated` 并在文档中说明替代方案和下线时间。
