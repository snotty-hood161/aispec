# rules/electron-desktop/common/ipc-communication.md

## 文档目标
1. 定义 Electron 桌面应用进程间通信（IPC）的设计规范与最佳实践。
2. 确保 IPC 通信安全、高效、可维护。

---

## IPC 通信模式（MUST）

### 渲染进程 → 主进程（invoke/handle 模式）

```typescript
// 主进程：注册 handler
ipcMain.handle('user:get-profile', async (_event, userId: number) => {
  return await userService.getProfile(userId);
});

// preload：暴露安全 API
contextBridge.exposeInMainWorld('electronAPI', {
  getUserProfile: (userId: number) =>
    ipcRenderer.invoke('user:get-profile', userId),
});

// 渲染进程：通过 API 层调用
const profile = await window.electronAPI.getUserProfile(userId);
```

1. 请求-响应式通信必须使用 `ipcMain.handle` + `ipcRenderer.invoke` 模式。
2. 禁止使用 `ipcRenderer.send` + `ipcMain.on` 处理需要返回值的通信。
3. `invoke` 返回 Promise，调用方必须处理 rejection。

### 主进程 → 渲染进程（单向推送）

```typescript
// 主进程：向指定窗口推送
mainWindow.webContents.send('update:progress', { percent: 75 });

// preload：暴露监听 API
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateProgress: (callback: (data: ProgressPayload) => void) => {
    const handler = (_event: IpcRendererEvent, data: ProgressPayload) =>
      callback(data);
    ipcRenderer.on('update:progress', handler);
    return () => ipcRenderer.removeListener('update:progress', handler);
  },
});

// 渲染进程：监听并清理
const unsubscribe = window.electronAPI.onUpdateProgress((data) => {
  setProgress(data.percent);
});
// 组件卸载时取消监听
onUnmounted(() => unsubscribe());
```

1. 主进程向渲染进程推送使用 `webContents.send`。
2. preload 暴露监听 API 时必须返回取消监听函数，防止内存泄漏。
3. 渲染进程在组件卸载时必须取消监听。

---

## IPC Channel 命名规范（MUST）

1. Channel 名称使用 `domain:action` 格式（`kebab-case`）。
2. 域名对应业务模块，动作对应操作。
3. 所有 channel 在独立的常量文件中统一定义，禁止字符串字面量散落在代码中。

```typescript
// src/shared/ipcChannels.ts
export const IPC_CHANNELS = {
  USER_GET_PROFILE: 'user:get-profile',
  USER_UPDATE_SETTINGS: 'user:update-settings',
  FILE_READ_CONTENT: 'file:read-content',
  FILE_SAVE: 'file:save',
  UPDATE_CHECK: 'update:check',
  UPDATE_PROGRESS: 'update:progress',
} as const;
```

---

## IPC 安全规范（MUST）

1. IPC handler 必须校验 `event.senderFrame` 的来源，防止恶意窗口调用。
2. preload 暴露的 API 必须对参数做类型和范围校验。
3. 禁止在 IPC 中传输敏感数据（密码、Token）明文，必须通过安全存储中转。
4. 禁止在 IPC handler 中执行任意 shell 命令（参数注入风险）。

```typescript
// IPC handler 来源校验
ipcMain.handle('user:get-profile', async (event, userId: number) => {
  if (!isValidSender(event.senderFrame)) {
    throw new AppError(ErrorCode.Business, '非法调用来源');
  }
  if (typeof userId !== 'number' || userId <= 0) {
    throw new AppError(ErrorCode.Business, '无效的用户 ID');
  }
  return await userService.getProfile(userId);
});
```

---

## IPC 数据传输规范（MUST）

1. IPC 传输的数据必须可序列化（JSON 兼容），禁止传输函数、类实例、循环引用对象。
2. 单次 IPC 传输数据量控制在 1MB 以内，大数据使用分页或流式传输。
3. 批量操作合并为单次 IPC 调用，禁止循环中逐条调用 IPC。
4. IPC 返回的数据结构精简，仅包含渲染进程展示所需字段（DTO 模式）。

---

## IPC 类型安全（SHOULD）

1. 主进程与渲染进程共享 IPC 类型定义（放在 `src/shared/` 目录）。
2. preload 暴露的 API 类型通过 `d.ts` 声明文件供渲染进程使用。

```typescript
// src/shared/types/user.ts
export interface UserDto {
  id: number;
  name: string;
  email: string;
}

// src/preload/types.ts
export interface ElectronAPI {
  getUserProfile: (userId: number) => Promise<UserDto>;
  onUpdateProgress: (callback: (data: ProgressPayload) => void) => () => void;
}

// src/renderer/env.d.ts
interface Window {
  electronAPI: import('../preload/types').ElectronAPI;
}
```
