# rules/dotnet-server/common/api-design.md

## API 版本与兼容
1. HTTP API 必须版本化（例如 `/api/v1`），破坏性变更必须升级版本。推荐使用 `Asp.Versioning.Http`（原 `Microsoft.AspNetCore.Mvc.Versioning`）。
2. gRPC/事件契约必须显式版本目录或命名空间（例如 `Order.V1`）。
3. 对外字段语义必须稳定，禁止直接透传数据库字段名或内部枚举。

## 文档形式与目录约定
1. HTTP 契约默认使用 OpenAPI 3.x 作为文档标准，推荐使用 Swagger/Swashbuckle 或 NSwag 自动生成。
2. gRPC 契约默认使用 `proto3`，以 `.proto` 文件作为契约源。
3. 单体应用默认将 OpenAPI 文档通过 `/swagger` 端点暴露，生产环境须通过配置控制是否启用。
4. 微服务默认将 gRPC 契约源放在 `Protos/` 目录。
5. 同一服务必须明确一种契约主来源（Contract-First 或 Code-First），禁止同一接口双源维护。

## 请求与响应规范
1. 列表接口必须支持分页，并限制 `PageSize` 上限。
2. 写接口必须定义幂等策略（幂等键、去重窗口或自然幂等）。
3. 响应格式、错误码、字段命名在同一服务内必须统一，并在契约文件中固定。
4. HTTP 响应必须使用统一包结构：`code`、`message`、`data`、`requestId`、`timestamp`。
5. 成功响应中 `code` 使用稳定成功码（如 `OK`），失败响应中 `code` 使用业务错误码，禁止返回原始系统异常文本。
6. 错误响应的 `message` 必须是可控文案，不得包含 SQL、堆栈、内部网络地址、密钥等内部细节。
7. `requestId` 必须由中间件注入并透传到响应，便于日志与链路追踪（推荐使用 `HttpContext.TraceIdentifier` 或自定义中间件）。
8. 对外时间统一使用 UTC 与明确格式（ISO 8601 或 Unix 时间戳）。
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

### 统一响应结构定义示例
```csharp
/// <summary>
/// 统一 API 响应结构
/// </summary>
public record ApiResponse<T>
{
    public string Code { get; init; } = "OK";
    public string Message { get; init; } = "success";
    public T? Data { get; init; }
    public string RequestId { get; init; } = string.Empty;
    public DateTime Timestamp { get; init; } = DateTime.UtcNow;
}
```

## 契约治理
1. API 变更必须在同一 PR 同步更新契约文件（OpenAPI 或 Proto）与示例。
2. 若使用 Code-First，必须在同一 PR 提交生成后的契约产物，并保证生成前后无漂移。
3. 契约变更需要标记兼容性级别：兼容、条件兼容、破坏性。
4. 禁止未评审发布破坏性变更。

## 参数校验
1. 请求参数校验推荐使用 FluentValidation 或 DataAnnotations，禁止在 Service 层手动校验请求格式。
2. 校验失败必须返回 `400 Bad Request`，响应中包含具体字段错误信息。
3. 校验规则必须集中定义（Validator 类或 Attribute），禁止在 Controller Action 中散写。
