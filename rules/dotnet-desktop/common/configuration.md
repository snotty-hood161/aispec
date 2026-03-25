# rules/dotnet-desktop/common/configuration.md

## 配置分类

| 类别 | 说明 | 存储位置 | 示例 |
|------|------|---------|------|
| **应用配置** | 开发者预设，用户不可改 | `appsettings.json`（随应用分发） | API 地址、日志级别、功能开关 |
| **用户设置** | 用户个性化偏好 | 用户数据目录 JSON/XML | 窗口位置、主题、语言、最近打开文件 |
| **凭据/密钥** | 认证令牌、API Key | 系统安全存储 | JWT Token、OAuth Refresh Token |

## 应用配置（MUST）

1. 应用配置使用 `Microsoft.Extensions.Configuration`，支持 `appsettings.json` + 环境变量。
2. 配置项使用 Options Pattern（`IOptions<T>`）绑定到强类型类，禁止在代码中直接读取 `IConfiguration` 键值。
3. `appsettings.json` 随应用分发，仅存非敏感默认值。
4. 不同环境（开发/测试/生产）的 API 地址等差异配置通过 `appsettings.{Environment}.json` 或构建时替换管理。

### 配置示例
```json
{
  "Api": {
    "BaseUrl": "https://api.example.com",
    "Timeout": 30
  },
  "Logging": {
    "MinLevel": "Information",
    "FilePath": "logs/app.log"
  },
  "Features": {
    "EnableAutoSave": true,
    "AutoSaveIntervalSeconds": 60
  }
}
```

## 用户设置（MUST）

1. 用户设置必须持久化到用户数据目录（`Environment.SpecialFolder.LocalApplicationData`），禁止存储在注册表（可移植性差）或程序安装目录（权限问题）。
2. 用户设置读写必须封装为独立服务（`IUserSettingsService`），ViewModel 和 Service 通过接口访问。
3. 用户设置文件格式推荐 JSON（可读性好、易于调试），禁止使用二进制格式。
4. 用户设置变更必须持久化到磁盘（可在变更时立即保存或应用退出时批量保存）。
5. 用户设置文件损坏或不存在时，必须回退到默认值并重建，禁止应用崩溃。

### 用户设置服务示例
```csharp
public interface IUserSettingsService
{
    UserSettings Load();
    Task SaveAsync(UserSettings settings);
}

public class UserSettings
{
    public double WindowLeft { get; set; } = 100;
    public double WindowTop { get; set; } = 100;
    public double WindowWidth { get; set; } = 1280;
    public double WindowHeight { get; set; } = 720;
    public string Theme { get; set; } = "Light";
    public string Language { get; set; } = "zh-CN";
    public List<string> RecentFiles { get; set; } = new();
}
```

## 凭据与密钥存储（MUST）

1. 认证令牌、API Key、OAuth Token 禁止存储在 `appsettings.json` 或明文文件中。
2. Windows 平台推荐使用 Windows Credential Manager（`Windows.Security.Credentials.PasswordVault`）或 DPAPI（`ProtectedData`）。
3. 跨平台应用推荐使用 `Microsoft.AspNetCore.DataProtection` 或平台 Keychain API。
4. Token 过期后必须自动刷新（Refresh Token 机制），刷新失败时提示用户重新登录。
5. 用户注销时必须清除本地存储的所有凭据。

## 环境管理（MUST）

1. 桌面应用必须区分至少两个环境：`Development`（开发调试）和 `Production`（正式发布）。
2. 开发环境可以启用详细日志、调试工具面板、Mock 数据。
3. 生产环境必须禁用调试功能、降低日志级别、指向生产 API。
4. 环境切换通过构建配置（`Debug` / `Release`）或启动参数控制，禁止运行时手动切换。
