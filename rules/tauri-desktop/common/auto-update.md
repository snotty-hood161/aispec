# rules/tauri-desktop/common/auto-update.md

## 文档目标
1. 定义 Tauri 桌面应用自动更新规范，实现"检测新版本 → 提示用户 → 自动下载安装 → 重启即用"的体验。
2. 禁止要求用户手动访问官网下载安装包。

---

## 更新框架选型（MUST）

| 方案 | 签名验证 | 跨平台 | 增量更新 | 推荐度 |
|------|---------|--------|---------|--------|
| **tauri-plugin-updater** | 内置 Ed25519 | Win/Mac/Linux | 支持（NSIS） | **首选** |

1. Tauri 项目必须使用 **tauri-plugin-updater** 作为自动更新方案。
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
3. 下载过程必须展示进度条（百分比 + 已下载/总大小），让用户知道进度。
4. 下载完成后自动退出当前应用、执行安装、用户重新打开即为新版本。
5. 更新失败（网络中断、签名校验失败等）必须提示用户，不影响当前版本正常使用。

---

## Tauri Updater 集成规范（MUST）

### 第 1 步：生成签名密钥

```bash
# 生成 Ed25519 密钥对（仅首次执行）
tauri signer generate -w ~/.tauri/myapp.key
# 输出：
#   私钥保存到 ~/.tauri/myapp.key（CI/CD 中作为密钥管理）
#   公钥输出到终端（配置到 tauri.conf.json）
```

1. 私钥必须安全存储（CI/CD Secret），禁止提交到版本控制。
2. 公钥配置到 `tauri.conf.json` 的 `plugins.updater.pubkey`。

### 第 2 步：配置 tauri.conf.json

```json
{
  "bundle": {
    "createUpdaterArtifacts": "v1Compatible"
  },
  "plugins": {
    "updater": {
      "pubkey": "dW50cnVzdGVkIGNvbW1lbnQ6...(你的公钥内容)",
      "endpoints": [
        "https://releases.yourapp.com/{{target}}/{{arch}}/{{current_version}}"
      ]
    }
  }
}
```

- `{{target}}`：平台标识（`windows-x86_64`、`darwin-aarch64`、`linux-x86_64`）
- `{{arch}}`：架构标识
- `{{current_version}}`：当前应用版本号

### 第 3 步：添加插件依赖

```bash
# Rust 侧
cargo add tauri-plugin-updater

# 前端侧
npm add @tauri-apps/plugin-updater @tauri-apps/plugin-process
```

```rust
// src-tauri/src/lib.rs 或 main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_updater::Builder::new().build())
        .plugin(tauri_plugin_process::init())
        // ...
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 第 4 步：前端实现更新检查与安装

```typescript
import { check } from '@tauri-apps/plugin-updater';
import { relaunch } from '@tauri-apps/plugin-process';

export async function checkForUpdate(): Promise<void> {
  try {
    const update = await check();
    if (!update) {
      console.log('当前已是最新版本');
      return;
    }

    console.log(`发现新版本: ${update.version}`);
    console.log(`更新内容: ${update.body}`);

    // 展示更新对话框，获取用户选择
    const userChoice = await showUpdateDialog({
      version: update.version,
      releaseNotes: update.body ?? '性能优化与问题修复',
      date: update.date,
    });

    if (userChoice !== 'update-now') return;

    // 下载并安装（带进度回调）
    let totalSize = 0;
    let downloaded = 0;

    await update.downloadAndInstall((event) => {
      switch (event.event) {
        case 'Started':
          totalSize = event.data.contentLength ?? 0;
          console.log(`开始下载，总大小: ${totalSize}`);
          break;
        case 'Progress':
          downloaded += event.data.chunkLength;
          const percent = totalSize > 0
            ? Math.round((downloaded / totalSize) * 100)
            : 0;
          updateProgressBar(percent, downloaded, totalSize);
          break;
        case 'Finished':
          console.log('下载完成');
          break;
      }
    });

    // 重启应用
    await relaunch();
  } catch (error) {
    console.error('检查更新失败:', error);
    showErrorNotification('检查更新失败，不影响正常使用');
  }
}
```

### 第 5 步（可选）：Rust 侧实现更新检查

如果更新逻辑需要在 Rust 侧控制（如定时检查、后台静默更新）：

```rust
use tauri_plugin_updater::UpdaterExt;

#[tauri::command]
async fn check_update(app: tauri::AppHandle) -> Result<Option<UpdateInfo>, AppError> {
    let updater = app.updater()
        .map_err(|e| AppError::Internal(e.to_string()))?;

    match updater.check().await {
        Ok(Some(update)) => {
            tracing::info!("发现新版本: {}", update.version);
            Ok(Some(UpdateInfo {
                version: update.version.clone(),
                body: update.body.clone(),
                date: update.date.clone(),
            }))
        }
        Ok(None) => {
            tracing::info!("当前已是最新版本");
            Ok(None)
        }
        Err(e) => {
            tracing::warn!("检查更新失败: {:?}", e);
            Err(AppError::Network(e.to_string()))
        }
    }
}
```

---

## 更新服务端配置（MUST）

### 服务端响应格式

更新端点必须返回以下 JSON 格式（有新版本时返回 200，无新版本时返回 204）：

```json
{
  "version": "1.2.0",
  "pub_date": "2025-01-15T12:00:00Z",
  "url": "https://releases.yourapp.com/downloads/myapp-1.2.0-x86_64.msi.zip",
  "signature": "dW50cnVzdGVkIGNvbW1lbnQ6...(Ed25519 签名)",
  "notes": "## 更新内容\n- 新增暗色主题\n- 修复数据导出问题\n- 性能优化"
}
```

### 托管方案

| 方案 | 成本 | 适用场景 |
|------|------|---------|
| **阿里云 OSS / 腾讯云 COS + 云函数** | 极低 | 国内用户，速度快 |
| **GitHub Releases + API** | 免费 | 开源项目 |
| **自建 API 服务** | 服务器成本 | 需要灰度发布、AB 测试 |
| **AWS S3 + CloudFront + Lambda** | 低 | 海外用户 |

### 静态文件托管方案（最简）

如果不需要灰度发布，可以使用静态文件 + 简单 API：

```text
releases/
├── windows-x86_64/
│   ├── latest.json          # 最新版本信息（上述 JSON 格式）
│   └── myapp-1.2.0-x86_64-setup.nsis.zip
├── darwin-aarch64/
│   ├── latest.json
│   └── myapp-1.2.0-aarch64.app.tar.gz
└── linux-x86_64/
    ├── latest.json
    └── myapp-1.2.0-amd64.AppImage.tar.gz
```

更新端点配置为：`https://releases.yourapp.com/{{target}}/latest.json`

---

## 构建与发布流程（MUST）

### 本地构建

```bash
# 设置签名私钥环境变量
export TAURI_SIGNING_PRIVATE_KEY="$(cat ~/.tauri/myapp.key)"
export TAURI_SIGNING_PRIVATE_KEY_PASSWORD=""

# 构建发布版本（自动生成签名文件）
pnpm tauri build
```

### 产物说明

```text
src-tauri/target/release/bundle/
├── nsis/
│   ├── myapp_1.2.0_x64-setup.exe          # Windows 安装程序
│   └── myapp_1.2.0_x64-setup.nsis.zip     # 更新包（Updater 使用）
│       └── myapp_1.2.0_x64-setup.nsis.zip.sig  # Ed25519 签名
├── dmg/
│   └── myapp_1.2.0_aarch64.dmg            # macOS 安装镜像
├── macos/
│   └── myapp.app.tar.gz                    # macOS 更新包
│       └── myapp.app.tar.gz.sig            # Ed25519 签名
└── appimage/
    └── myapp_1.2.0_amd64.AppImage.tar.gz  # Linux 更新包
        └── myapp_1.2.0_amd64.AppImage.tar.gz.sig
```

### CI/CD 集成示例（GitHub Actions）

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - platform: windows-latest
            target: x86_64-pc-windows-msvc
          - platform: macos-latest
            target: aarch64-apple-darwin
          - platform: ubuntu-22.04
            target: x86_64-unknown-linux-gnu

    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Install frontend dependencies
        run: pnpm install

      - name: Build Tauri app
        uses: tauri-apps/tauri-action@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
          TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_KEY_PASSWORD }}
        with:
          tagName: v__VERSION__
          releaseName: 'v__VERSION__'
          releaseBody: 'See the assets to download and install this version.'
          releaseDraft: true
```

---

## 安全约束（MUST）

1. 更新包必须经过 Ed25519 签名验证，Tauri Updater 内置校验，禁止绕过。
2. 签名私钥必须安全存储在 CI/CD Secret 中，禁止提交到版本控制。
3. 更新端点必须使用 HTTPS，禁止 HTTP 明文传输。
4. 更新服务 URL 必须通过 `tauri.conf.json` 配置，禁止硬编码在业务代码中。
5. 发布构建必须进行代码签名（Windows: Authenticode、macOS: Apple Developer ID）。

---

## 禁止事项

1. 禁止要求用户手动访问官网下载安装包进行更新。
2. 禁止自行实现"下载 zip → 解压覆盖"的更新逻辑。
3. 禁止更新检查阻塞应用启动或 UI 交互。
4. 禁止更新失败导致应用不可用（必须可继续使用当前版本）。
5. 禁止跳过签名验证直接分发更新包。
6. 禁止将签名私钥硬编码在源码或配置文件中。
