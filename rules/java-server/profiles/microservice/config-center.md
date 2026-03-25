# rules/java-server/profiles/microservice/config-center.md

## 文档目标
1. 定义微服务场景下配置中心选型、动态配置、热更新约束。
2. 静态配置文件规范参见 `common/configuration.md`，本文件聚焦运行时动态配置。

---

## 配置中心选型（MUST）

| 方案 | 适用场景 | 特点 |
|------|---------|------|
| **Nacos** | Spring Cloud Alibaba 生态 | 配置+注册一体、版本化、灰度推送、多格式 |
| **Apollo** | 大规模微服务、多环境多集群 | 灰度发布、权限管控、审计日志、Java 原生支持 |
| **Consul KV** | 已选 Consul 做服务注册 | 轻量 KV、Watch 机制 |
| **Spring Cloud Config** | 轻量 Git-based 配置 | Git 存储、版本化、需配合 Bus 刷新 |

1. 项目必须选定唯一的配置中心方案，禁止混用。
2. 已使用 Spring Cloud Alibaba 的项目推荐 **Nacos Config**；大规模企业级项目推荐 **Apollo**。
3. 选型必须在架构设计阶段确定并记录。
4. 配置中心不可用时，服务必须能以本地配置文件（`application.yml`）兜底启动，禁止因配置中心故障导致服务无法启动。
5. Spring Cloud 配置加载通过 `bootstrap.yml`（Spring Cloud 2021 前）或 `spring.config.import`（Spring Cloud 2021+）集成。

检查方式：架构评审
阻断级别：阻断合并

---

## 配置分类（MUST）

| 分类 | 示例 | 是否支持热更新 | 存放位置 |
|------|------|--------------|---------|
| **静态配置** | 数据库连接串、服务端口、日志级别 | 否（需重启） | 本地 `application.yml` |
| **动态配置** | 限流阈值、熔断参数、功能开关、业务规则参数 | 是（运行时生效） | 配置中心（Nacos/Apollo） |
| **敏感配置** | 数据库密码、API 密钥、JWT 密钥 | 否 | 密钥管理服务（Vault / K8s Secret） |

1. 配置必须按上述分类管理，禁止将敏感配置放入配置中心明文存储。
2. 动态配置的变更必须有审计日志（谁在什么时间改了什么值），Nacos/Apollo 默认支持。
3. 敏感配置必须通过密钥管理服务或环境变量注入，禁止硬编码或写入配置文件。

检查方式：配置审查
阻断级别：阻断合并

---

## 热更新规范（MUST）

1. 支持热更新的配置项必须显式标注。Nacos 通过 `@RefreshScope` + `@Value` 或 `@ConfigurationProperties` 实现动态刷新。
2. 热更新回调必须是线程安全的，更新过程中禁止出现中间态影响业务逻辑。
3. 热更新后必须记录日志：配置项名称、旧值、新值、生效时间。
4. 连接池参数（数据库、Redis）等涉及资源重建的配置，禁止热更新，必须重启生效。
5. 配置变更必须支持回滚：配置中心必须保留历史版本，可一键回退到上一版本（Nacos/Apollo 默认支持）。
6. `@RefreshScope` Bean 在刷新时会被销毁重建，包含状态的 Bean 禁止使用 `@RefreshScope`。

### Nacos 动态配置示例

```java
@RefreshScope
@RestController
public class ConfigDemoController {

    @Value("${app.feature.rate-limit:100}")
    private int rateLimitThreshold;

    @GetMapping("/config/rate-limit")
    public int getRateLimit() {
        return rateLimitThreshold;
    }
}
```

### SHOULD
1. 动态配置变更支持灰度推送（先推送部分实例，观察后再全量），Nacos 支持 Beta 发布。
2. 关键配置变更触发告警通知相关负责人。

检查方式：代码审查 + 配置中心审计日志
阻断级别：阻断合并

---

## 功能开关（Feature Flag）（SHOULD）

1. 新功能上线推荐使用功能开关，存储在配置中心，支持运行时启停，降低发布风险。
2. 功能开关必须有明确的生命周期：创建 → 灰度 → 全量 → 清理代码。
3. 功能全量上线后，必须在下一个版本中清理开关代码和配置中心中的开关项，禁止长期保留无用开关。
4. 功能开关的状态必须可观测（监控面板可查看当前开启的开关列表）。
5. 功能开关命名规范：`feature.{模块}.{功能名}.enabled`，如 `feature.order.express-checkout.enabled`。

检查方式：代码审查
阻断级别：告警记录

---

## 多环境配置管理（MUST）

1. 配置中心必须按环境隔离命名空间（Nacos Namespace / Apollo Environment），禁止多环境共用同一配置空间。
2. 配置项命名规范统一：按 `spring.xxx` 标准命名或 `app.{模块}.{配置项}` 自定义命名。
3. 每个环境的配置必须独立审查和发布，禁止开发环境配置直接推送到生产环境。
4. 配置中心访问必须有权限管控：开发人员可读写开发环境，生产环境仅运维/负责人可写。

检查方式：配置中心权限审查
阻断级别：阻断合并
