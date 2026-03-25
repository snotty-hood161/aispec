# rules/electron-desktop/common/auto-update.md

## 文档目标
1. 定义 Electron 桌面应用自动更新规范，实现"检测新版本 → 提示用户 → 自动下载安装 → 重启即用"的体验。
2. 禁止要求用户手动访问官网下载安装包。

---

## 更新框架选型（MUST）

| 方案 | 签名验证 | 跨平台 | 增量更新 | 推荐度 |
|------|---------|--------|---------|--------|
| **electron-updater** | 内置代码签名 | Win/Mac/Linux | 支持（差量） | **首选** |

1. Electron 项目必须使用 **electron-updater**（`electron-builder` 配套）作为自动更新方案。
2. 禁止自行实现更新逻辑（下载 zip → 解压覆盖），安全性和可靠性无法保证。
3. 禁止使用"跳转浏览器下载"方式作为更新手段。

---

## 更新体验要求（MUST）

### 用户视角的完整流程
```
应用启动 → 后台静默检查新版本 → 发现新版本 → 弹出更新提示（版本号 + 更新内容）
→ 用户点击"立即更新" → 显示下载进度 → 下载完成 → 退出并安装 → 重新打开即可使用
```

### 体验约束
1. 检查更新必须在后台异步执行，禁止阻塞应用启动或 UI 交互。
2. 更新提示必须展示：新版本号、更新内容摘要、"立即更新"和"稍后提醒"两个选项。
3. 下载过程必须展示进度条（百分比 + 已下载/总大小），让用户知道进度。
4. 下载完成后退出当前应用、执行安装、用户重新打开即为新版本。
5. 更新失败（网络中断、签名校验失败等）必须提示用户，不影响当前版本正常使用。

---

## electron-updater 集成规范（MUST）

### 主进程实现

```typescript
import { autoUpdater } from 'electron-updater';
import log from 'electron-log';

autoUpdater.logger = log;
autoUpdater.autoDownload = false;
autoUpdater.autoInstallOnAppQuit = true;

export function initAutoUpdater(mainWindow: BrowserWindow): void {
  autoUpdater.on('update-available', (info) => {
    mainWindow.webContents.send('update:available', {
      version: info.version,
      releaseNotes: info.releaseNotes,
      releaseDate: info.releaseDate,
    });
  });

  autoUpdater.on('download-progress', (progress) => {
    mainWindow.webContents.send('update:progress', {
      percent: Math.round(progress.percent),
      transferred: progress.transferred,
      total: progress.total,
    });
  });

  autoUpdater.on('update-downloaded', () => {
    mainWindow.webContents.send('update:downloaded');
  });

  autoUpdater.on('error', (error) => {
    log.error('自动更新错误:', error);
    mainWindow.webContents.send('update:error', error.message);
  });
}

export function checkForUpdates(): void {
  autoUpdater.checkForUpdates();
}

export function downloadUpdate(): void {
  autoUpdater.downloadUpdate();
}

export function installUpdate(): void {
  autoUpdater.quitAndInstall(false, true);
}
```

### electron-builder 配置

```yaml
# electron-builder.yml
publish:
  provider: generic
  url: https://releases.yourapp.com/
  channel: latest
```

### IPC handler 注册

```typescript
ipcMain.handle('update:check', () => checkForUpdates());
ipcMain.handle('update:download', () => downloadUpdate());
ipcMain.handle('update:install', () => installUpdate());
```

---

## 更新服务端配置（MUST）

### 托管方案

| 方案 | 成本 | 适用场景 |
|------|------|---------|
| **阿里云 OSS / 腾讯云 COS** | 极低 | 国内用户，速度快 |
| **GitHub Releases** | 免费 | 开源项目 |
| **自建 API 服务** | 服务器成本 | 需要灰度发布、AB 测试 |
| **AWS S3 + CloudFront** | 低 | 海外用户 |

### 静态文件托管方案（最简）

```text
releases/
├── latest.yml               # Windows 最新版本信息
├── latest-mac.yml            # macOS 最新版本信息
├── latest-linux.yml          # Linux 最新版本信息
├── MyApp-1.2.0-setup.exe     # Windows 安装包
├── MyApp-1.2.0.dmg           # macOS 安装包
└── MyApp-1.2.0.AppImage      # Linux 安装包
```

---

## 安全约束（MUST）

1. 更新包必须经过代码签名验证，`electron-updater` 内置校验，禁止绕过。
2. 签名证书/密钥必须安全存储在 CI/CD Secret 中，禁止提交到版本控制。
3. 更新端点必须使用 HTTPS，禁止 HTTP 明文传输。
4. 更新服务 URL 通过构建配置管理，禁止硬编码在业务代码中。

---

## 禁止事项

1. 禁止要求用户手动访问官网下载安装包进行更新。
2. 禁止自行实现"下载 zip → 解压覆盖"的更新逻辑。
3. 禁止更新检查阻塞应用启动或 UI 交互。
4. 禁止更新失败导致应用不可用（必须可继续使用当前版本）。
5. 禁止跳过签名验证直接分发更新包。
6. 禁止将签名密钥硬编码在源码或配置文件中。
