# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ESLint/Prettier/CI）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | TypeScript `strict: true` 已启用 | 静态扫描：检查 tsconfig.json |
| BL-02 | P0 | Electron 版本符合基线要求（v30+） | 静态扫描：检查 package.json electron 依赖版本 |
| BL-03 | P0 | ESLint 零警告 | 静态扫描：CI eslint --max-warnings 0 |
| BL-04 | P0 | Prettier 格式化通过 | 静态扫描：prettier --check |

## 二、代码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 类/接口使用 PascalCase | 静态扫描：ESLint naming-convention |
| CS-02 | P0 | 函数/变量使用 camelCase | 静态扫描：ESLint naming-convention |
| CS-03 | P0 | 常量使用 UPPER_SNAKE_CASE | 静态扫描：ESLint naming-convention |
| CS-04 | P0 | 公开 API 有 TSDoc 注释 | 模式匹配：export 声明注释检查 |
| CS-05 | P0 | 无 TODO / FIXME / console.log 遗留 | 模式匹配：关键词扫描 |

## 三、架构（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AR-01 | P0 | IPC handler 使用 ipcMain.handle 注册 | 模式匹配：handler 注册方式检查 |
| AR-02 | P0 | 渲染进程通过 API 层调用 IPC，无直接 window.electronAPI 调用 | 模式匹配：组件代码中 window.electronAPI 调用检查 |
| AR-03 | P0 | IPC handler 无业务逻辑（仅参数校验 + 调用转发） | 人工审查 |
| AR-04 | P0 | Service 层不依赖 Electron API | 模式匹配：service 文件中 electron import 检查 |

## 四、IPC 通信（common/ipc-communication.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| IC-01 | P0 | 请求-响应使用 handle/invoke 模式 | 模式匹配：ipcMain.on + event.reply 用于请求-响应场景检查 |
| IC-02 | P0 | IPC channel 在常量文件中定义 | 模式匹配：字符串字面量 channel 扫描 |
| IC-03 | P0 | IPC handler 有参数校验 | 人工审查 |
| IC-04 | P0 | 事件监听返回取消函数 | 模式匹配：preload 监听 API 返回 unlisten 检查 |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | contextIsolation: true | 模式匹配：BrowserWindow webPreferences 检查 |
| SC-02 | P0 | nodeIntegration: false | 模式匹配：BrowserWindow webPreferences 检查 |
| SC-03 | P0 | sandbox: true | 模式匹配：BrowserWindow webPreferences 检查 |
| SC-04 | P0 | preload 未直接暴露 ipcRenderer 对象 | 模式匹配：contextBridge 暴露内容检查 |
| SC-05 | P0 | CSP 配置无 unsafe-eval | 模式匹配：CSP 配置扫描 |
| SC-06 | P0 | will-navigate 事件已监听 | 模式匹配：webContents 事件注册检查 |
| SC-07 | P0 | setWindowOpenHandler 已配置 | 模式匹配：窗口打开处理检查 |

## 六、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | IPC handler 使用 try/catch 包裹 | 模式匹配：handler 函数体检查 |
| EH-02 | P0 | 自定义 AppError 类返回序列化错误 | 模式匹配：throw 语句检查 |
| EH-03 | P0 | 渲染进程 IPC 调用有 try/catch | 模式匹配：API 层 invoke 调用检查 |
| EH-04 | P0 | 无未处理的 Promise rejection | 模式匹配：async 函数中 await 无 catch 检查 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置不硬编码 | 模式匹配：密钥/密码/secret 关键词扫描 |
| CF-02 | P0 | 敏感数据使用 safeStorage 或系统密钥链 | 模式匹配：存储方式检查 |
| CF-03 | P0 | 配置损坏有默认值回退 | 人工审查 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 主进程使用 electron-log 或 winston | 模式匹配：日志库依赖与使用检查 |
| OB-02 | P0 | 无 console.log 在生产代码中 | 模式匹配：关键词扫描 |
| OB-03 | P0 | 日志不包含敏感信息 | 人工审查 |
| OB-04 | P1 | 关键业务操作有日志记录 | 人工审查 |

## 九、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 启动时间优化（延迟加载非关键模块） | 人工审查 |
| PF-02 | P0 | 无同步操作阻塞主进程事件循环 | 模式匹配：fs.readFileSync 等同步 API 扫描 |
| PF-03 | P0 | 渲染进程资源按需加载（code splitting） | 模式匹配：路由懒加载检查 |
| PF-04 | P1 | 关闭的窗口及时 destroy | 人工审查 |

## 十、自动更新（common/auto-update.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AU-01 | P0 | 使用 electron-updater 集成更新 | 模式匹配：electron-updater 依赖与配置检查 |
| AU-02 | P0 | 更新端点使用 HTTPS | 模式匹配：更新 URL 协议检查 |
| AU-03 | P0 | 更新有用户交互确认 | 人工审查 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 主进程核心逻辑有单元测试 | 模式匹配：.test / .spec 文件存在 |
| TR-02 | P0 | 渲染进程组件有测试覆盖 | 模式匹配：.test / .spec 文件存在 |
| TR-03 | P0 | CI/CD 包含 lint + test + 构建 | 人工审查 |
| TR-04 | P0 | 打包配置正确（签名/版本号/图标） | 人工审查 |

## 十二、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止 nodeIntegration: true | 模式匹配：webPreferences 配置扫描 |
| FB-02 | P0 | 禁止 contextIsolation: false | 模式匹配：webPreferences 配置扫描 |
| FB-03 | P0 | 禁止直接暴露 ipcRenderer | 模式匹配：preload 代码扫描 |
| FB-04 | P0 | 禁止渲染进程直接操作文件系统 | 模式匹配：渲染进程 fs/path import 检查 |

---

## 十三、框架专项检查

### Electron v30+ 追加项（profiles/electron-v30/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EV-01 | P0 | 项目结构符合 Electron v30+ 标准模板（src/main/、src/preload/、src/renderer/） | 人工审查 |
| EV-02 | P0 | 主进程/preload/渲染进程代码物理分离 | 模式匹配：目录结构检查 |
| EV-03 | P0 | 共享代码仅限类型和常量（src/shared/） | 模式匹配：shared 目录内容检查 |
