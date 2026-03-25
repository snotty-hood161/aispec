# rules/electron-desktop/profiles/electron-v30/project-structure.md

## 文档目标
1. 定义 Electron v30+ 项目的标准目录结构与配置要求。

---

## Electron v30+ 特性要求（MUST）

1. Electron v30+ 默认启用 `contextIsolation: true`、`nodeIntegration: false`、`sandbox: true`，禁止覆盖这些默认值。
2. 使用 ESM 模块系统（`"type": "module"` 或 `.mts` 后缀）。
3. 渲染进程使用 Chromium 124+ 内核，可使用最新 Web API。
4. 推荐使用 `electron-vite` 统一构建主进程、preload、渲染进程。

---

## 标准项目结构

```text
project-root/
├── package.json                    # 项目元数据与依赖
├── electron-builder.yml            # 打包配置
├── tsconfig.json                   # 根 TypeScript 配置
├── tsconfig.main.json              # 主进程 TypeScript 配置
├── tsconfig.preload.json           # preload TypeScript 配置
├── tsconfig.renderer.json          # 渲染进程 TypeScript 配置
├── .eslintrc.cjs                   # ESLint 配置
├── .prettierrc                     # Prettier 配置
├── .env                            # 环境变量（不提交）
├── .env.example                    # 环境变量示例
├── .gitignore
├── resources/                      # 静态资源（图标等）
│   ├── icon.ico
│   ├── icon.icns
│   └── icon.png
├── src/
│   ├── main/                       # 主进程
│   │   ├── index.ts                # 入口，app 生命周期
│   │   ├── ipc/                    # IPC handler 注册
│   │   │   ├── index.ts
│   │   │   └── userHandlers.ts
│   │   ├── services/               # 业务逻辑层
│   │   │   └── userService.ts
│   │   ├── repositories/           # 数据访问层
│   │   │   └── userRepo.ts
│   │   ├── windows/                # 窗口管理
│   │   │   └── mainWindow.ts
│   │   └── utils/                  # 工具函数
│   │       ├── logger.ts
│   │       └── paths.ts
│   ├── preload/                    # preload 脚本
│   │   ├── index.ts                # contextBridge 暴露 API
│   │   └── types.ts                # 暴露的 API 类型定义
│   ├── renderer/                   # 渲染进程（前端）
│   │   ├── index.html
│   │   ├── main.tsx                # 前端入口
│   │   ├── App.tsx
│   │   ├── api/                    # IPC 调用封装层
│   │   ├── pages/
│   │   ├── components/
│   │   ├── stores/
│   │   ├── hooks/
│   │   ├── types/
│   │   └── utils/
│   └── shared/                     # 主进程与渲染进程共享
│       ├── ipcChannels.ts          # IPC channel 常量
│       └── types/                  # 共享类型定义
│           └── user.ts
├── tests/                          # 测试
│   ├── main/                       # 主进程测试
│   ├── renderer/                   # 渲染进程测试
│   └── e2e/                        # E2E 测试
└── scripts/                        # 构建/发布脚本
    └── notarize.ts                 # macOS 公证脚本
```

---

## 配置文件要求（MUST）

### package.json
```json
{
  "name": "my-electron-app",
  "version": "1.0.0",
  "main": "dist/main/index.js",
  "scripts": {
    "dev": "electron-vite dev",
    "build": "electron-vite build",
    "preview": "electron-vite preview",
    "lint": "eslint . --max-warnings 0",
    "format": "prettier --write .",
    "test": "vitest run",
    "test:e2e": "playwright test",
    "release": "electron-builder --publish always"
  }
}
```

### electron-builder.yml
```yaml
appId: com.yourcompany.myapp
productName: MyApp
directories:
  output: release
  buildResources: resources
files:
  - dist/**/*
  - package.json
win:
  target: nsis
  icon: resources/icon.ico
  signingHashAlgorithms: [sha256]
mac:
  target: dmg
  icon: resources/icon.icns
  hardenedRuntime: true
  gatekeeperAssess: false
  entitlements: build/entitlements.mac.plist
  entitlementsInherit: build/entitlements.mac.plist
linux:
  target: [AppImage, deb]
  icon: resources/icon.png
nsis:
  oneClick: false
  allowToChangeInstallationDirectory: true
publish:
  provider: generic
  url: https://releases.yourapp.com/
```

---

## electron-vite 构建配置

```typescript
// electron.vite.config.ts
import { defineConfig, externalizeDepsPlugin } from 'electron-vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  main: {
    plugins: [externalizeDepsPlugin()],
  },
  preload: {
    plugins: [externalizeDepsPlugin()],
  },
  renderer: {
    plugins: [react()],
  },
});
```

---

## 约束

1. 主进程、preload、渲染进程代码必须物理分离在 `src/main/`、`src/preload/`、`src/renderer/` 目录。
2. 共享类型和常量放在 `src/shared/`，禁止共享运行时代码。
3. 渲染进程禁止 import 主进程模块，主进程禁止 import 渲染进程模块。
4. 测试文件按进程类型分目录组织。
