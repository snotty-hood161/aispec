# rules/tauri-desktop/common/observability.md

## 文档目标
1. 定义 Tauri 桌面应用的日志、崩溃报告、遥测规范。

---

## 日志（MUST）

### Rust 侧
1. 使用 `tracing` + `tracing-subscriber` 作为日志框架。
2. 日志文件写入用户数据目录（`app_log_dir`），禁止写入应用安装目录。
3. 必须配置日志滚动策略（按大小或按天），防止磁盘占满。
4. 日志级别：开发环境 `debug`，生产环境 `info`。

```rust
use tracing_subscriber::{fmt, EnvFilter};
use tracing_appender::rolling;

pub fn init_logging(log_dir: &Path) {
    let file_appender = rolling::daily(log_dir, "app.log");
    let (non_blocking, _guard) = tracing_appender::non_blocking(file_appender);

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env()
            .add_directive("app=info".parse().unwrap()))
        .with_writer(non_blocking)
        .with_ansi(false)
        .init();
}
```

### 前端侧
1. 禁止生产环境残留 `console.log` 调试代码。
2. 前端错误日志通过 IPC 发送到 Rust 侧统一写入文件。

### 日志内容约束
1. 禁止记录用户密码、Token、个人身份信息。
2. 日志必须包含时间戳、级别、模块路径。
3. 错误日志必须包含完整错误链（`{:?}` 格式）。

---

## 崩溃报告（SHOULD）

1. 集成 `sentry` 或 `minidump` 收集崩溃信息。
2. 崩溃报告必须包含：操作系统版本、应用版本、错误堆栈、复现步骤（如可获取）。
3. 崩溃报告上传前必须获得用户同意（首次启动时询问）。
4. Rust panic 使用 `std::panic::set_hook` 捕获并记录。

```rust
std::panic::set_hook(Box::new(|info| {
    tracing::error!("应用 panic: {}", info);
    // 写入崩溃日志文件
}));
```

---

## 使用遥测（SHOULD）

1. 遥测数据收集必须获得用户明确同意，提供开关选项。
2. 遥测数据仅包含匿名使用统计（功能使用频率、性能指标），禁止收集个人信息。
3. 遥测数据传输使用 HTTPS，禁止明文传输。
