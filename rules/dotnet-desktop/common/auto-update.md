# rules/dotnet-desktop/common/auto-update.md

## 文档目标
1. 定义 C#/.NET 桌面应用自动更新规范，实现"检测新版本 → 提示用户 → 自动下载安装 → 重启即用"的体验。
2. 禁止要求用户手动访问官网下载安装包。

---

## 更新框架选型（MUST）

| 方案 | 增量更新 | 跨平台 | 托管要求 | 推荐度 |
|------|---------|--------|---------|--------|
| **Velopack** | 支持（Rust diff 算法） | Win/Mac/Linux | 静态文件服务即可 | **首选** |
| MSIX App Installer | 支持 | 仅 Windows 10+ | 静态文件/CDN | Win10+ 专属备选 |

1. 新项目必须使用 **Velopack** 作为自动更新框架。
2. 禁止自行实现更新逻辑（下载 zip → 解压覆盖），安全性和可靠性无法保证。
3. 禁止使用"跳转浏览器下载"方式作为更新手段。

---

## 更新体验要求（MUST）

### 用户视角的完整流程
```
应用启动 → 后台静默检查新版本 → 发现新版本 → 弹出更新提示（版本号 + 更新内容）
→ 用户点击"立即更新" → 显示下载进度 → 下载完成 → 自动退出并安装 → 用户重新打开即可使用
```

### 体验约束
1. 检查更新必须在后台异步执行，禁止阻塞应用启动或 UI 交互。
2. 更新提示必须展示：新版本号、更新内容摘要、"立即更新"和"稍后提醒"两个选项。
3. 下载过程必须展示进度条（百分比），让用户知道进度。
4. 下载完成后自动退出当前应用、执行安装、用户重新打开即为新版本。
5. 更新失败（网络中断、磁盘不足等）必须提示用户，不影响当前版本正常使用。
6. 增量更新优先：仅下载版本差异部分，减少下载量和等待时间。

---

## Velopack 集成规范（MUST）

### 第 1 步：安装依赖

```bash
# NuGet 包
dotnet add package Velopack

# CLI 工具（CI/CD 打包用）
dotnet tool install -g vpk
```

### 第 2 步：应用启动入口初始化

必须在应用最开始调用 `VelopackApp.Build().Run()`，处理安装/卸载/更新钩子。

```csharp
// WPF: App.xaml.cs
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        // 必须最先调用 — 处理 Velopack 安装/更新/卸载钩子
        VelopackApp.Build()
            .WithFirstRun(v => { /* 首次安装后的逻辑 */ })
            .Run();

        base.OnStartup(e);
    }
}
```

### 第 3 步：实现更新服务

```csharp
/// <summary>
/// 自动更新服务接口
/// </summary>
public interface IAppUpdateService
{
    /// <summary>
    /// 后台检查更新，发现新版本时通过回调通知 UI
    /// </summary>
    Task CheckForUpdateAsync(CancellationToken ct = default);
}
```

```csharp
public class VelopackUpdateService : IAppUpdateService
{
    private readonly ILogger<VelopackUpdateService> _logger;
    private readonly IDialogService _dialogService;
    private readonly UpdateManager _updateManager;

    public VelopackUpdateService(
        ILogger<VelopackUpdateService> logger,
        IDialogService dialogService,
        IOptions<UpdateOptions> options)
    {
        _logger = logger;
        _dialogService = dialogService;
        _updateManager = new UpdateManager(options.Value.UpdateUrl);
    }

    public async Task CheckForUpdateAsync(CancellationToken ct)
    {
        // 开发模式下跳过更新检查
        if (!_updateManager.IsInstalled)
        {
            _logger.LogDebug("开发模式，跳过更新检查");
            return;
        }

        try
        {
            // 1. 检查新版本
            var update = await _updateManager.CheckForUpdatesAsync();
            if (update == null)
            {
                _logger.LogInformation("当前已是最新版本 {Version}",
                    _updateManager.CurrentVersion);
                return;
            }

            _logger.LogInformation("发现新版本: {NewVersion}，当前: {Current}",
                update.TargetFullRelease.Version,
                _updateManager.CurrentVersion);

            // 2. 提示用户
            var userChoice = await _dialogService.ShowUpdateDialogAsync(
                newVersion: update.TargetFullRelease.Version.ToString(),
                releaseNotes: update.TargetFullRelease.Body ?? "性能优化与问题修复");

            if (userChoice != UpdateChoice.UpdateNow)
                return;

            // 3. 下载（带进度）
            await _updateManager.DownloadUpdatesAsync(update, progress =>
            {
                _dialogService.UpdateDownloadProgress(progress);
            });

            // 4. 退出并安装，用户重新打开即为新版本
            _updateManager.ApplyUpdatesAndRestart(update);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "检查更新失败，不影响正常使用");
        }
    }
}
```

### 第 4 步：在主窗口启动后触发检查

```csharp
public partial class MainWindowViewModel : ObservableObject
{
    private readonly IAppUpdateService _updateService;

    [RelayCommand]
    private async Task OnWindowLoadedAsync()
    {
        // 正常加载业务数据
        await LoadDataAsync();

        // 后台静默检查更新（不阻塞 UI）
        _ = Task.Run(() => _updateService.CheckForUpdateAsync());
    }
}
```

### 第 5 步：DI 注册与配置

```csharp
// Program.cs / App.xaml.cs
services.AddSingleton<IAppUpdateService, VelopackUpdateService>();
services.Configure<UpdateOptions>(config.GetSection("Update"));
```

```json
// appsettings.json
{
  "Update": {
    "UpdateUrl": "https://your-oss-bucket.com/releases/myapp/"
  }
}
```

---

## 构建与发布流程（MUST）

### 本地打包

```bash
# 1. 发布应用
dotnet publish -c Release -r win-x64 --self-contained -o ./publish

# 2. 首次打包（无增量）
vpk pack --packId MyApp --packVersion 1.0.0 --packDir ./publish --mainExe MyApp.exe

# 3. 后续版本打包（自动生成增量包）
#    先下载上一版本的包到 releases 目录，vpk 自动计算 delta
vpk download http --url https://your-oss-bucket.com/releases/myapp/
vpk pack --packId MyApp --packVersion 1.1.0 --packDir ./publish --mainExe MyApp.exe
```

### 产物说明

```text
releases/
├── MyApp-1.1.0-full.nupkg          # 全量包（新用户安装 / 增量失败回退）
├── MyApp-1.1.0-delta.nupkg         # 增量包（仅差异，通常几百 KB）
├── MyApp-Setup.exe                  # 安装程序（分发给新用户）
├── MyApp-Portable.zip               # 免安装版（可选）
└── releases.win.json                # 版本索引（UpdateManager 读取此文件）
```

### 上传到文件服务

```bash
# 上传到阿里云 OSS / MinIO / S3 等对象存储
# 只需上传以下文件：
#   releases.win.json
#   MyApp-1.1.0-full.nupkg
#   MyApp-1.1.0-delta.nupkg
#   MyApp-Setup.exe（供新用户首次下载）
```

### CI/CD 集成示例（GitHub Actions）

```yaml
- name: Publish
  run: dotnet publish -c Release -r win-x64 --self-contained -o ./publish

- name: Download previous release
  run: vpk download github --repoUrl ${{ github.repository }} --token ${{ secrets.GITHUB_TOKEN }}

- name: Pack
  run: vpk pack --packId MyApp --packVersion ${{ env.VERSION }} --packDir ./publish --mainExe MyApp.exe

- name: Upload to GitHub Releases
  run: vpk upload github --repoUrl ${{ github.repository }} --tag v${{ env.VERSION }} --token ${{ secrets.GITHUB_TOKEN }}
```

---

## 托管方案（MUST）

| 方案 | 成本 | 适用场景 |
|------|------|---------|
| **阿里云 OSS / 腾讯云 COS** | 极低 | 国内用户，速度快 |
| **MinIO（自建）** | 服务器成本 | 内网/私有化部署 |
| **GitHub Releases** | 免费 | 开源项目 |
| **AWS S3 / Azure Blob** | 低 | 海外用户 |

1. 更新文件托管只需静态文件服务，不需要专门的更新服务器。
2. `releases.{channel}.json` 是 UpdateManager 发现新版本的唯一入口，必须与实际包文件保持同步。
3. 建议配置 CDN 加速下载，提升用户体验。

---

## 安全约束（MUST）

1. 发布产物必须进行代码签名（Authenticode Signing），防止 Windows SmartScreen 拦截和篡改。
2. 更新包传输必须使用 HTTPS，禁止 HTTP 明文传输。
3. Velopack 内置包完整性校验，禁止绕过或禁用。
4. 更新服务 URL 必须通过配置管理，禁止硬编码。

---

## 禁止事项

1. 禁止要求用户手动访问官网下载安装包进行更新。
2. 禁止自行实现"下载 zip → 解压覆盖"的更新逻辑。
3. 禁止更新检查阻塞应用启动或 UI 交互。
4. 禁止更新失败导致应用不可用（必须可继续使用当前版本）。
5. 禁止跳过代码签名直接分发更新包。
