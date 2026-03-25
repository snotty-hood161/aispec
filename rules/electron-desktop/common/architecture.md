# rules/electron-desktop/common/architecture.md

## 整体架构

Electron 应用采用"主进程 Node.js + 渲染进程 Web 前端"多进程架构：
- **Main Process**：应用生命周期管理、原生系统 API 调用、窗口管理、IPC 中枢。
- **Renderer Process**：UI 渲染、用户交互、展示逻辑（运行在沙箱化 Chromium 中）。
- **Preload Script**：安全桥梁，通过 `contextBridge` 向渲染进程暴露受限 API。

## 分层规则（MUST）

### 主进程分层
```text
src/main/
├── index.ts                # 入口，app 生命周期与窗口创建
├── ipc/                    # IPC handler 注册（类似 Controller）
│   ├── index.ts
│   ├── userHandlers.ts
│   └── fileHandlers.ts
├── services/               # 业务逻辑层
│   ├── userService.ts
│   └── updateService.ts
├── models/                 # 数据模型
│   └── user.ts
├── repositories/           # 数据访问层
│   └── userRepo.ts
├── windows/                # 窗口管理
│   ├── mainWindow.ts
│   └── settingsWindow.ts
└── utils/                  # 工具函数
    ├── logger.ts
    └── paths.ts
```

### preload 分层
```text
src/preload/
├── index.ts                # contextBridge.exposeInMainWorld 入口
└── types.ts                # 暴露给渲染进程的 API 类型定义
```

### 渲染进程分层
```text
src/renderer/
├── App.tsx                 # 根组件
├── api/                    # IPC 调用封装层（禁止组件直接调用 window.electronAPI）
│   ├── user.ts
│   └── file.ts
├── pages/                  # 页面组件
├── components/             # 通用 UI 组件
├── stores/                 # 状态管理（Zustand/Pinia）
├── hooks/                  # 自定义 Hooks
├── types/                  # TypeScript 类型定义
└── utils/                  # 工具函数
```

### 依赖方向
```
Renderer Component → API Layer → [IPC via preload] → IPC Handler → Service → Repository
```

1. 渲染进程组件禁止直接调用 `window.electronAPI`，必须通过 `api/` 层封装。
2. IPC Handler 仅做参数校验和调用转发，禁止包含业务逻辑。
3. Service 层包含核心业务逻辑，禁止依赖 Electron API（保持可测试性）。
4. Repository 层负责数据持久化，禁止依赖 Service 层。

## 窗口管理（MUST）

1. 窗口创建逻辑必须集中在 `windows/` 目录，禁止在业务代码中随意创建窗口。
2. 每个窗口配置独立的 preload 脚本，权限最小化。
3. 窗口间通信通过主进程中转，禁止渲染进程直接互访。

```typescript
// windows/mainWindow.ts
import { BrowserWindow } from 'electron';
import path from 'node:path';

export function createMainWindow(): BrowserWindow {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
  });
  return win;
}
```

## 状态管理（MUST）

### 主进程侧
1. 应用级状态使用单例 Service 类管理，通过依赖注入传递。
2. 禁止使用全局可变变量存储应用状态。
3. 跨窗口共享状态通过主进程 IPC 广播同步。

### 渲染进程侧
1. 使用框架对应的状态管理方案（React: Zustand、Vue: Pinia）。
2. 来自主进程的数据通过 IPC 获取后存入前端 Store，禁止在多个组件中重复调用 IPC。
3. 持久化数据以主进程侧为准（单一数据源原则）。
