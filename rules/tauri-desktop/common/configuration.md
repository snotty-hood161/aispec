# rules/tauri-desktop/common/configuration.md

## 文档目标
1. 定义 Tauri 桌面应用的配置管理规范。

---

## 配置分层（MUST）

| 层级 | 存储位置 | 内容 | 示例 |
|------|---------|------|------|
| 应用配置 | `tauri.conf.json` | Tauri 框架配置 | 窗口大小、CSP、权限 |
| 运行时配置 | `config.toml` / 环境变量 | API 地址、功能开关 | `api_base_url` |
| 用户设置 | `tauri-plugin-store` | 用户偏好 | 主题、语言、窗口位置 |
| 敏感凭据 | 系统密钥链 | Token、密码 | API Key |

## 应用配置（MUST）

1. `tauri.conf.json` 是 Tauri 核心配置，必须纳入版本控制。
2. 环境差异（开发/测试/生产）通过环境变量或构建时替换处理。
3. 禁止在 `tauri.conf.json` 中硬编码敏感信息。

## 运行时配置（MUST）

```rust
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct AppConfig {
    pub api_base_url: String,
    pub max_retry: u32,
    pub log_level: String,
}

impl AppConfig {
    pub fn load(app: &tauri::AppHandle) -> Result<Self, AppError> {
        let config_path = app.path().app_config_dir()?.join("config.toml");
        let content = std::fs::read_to_string(&config_path)
            .unwrap_or_else(|_| include_str!("../config.default.toml").to_string());
        toml::from_str(&content).map_err(|e| AppError::Internal(e.to_string()))
    }
}
```

1. 配置文件损坏时必须回退到默认值，禁止崩溃。
2. 默认配置内嵌到二进制文件中（`include_str!`），确保首次运行可用。

---

## 用户设置（MUST）

```typescript
// 前端使用 tauri-plugin-store
import { Store } from '@tauri-apps/plugin-store';

const store = await Store.load('settings.json');
await store.set('theme', 'dark');
await store.set('language', 'zh-CN');
await store.save();

const theme = await store.get<string>('theme');
```

1. 用户设置使用 `tauri-plugin-store`，自动持久化到用户数据目录。
2. 设置读取失败时回退默认值，禁止崩溃。
3. 窗口位置和大小在关闭时保存，下次启动恢复。

---

## 敏感凭据（MUST）

1. API Token、密码等敏感信息使用系统密钥链存储：
   - macOS：Keychain
   - Windows：Credential Manager
   - Linux：Secret Service (libsecret)
2. 推荐使用 `keyring` crate（Rust 侧）管理凭据。
3. 禁止将敏感信息存储在 `tauri-plugin-store`、配置文件或 `localStorage` 中。

```rust
use keyring::Entry;

pub fn store_token(service: &str, user: &str, token: &str) -> Result<(), AppError> {
    let entry = Entry::new(service, user)
        .map_err(|e| AppError::Internal(e.to_string()))?;
    entry.set_password(token)
        .map_err(|e| AppError::Internal(e.to_string()))
}

pub fn get_token(service: &str, user: &str) -> Result<String, AppError> {
    let entry = Entry::new(service, user)
        .map_err(|e| AppError::Internal(e.to_string()))?;
    entry.get_password()
        .map_err(|e| AppError::Internal(e.to_string()))
}
```
