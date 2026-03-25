# rules/electron-desktop/common/security.md

## 文档目标
1. 定义 Electron 桌面应用的安全规范，覆盖进程隔离、CSP、沙箱、文件系统安全等。
2. 遵循 Electron 官方安全最佳实践，最小化攻击面。

---

## 进程隔离与沙箱（MUST）

### contextIsolation（上下文隔离）
1. 所有 `BrowserWindow` 必须启用 `contextIsolation: true`（Electron v30+ 默认启用）。
2. 禁止将 `contextIsolation` 设置为 `false`。
3. 渲染进程与 preload 脚本运行在独立的 JavaScript 上下文中，通过 `contextBridge` 通信。

### nodeIntegration（Node.js 集成）
1. 所有 `BrowserWindow` 必须禁用 `nodeIntegration: false`（Electron v30+ 默认禁用）。
2. 禁止将 `nodeIntegration` 设置为 `true`。
3. 渲染进程禁止直接访问 Node.js API（`require`、`process`、`fs` 等）。

### sandbox（沙箱）
1. 必须启用 `sandbox: true`，限制 preload 脚本的 Node.js API 访问范围。
2. 启用沙箱后，preload 脚本仅可使用 Electron 提供的安全 API 子集。

```typescript
// 安全的 BrowserWindow 配置
const win = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,    // MUST: 上下文隔离
    nodeIntegration: false,    // MUST: 禁用 Node 集成
    sandbox: true,             // MUST: 启用沙箱
    webSecurity: true,         // MUST: 启用 Web 安全策略
    allowRunningInsecureContent: false,
  },
});
```

---

## preload 脚本安全（MUST）

1. preload 必须通过 `contextBridge.exposeInMainWorld` 暴露 API，禁止直接暴露 `ipcRenderer`。
2. 暴露的 API 必须按功能最小化，仅暴露渲染进程实际需要的方法。
3. 暴露的方法必须对参数做校验，防止渲染进程传入恶意数据。

```typescript
// preload/index.ts — 正确做法
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  getUserProfile: (userId: number) =>
    ipcRenderer.invoke('user:get-profile', userId),
  onUpdateProgress: (callback: (percent: number) => void) => {
    const handler = (_event: Electron.IpcRendererEvent, percent: number) =>
      callback(percent);
    ipcRenderer.on('update:progress', handler);
    return () => ipcRenderer.removeListener('update:progress', handler);
  },
});
```

```typescript
// 禁止：直接暴露 ipcRenderer
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: ipcRenderer,  // 禁止！攻击者可调用任意 IPC channel
});
```

---

## CSP（Content Security Policy）（MUST）

1. 必须通过 HTTP 响应头或 `<meta>` 标签配置严格的 CSP：
   ```html
   <meta http-equiv="Content-Security-Policy"
     content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:">
   ```
2. 禁止 `script-src 'unsafe-eval'`（禁止 `eval()`）。
3. 禁止 `script-src 'unsafe-inline'`（禁止内联脚本）。
4. 外部资源加载必须限定域名白名单。

---

## 网络安全（MUST）

1. 所有 HTTP 请求必须使用 HTTPS，禁止 HTTP 明文传输。
2. 禁止在代码中禁用 SSL 证书校验。
3. API 密钥和 Token 存储在系统密钥链（macOS Keychain / Windows Credential Manager），禁止明文存储。
4. 禁止加载远程不可信页面，如需加载外部 URL 必须使用独立窗口并限制权限。
5. 必须注册 `webRequest` 拦截器或 `session.setPermissionRequestHandler` 控制权限请求。

---

## 导航与新窗口安全（MUST）

1. 必须监听 `will-navigate` 事件，阻止导航到不可信 URL。
2. 必须使用 `setWindowOpenHandler` 控制新窗口创建，禁止默认允许 `window.open`。

```typescript
win.webContents.setWindowOpenHandler(({ url }) => {
  if (isSafeUrl(url)) {
    shell.openExternal(url);
  }
  return { action: 'deny' };
});

win.webContents.on('will-navigate', (event, url) => {
  if (!isTrustedOrigin(url)) {
    event.preventDefault();
  }
});
```

---

## 代码安全（MUST）

1. 禁止在渲染进程代码中硬编码密钥、Token、凭据。
2. 发布构建必须启用代码签名（Windows: Authenticode、macOS: Apple Developer ID）。
3. 更新包必须经过签名验证，禁止绕过。
4. 禁止在生产构建中开启 DevTools（可通过 `win.webContents.openDevTools()` 守卫控制）。

---

## 禁止事项

1. 禁止设置 `nodeIntegration: true`。
2. 禁止设置 `contextIsolation: false`。
3. 禁止直接暴露 `ipcRenderer` 或 `require` 给渲染进程。
4. 禁止在 CSP 中使用 `unsafe-eval`。
5. 禁止在生产构建中启用 DevTools。
6. 禁止将敏感数据写入日志文件。
7. 禁止使用 `shell.openExternal` 打开未校验的 URL。
8. 禁止禁用 `webSecurity`。
