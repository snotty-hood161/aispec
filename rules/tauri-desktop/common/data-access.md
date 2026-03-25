# rules/tauri-desktop/common/data-access.md

## 文档目标
1. 定义 Tauri 桌面应用的数据访问规范，覆盖本地数据库、远程 API、离线支持。

---

## 本地数据库（MUST）

### 推荐方案
| 方案 | 适用场景 | 推荐度 |
|------|---------|--------|
| **SQLite（sqlx）** | 结构化数据、复杂查询 | **首选** |
| **tauri-plugin-store** | 简单键值配置 | 轻量配置 |
| **sled / redb** | 嵌入式 KV 存储 | 特殊场景 |

### 规则
1. 数据库文件存储在用户数据目录（`app_data_dir`），禁止存放在应用安装目录。
2. 数据库操作必须在 Rust 侧异步执行，禁止在前端直接操作数据库。
3. 使用连接池管理数据库连接（`sqlx::SqlitePool`）。
4. 数据库 Schema 变更使用迁移脚本，纳入版本控制。

```rust
// 数据库初始化
let db_path = app.path().app_data_dir()?.join("app.db");
let pool = sqlx::SqlitePool::connect(
    &format!("sqlite:{}?mode=rwc", db_path.display())
).await?;
sqlx::migrate!("./migrations").run(&pool).await?;
```

---

## 远程 API 调用（MUST）

1. HTTP 客户端使用 `reqwest`，通过 Rust 侧发起请求，禁止前端直接调用外部 API。
2. 必须配置请求超时（默认 30 秒）和重试策略。
3. API Base URL 通过配置文件管理，禁止硬编码。
4. 认证 Token 存储在系统密钥链，请求时从安全存储读取。

```rust
use reqwest::Client;
use std::time::Duration;

pub fn create_http_client() -> Result<Client, reqwest::Error> {
    Client::builder()
        .timeout(Duration::from_secs(30))
        .connect_timeout(Duration::from_secs(10))
        .user_agent(concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION")))
        .build()
}
```

---

## 离线支持（SHOULD）

1. 应用应能在无网络环境下正常启动和使用本地数据。
2. 网络请求失败时优先使用本地缓存数据，并提示用户当前为离线模式。
3. 离线期间的数据变更在网络恢复后自动同步（如适用）。
4. 使用 Tauri 的网络状态检测或系统 API 判断在线/离线状态。

---

## 文件操作（MUST）

1. 文件读写使用 Rust 侧的 `tokio::fs` 异步 API，禁止同步阻塞。
2. 大文件操作使用流式处理，禁止一次性读入内存。
3. 临时文件使用 `tempfile` crate，确保异常时自动清理。
4. 文件路径使用 `std::path::PathBuf`，禁止字符串拼接路径。
