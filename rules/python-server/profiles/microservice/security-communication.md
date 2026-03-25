# rules/python-server/profiles/microservice/security-communication.md

## 文档目标
1. 定义微服务间安全通信约束。通用安全规范参见 `common/security.md`。

---

## 传输加密（MUST）

1. 服务间内部通信必须使用 **mTLS（双向 TLS）** 或等效加密方案，禁止明文传输。
2. 使用 Service Mesh（如 Istio、Linkerd）时，mTLS 由 Sidecar 自动处理，无需应用层实现。
3. 非 Service Mesh 环境下，gRPC 必须配置 TLS 证书；HTTP 内部调用必须使用 HTTPS。
4. Python gRPC 服务使用 `grpcio` 时，MUST 配置 `ssl_channel_credentials` / `server_credentials`。
5. `httpx.AsyncClient` 内部调用 MUST 配置 `verify=True`（生产环境），禁止 `verify=False` 跳过证书验证。

### gRPC TLS 配置示例
```python
import grpc

credentials = grpc.ssl_channel_credentials(
    root_certificates=ca_cert,
    private_key=client_key,
    certificate_chain=client_cert,
)
channel = grpc.aio.secure_channel("user-svc:50051", credentials)
```

检查方式：安全审查 + 网络扫描
阻断级别：阻断合并

---

## 服务间认证（MUST）

1. 推荐方案：
   - **mTLS 证书认证**：双方持有 CA 签发的证书。
   - **JWT Token 认证**：调用方携带内部签发的服务间 Token。
   - **API Key 认证**：轻量级场景，调用方携带预共享密钥。
2. 服务间 Token 必须与用户 Token 分离，使用独立签发机制和校验逻辑。
3. 敏感数据在服务间传输时必须加密或脱敏，禁止明文透传。
4. 服务间调用必须携带调用方身份标识（如 `x-caller-service` Header），便于审计和追踪。

### 服务间 JWT 认证示例
```python
import httpx

async def call_order_service(order_id: int, service_token: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://order-svc:8000/api/v1/orders/{order_id}",
            headers={
                "Authorization": f"Bearer {service_token}",
                "X-Caller-Service": "user-svc",
            },
            timeout=10.0,
        )
        response.raise_for_status()
        return response.json()
```

检查方式：安全审查
阻断级别：阻断合并

---

## 网络隔离（SHOULD）

1. 微服务之间推荐使用网络策略（K8s NetworkPolicy / 安全组）限制通信范围。
2. 数据库、Redis、消息队列等基础设施禁止暴露到公网，仅允许内网访问。
3. 不同环境（dev / staging / prod）的网络必须隔离，禁止跨环境直接访问。

检查方式：网络配置审查
阻断级别：告警记录

---

## 密钥与证书管理（MUST）

1. TLS 证书和私钥禁止硬编码或提交到代码仓库，必须通过密钥管理服务（Vault / K8s Secret）注入。
2. 证书必须设置有效期，到期前自动轮换或告警。
3. 服务间共享密钥必须定期轮换（建议 ≤ 90 天），轮换期间必须支持新旧密钥并存。
4. 推荐使用 `cert-manager`（K8s 环境）自动管理 TLS 证书的签发和续期。

检查方式：安全审查
阻断级别：阻断合并
