# rules/java-server/profiles/microservice/security-communication.md

## 文档目标
1. 定义微服务间安全通信约束。通用安全规范参见 `common/security.md`。

---

## 传输加密（MUST）

1. 服务间内部通信必须使用 **mTLS（双向 TLS）** 或等效加密方案，禁止明文传输。
2. 使用 Service Mesh（如 Istio）时，mTLS 由 Sidecar 自动处理，无需应用层实现。
3. 非 Service Mesh 环境下：
   - HTTP 内部调用必须使用 HTTPS（配置 `server.ssl.*`）。
   - gRPC 必须配置 TLS 证书。
   - Feign Client 必须配置 SSL 上下文（`OkHttpClient` 或 `Apache HttpClient` 的 SSL 配置）。
4. 证书管理推荐使用 Vault PKI 或 cert-manager（K8s），禁止使用自签证书且无轮换机制。

检查方式：安全审查 + 网络扫描
阻断级别：阻断合并

---

## 服务间认证（MUST）

1. 推荐方案：
   - **mTLS 证书认证**：双方持有 CA 签发的证书，在 TLS 握手阶段完成认证。
   - **JWT Token 认证**：调用方携带内部签发的服务间 Token（通过 Feign Interceptor 自动注入）。
   - **OAuth2 Client Credentials**：服务间使用 Client ID + Client Secret 获取 Token。
2. 服务间 Token 必须与用户 Token 分离，使用独立签发机制和校验逻辑。
3. 服务间 Token 必须设置较短有效期（建议 ≤ 5 分钟），支持自动刷新。
4. 敏感数据在服务间传输时必须加密或脱敏，禁止明文透传用户密码、身份证号等。
5. 网关传递给下游的用户身份 Header（如 `X-User-Id`）必须仅在内部网络可信，网关层必须清洗外部伪造的同名 Header。

### 服务间 Token 注入示例

```java
@Component
public class InternalAuthInterceptor implements RequestInterceptor {
    private final InternalTokenProvider tokenProvider;

    public InternalAuthInterceptor(InternalTokenProvider tokenProvider) {
        this.tokenProvider = tokenProvider;
    }

    @Override
    public void apply(RequestTemplate template) {
        template.header("X-Internal-Token", tokenProvider.generateServiceToken());
    }
}
```

检查方式：安全审查
阻断级别：阻断合并

---

## 内部网络安全（MUST）

1. 微服务间通信必须限制在内部网络（VPC / K8s 集群网络），禁止暴露内部服务端口到公网。
2. 内部服务端口通过 Network Policy（K8s）或安全组限制访问来源。
3. 管理端口（Actuator、JMX）必须与业务端口分离，且仅允许运维网络访问。
4. 数据库、Redis、消息队列等中间件端口禁止暴露到公网，仅允许内部服务网络访问。

### SHOULD
1. 启用 Service Mesh（Istio / Linkerd）统一管理 mTLS 和服务间认证，降低应用层安全实现复杂度。
2. 定期扫描内部网络，检测未授权暴露的端口和服务。
3. 微服务间调用日志中记录调用方服务名（通过 Token 或证书中的 Subject），便于审计和排查。

检查方式：网络安全审查
阻断级别：阻断合并
