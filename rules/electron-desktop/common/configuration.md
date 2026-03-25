# rules/electron-desktop/common/configuration.md

## 文档目标
1. 定义 Electron 桌面应用的配置管理规范。

---

## 配置分层（MUST）

| 层级 | 存储位置 | 内容 | 示例 |
|------|---------|------|------|
| 构建配置 | `electron-builder.yml` / `forge.config.ts` | 打包与分发配置 | 安装包格式、签名、图标 |
| 运行时配置 | `config.json` / 环境变量 | API 地址、功能开关 | `apiBaseUrl` |
| 用户设置 | `electron-store` | 用户偏好 | 主题、语言、窗口位置 |
| 敏感凭据 | 系统密钥链 | Token、密码 | API Key |

## 构建配置（MUST）

1. `electron-builder.yml` 或 `forge.config.ts` 是打包核心配置，必须纳入版本控制。
2. 环境差异（开发/测试/生产）通过环境变量或构建时替换处理。
3. 禁止在构建配置中硬编码敏感信息。

## 运行时配置（MUST）

```typescript
// src/main/config.ts
import { app } from 'electron';
import path from 'node:path';
import fs from 'node:fs';

interface AppConfig {
  apiBaseUrl: string;
  maxRetry: number;
  logLevel: string;
}

const defaultConfig: AppConfig = {
  apiBaseUrl: 'https://api.example.com',
  maxRetry: 3,
  logLevel: 'info',
};

export function loadConfig(): AppConfig {
  const configPath = path.join(app.getPath('userData'), 'config.json');
  try {
    const content = fs.readFileSync(configPath, 'utf-8');
    return { ...defaultConfig, ...JSON.parse(content) };
  } catch {
    return defaultConfig;
  }
}
```

1. 配置文件损坏时必须回退到默认值，禁止崩溃。
2. 默认配置内嵌到代码中，确保首次运行可用。

---

## 用户设置（MUST）

```typescript
// 使用 electron-store 管理用户设置
import Store from 'electron-store';

interface UserSettings {
  theme: 'light' | 'dark';
  language: string;
  windowBounds: { x: number; y: number; width: number; height: number };
}

const store = new Store<UserSettings>({
  defaults: {
    theme: 'light',
    language: 'zh-CN',
    windowBounds: { x: 0, y: 0, width: 1200, height: 800 },
  },
});
```

1. 用户设置使用 `electron-store`，自动持久化到用户数据目录。
2. 设置读取失败时回退默认值，禁止崩溃。
3. 窗口位置和大小在关闭时保存，下次启动恢复。

---

## 敏感凭据（MUST）

1. API Token、密码等敏感信息使用系统密钥链存储：
   - macOS：Keychain
   - Windows：Credential Manager
   - Linux：Secret Service (libsecret)
2. 推荐使用 `keytar` 或 Electron 的 `safeStorage` API 管理凭据。
3. 禁止将敏感信息存储在 `electron-store`、配置文件或 `localStorage` 中。

```typescript
// 使用 Electron safeStorage 加密敏感数据
import { safeStorage } from 'electron';

export function encryptToken(token: string): Buffer {
  return safeStorage.encryptString(token);
}

export function decryptToken(encrypted: Buffer): string {
  return safeStorage.decryptString(encrypted);
}
```
