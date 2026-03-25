# rules/tauri-desktop/common/error-handling.md

## 文档目标
1. 定义 Tauri 桌面应用的错误处理规范，覆盖 Rust 侧和前端侧。
2. 确保错误信息对用户友好，对开发者可追踪。

---

## Rust 侧错误处理（MUST）

### 统一错误类型
```rust
use serde::Serialize;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("业务错误: {0}")]
    Business(String),

    #[error("数据库错误: {0}")]
    Database(#[from] sqlx::Error),

    #[error("网络错误: {0}")]
    Network(#[from] reqwest::Error),

    #[error("IO 错误: {0}")]
    Io(#[from] std::io::Error),

    #[error("未知错误: {0}")]
    Internal(String),
}

// Tauri Command 要求错误类型实现 Serialize
impl Serialize for AppError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}
```

### 规则
1. 必须使用 `thiserror` 定义应用错误枚举，禁止返回 `String` 作为错误类型。
2. 所有 Tauri Command 返回 `Result<T, AppError>`，禁止在 Command 中 `unwrap()`。
3. 错误转换使用 `#[from]` 或手动 `impl From<E>`，禁止在调用处 `.unwrap()` 后重新包装。
4. 日志记录完整错误链（`{:?}` 格式），返回给前端的错误信息脱敏。

---

## 前端侧错误处理（MUST）

### IPC 调用错误处理
```typescript
// api/user.ts
import { invoke } from '@tauri-apps/api/core';

export async function getUser(userId: number): Promise<UserDto> {
  try {
    return await invoke<UserDto>('get_user', { userId });
  } catch (error) {
    // Tauri Command 返回的错误是字符串
    throw new AppError('获取用户失败', error as string);
  }
}
```

### 规则
1. 所有 IPC 调用必须有 `try/catch`，禁止未处理的 Promise rejection。
2. 前端使用统一的错误类型（`AppError`），包含用户友好消息和原始错误。
3. 错误展示使用 Toast/Notification 组件，禁止 `alert()` 或 `console.error()` 替代。
4. 组件级错误使用 Error Boundary（React）或 `onErrorCaptured`（Vue）捕获。

### 全局错误处理
```typescript
// 未捕获的 Promise rejection
window.addEventListener('unhandledrejection', (event) => {
  console.error('未处理的异步错误:', event.reason);
  showErrorNotification('操作失败，请重试');
  event.preventDefault();
});
```

---

## 错误分类

| 类型 | Rust 处理 | 前端展示 |
|------|----------|---------|
| 业务错误（参数校验、权限不足） | `AppError::Business` | 展示具体提示 |
| 网络错误（超时、断连） | `AppError::Network` | "网络异常，请检查连接" |
| 数据库错误 | `AppError::Database` | "数据操作失败" |
| 未知错误 | `AppError::Internal` | "系统异常，请重试" + 日志上报 |
