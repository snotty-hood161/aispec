# rules/electron-desktop/common/error-handling.md

## 文档目标
1. 定义 Electron 桌面应用的错误处理规范，覆盖主进程侧和渲染进程侧。
2. 确保错误信息对用户友好，对开发者可追踪。

---

## 主进程侧错误处理（MUST）

### 统一错误类型
```typescript
// src/main/errors/AppError.ts
export enum ErrorCode {
  Business = 'BUSINESS_ERROR',
  Database = 'DATABASE_ERROR',
  Network = 'NETWORK_ERROR',
  FileSystem = 'FILESYSTEM_ERROR',
  Internal = 'INTERNAL_ERROR',
}

export class AppError extends Error {
  constructor(
    public readonly code: ErrorCode,
    message: string,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }

  toSerializable(): { code: string; message: string } {
    return { code: this.code, message: this.message };
  }
}
```

### 规则
1. 必须定义统一的 `AppError` 类，IPC handler 返回给渲染进程的错误必须序列化。
2. 所有 IPC handler 必须使用 `try/catch` 捕获异常，禁止未处理的异常导致主进程崩溃。
3. 日志记录完整错误链（包含 `cause`），返回给渲染进程的错误信息脱敏。
4. 主进程未捕获异常使用 `process.on('uncaughtException')` 兜底并记录日志。

```typescript
// IPC handler 错误处理模式
ipcMain.handle('user:get-profile', async (_event, userId: number) => {
  try {
    return await userService.getProfile(userId);
  } catch (error) {
    logger.error('获取用户信息失败', { userId, error });
    if (error instanceof AppError) {
      throw error.toSerializable();
    }
    throw new AppError(ErrorCode.Internal, '系统异常').toSerializable();
  }
});
```

---

## 渲染进程侧错误处理（MUST）

### IPC 调用错误处理
```typescript
// api/user.ts
export async function getUserProfile(userId: number): Promise<UserDto> {
  try {
    return await window.electronAPI.getUserProfile(userId);
  } catch (error) {
    throw new AppError('获取用户失败', error as SerializedError);
  }
}
```

### 规则
1. 所有 IPC 调用必须有 `try/catch`，禁止未处理的 Promise rejection。
2. 渲染进程使用统一的错误类型，包含用户友好消息和原始错误。
3. 错误展示使用 Toast/Notification 组件，禁止 `alert()` 或 `console.error()` 替代。
4. 组件级错误使用 Error Boundary（React）或 `onErrorCaptured`（Vue）捕获。

### 全局错误处理
```typescript
window.addEventListener('unhandledrejection', (event) => {
  console.error('未处理的异步错误:', event.reason);
  showErrorNotification('操作失败，请重试');
  event.preventDefault();
});
```

---

## 错误分类

| 类型 | 主进程处理 | 渲染进程展示 |
|------|----------|------------|
| 业务错误（参数校验、权限不足） | `ErrorCode.Business` | 展示具体提示 |
| 网络错误（超时、断连） | `ErrorCode.Network` | "网络异常，请检查连接" |
| 数据库错误 | `ErrorCode.Database` | "数据操作失败" |
| 文件系统错误 | `ErrorCode.FileSystem` | "文件操作失败" |
| 未知错误 | `ErrorCode.Internal` | "系统异常，请重试" + 日志上报 |
