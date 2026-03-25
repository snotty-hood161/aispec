# rules/electron-desktop/common/observability.md

## 文档目标
1. 定义 Electron 桌面应用的日志、崩溃报告、遥测规范。

---

## 日志（MUST）

### 主进程侧
1. 使用 `electron-log` 或 `winston` 作为日志框架，禁止直接使用 `console.log`。
2. 日志文件写入用户数据目录（`app.getPath('logs')`），禁止写入应用安装目录。
3. 必须配置日志滚动策略（按大小或按天），防止磁盘占满。
4. 日志级别：开发环境 `debug`，生产环境 `info`。

```typescript
import log from 'electron-log';

log.transports.file.level = app.isPackaged ? 'info' : 'debug';
log.transports.file.maxSize = 10 * 1024 * 1024; // 10MB
log.transports.file.format = '[{y}-{m}-{d} {h}:{i}:{s}] [{level}] {text}';
log.transports.console.level = app.isPackaged ? 'warn' : 'debug';
```

### 渲染进程侧
1. 禁止生产环境残留 `console.log` 调试代码。
2. 渲染进程错误日志通过 IPC 发送到主进程统一写入文件。

### 日志内容约束
1. 禁止记录用户密码、Token、个人身份信息。
2. 日志必须包含时间戳、级别、模块标识。
3. 错误日志必须包含完整错误堆栈。

---

## 崩溃报告（SHOULD）

1. 使用 Electron 内置 `crashReporter` 或集成 Sentry 收集崩溃信息。
2. 崩溃报告必须包含：操作系统版本、应用版本、错误堆栈、复现步骤（如可获取）。
3. 崩溃报告上传前必须获得用户同意（首次启动时询问）。

```typescript
import { crashReporter } from 'electron';

crashReporter.start({
  productName: 'MyApp',
  submitURL: 'https://crash.yourapp.com/report',
  uploadToServer: true,
  compress: true,
});
```

4. 主进程未捕获异常兜底处理：

```typescript
process.on('uncaughtException', (error) => {
  log.error('主进程未捕获异常:', error);
});

process.on('unhandledRejection', (reason) => {
  log.error('主进程未处理的 Promise rejection:', reason);
});
```

---

## 使用遥测（SHOULD）

1. 遥测数据收集必须获得用户明确同意，提供开关选项。
2. 遥测数据仅包含匿名使用统计（功能使用频率、性能指标），禁止收集个人信息。
3. 遥测数据传输使用 HTTPS，禁止明文传输。
