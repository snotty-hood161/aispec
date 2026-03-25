# rules/dotnet-server/common/configuration.md

## 配置文件组织
1. 配置目录采用 ASP.NET Core 标准结构：`appsettings.json + appsettings.{Environment}.json`。
2. `appsettings.json` 存放跨环境默认值；环境差异配置放 `appsettings.Development.json`、`appsettings.Staging.json`、`appsettings.Production.json`。
3. 环境必须通过 `ASPNETCORE_ENVIRONMENT` 或 `DOTNET_ENVIRONMENT` 显式指定，禁止依赖隐式默认环境启动生产服务。
4. 配置类统一使用 Options Pattern（`IOptions<T>` / `IOptionsSnapshot<T>` / `IOptionsMonitor<T>`），禁止在代码中直接读取 `IConfiguration` 键值。
5. 环境名称必须白名单校验（如 `Development/Staging/Production`），非法环境启动必须失败或告警。

## 配置来源与优先级
1. 推荐加载顺序（低到高）：`appsettings.json` < `appsettings.{Environment}.json` < 环境变量 < 命令行参数 < 配置中心覆盖。
2. 配置通过环境变量或配置中心注入，禁止硬编码环境差异参数。
3. 密钥类配置必须来自安全存储（Azure Key Vault / AWS Secrets Manager / 配置中心密钥管理），禁止提交到仓库。
4. `appsettings.*.json` 仅存非敏感默认值或模板，禁止存放明文密钥。
5. 当前生效环境必须在启动日志中明确输出，便于排查环境错配。

## 强类型配置（Options Pattern）
1. 每个配置节必须有对应的强类型类，使用 `[Required]` 或 FluentValidation 校验必填项。
2. 配置类必须通过 `builder.Services.AddOptions<T>().BindConfiguration("SectionName").ValidateDataAnnotations().ValidateOnStart()` 注册。
3. 启动阶段必须完成配置校验（`ValidateOnStart`），失败要快速退出并输出明确错误。
4. 示例：
   ```csharp
   public class DatabaseOptions
   {
       public const string SectionName = "Database";

       [Required]
       public string Type { get; set; } = string.Empty; // mysql 或 postgresql

       [Required]
       public string ConnectionString { get; set; } = string.Empty;

       public int MaxRetryCount { get; set; } = 3;
       public int CommandTimeoutSeconds { get; set; } = 30;
   }
   ```

## 基础设施配置约束
1. 数据库、Redis、MinIO 等外部依赖必须使用配置声明地址、凭据、超时、连接池参数，禁止代码硬编码。
2. 数据库配置必须显式声明 `Type`，且仅允许 `mysql` 或 `postgresql`（通过 Pomelo.EntityFrameworkCore.MySql 或 Npgsql.EntityFrameworkCore.PostgreSQL）。
3. 若检查到"需要配置数据库"但未明确 `Type`，必须先反馈并要求用户选择（`mysql` 或 `postgresql`），不得自行假设。
4. 超时、重试、连接池大小、并发上限必须可配置。
5. 配置项变更涉及行为变化时，必须更新文档并注明默认值。

## CORS 配置约束
1. CORS 白名单域名必须由配置加载，禁止在中间件里硬编码。
2. CORS 必须支持多域名配置（如 `AllowedOrigins` 字符串数组）。
3. 不同环境必须允许配置不同 CORS 域名集合（例如 Development 允许本地调试域名，Production 仅允许正式域名）。
4. 当 `AllowCredentials` 为 `true` 时，`AllowedOrigins` 禁止使用 `*`。

## 配置示例（appsettings.json 简化）
```json
{
  "App": {
    "Name": "admin-server"
  },
  "Database": {
    "Type": "mysql",
    "ConnectionString": "${DB_CONNECTION_STRING}",
    "MaxRetryCount": 3,
    "CommandTimeoutSeconds": 30
  },
  "Redis": {
    "ConnectionString": "${REDIS_CONNECTION_STRING}",
    "DefaultDatabase": 0,
    "ConnectTimeout": 5000
  },
  "Minio": {
    "Endpoint": "${MINIO_ENDPOINT}",
    "AccessKey": "${MINIO_ACCESS_KEY}",
    "SecretKey": "${MINIO_SECRET_KEY}",
    "Bucket": "app-assets",
    "UseSsl": true
  },
  "Cors": {
    "AllowedOrigins": [
      "https://admin.example.com",
      "https://app.example.com"
    ],
    "AllowedMethods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    "AllowedHeaders": ["Authorization", "Content-Type", "X-Request-ID"],
    "AllowCredentials": true
  }
}
```
