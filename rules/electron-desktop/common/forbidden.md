# rules/electron-desktop/common/forbidden.md

## 文档目标
1. 汇总 Electron 桌面应用开发中的禁止事项，便于快速检查。

---

## 主进程侧禁止事项

1. 禁止在主进程生产代码中使用 `console.log`，必须使用结构化日志库。
2. 禁止在 IPC handler 中包含业务逻辑（handler 仅做参数校验和调用转发）。
3. 禁止硬编码 API 地址、密钥、凭据。
4. 禁止同步 I/O 阻塞主进程事件循环。
5. 禁止忽略 Promise rejection（必须 `catch` 或使用 `async/await` + `try/catch`）。
6. 禁止在 IPC handler 中执行任意 shell 命令（参数注入风险）。
7. 禁止使用全局可变变量存储应用状态。
8. 禁止在 `app.on('ready')` 之前执行依赖 Electron API 的操作。

## 渲染进程侧禁止事项

9. 禁止在组件中直接调用 `window.electronAPI`，必须通过 API 层封装。
10. 禁止使用 `any` 类型（TypeScript `strict: true`）。
11. 禁止生产环境残留 `console.log` 调试代码。
12. 禁止使用 `alert()` 展示错误信息。
13. 禁止在渲染进程硬编码敏感信息（Token、密钥）。
14. 禁止未处理的 Promise rejection。
15. 禁止在循环中逐条调用 IPC（应合并为批量操作）。

## 安全禁止事项

16. 禁止设置 `nodeIntegration: true`。
17. 禁止设置 `contextIsolation: false`。
18. 禁止直接暴露 `ipcRenderer` 或 `require` 给渲染进程。
19. 禁止在 CSP 中使用 `unsafe-eval`。
20. 禁止禁用 `webSecurity`。
21. 禁止禁用 SSL 证书校验。
22. 禁止将敏感数据存储在 `localStorage` 或 `electron-store` 中（应使用 `safeStorage` 或系统密钥链）。
23. 禁止在生产构建中启用 DevTools。
24. 禁止跳过更新包签名验证。
25. 禁止将签名密钥/证书提交到版本控制。

## 架构禁止事项

26. 禁止渲染进程直接操作文件系统（必须通过主进程 IPC）。
27. 禁止渲染进程直接调用外部 HTTP API（必须通过主进程代理）。
28. 禁止 Service 层依赖 Electron API（保持可测试性）。
29. 禁止循环依赖（模块间单向依赖）。
30. 禁止在 preload 脚本中包含业务逻辑。

## 发布禁止事项

31. 禁止要求用户手动访问官网下载安装包进行更新。
32. 禁止自行实现"下载 zip → 解压覆盖"的更新逻辑。
33. 禁止跳过代码签名直接分发安装包。
34. 禁止发布未经 ESLint 和单元测试验证的代码。
