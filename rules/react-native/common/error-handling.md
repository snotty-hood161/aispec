# rules/react-native/common/error-handling.md

## 文档目标
1. 定义 React Native 应用的错误处理规范，确保异常可追踪、用户体验可控。

---

## 异常建模（MUST）

1. 应用必须定义统一的异常类型体系，禁止直接抛出原生 `Error` 或字符串。
2. 推荐使用继承自 `Error` 的自定义异常类：

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly originalError?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class NetworkError extends AppError {
  constructor(
    message: string,
    public readonly statusCode?: number,
    originalError?: unknown,
  ) {
    super(message, 'NETWORK_ERROR', originalError);
    this.name = 'NetworkError';
  }
}

export class AuthError extends AppError {
  constructor(message: string, originalError?: unknown) {
    super(message, 'AUTH_ERROR', originalError);
    this.name = 'AuthError';
  }
}

export class BusinessError extends AppError {
  constructor(message: string, code: string, originalError?: unknown) {
    super(message, code, originalError);
    this.name = 'BusinessError';
  }
}
```

3. 网络层必须将 HTTP 错误码映射为类型化异常（如 401 → `AuthError`、5xx → `NetworkError`）。
4. 业务错误码由服务端定义，前端映射为 `BusinessError`。

---

## ErrorBoundary（MUST）

1. 应用根节点必须包裹 `ErrorBoundary`，捕获 React 组件树中的渲染错误：

```tsx
import React, { Component, ErrorInfo } from 'react';

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<
  { children: React.ReactNode; fallback?: React.ReactNode },
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo): void {
    crashReporter.captureException(error, { extra: { componentStack: info.componentStack } });
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? <ErrorFallbackScreen onRetry={() => this.setState({ hasError: false, error: null })} />;
    }
    return this.props.children;
  }
}
```

2. 核心页面（首页、订单页、支付页）推荐各自包裹独立 `ErrorBoundary`，避免单页错误导致全应用崩溃。
3. 错误降级 UI 必须提供重试操作入口。

---

## 全局错误捕获（MUST）

1. 必须配置全局未捕获异常处理器：

```typescript
import { setJSExceptionHandler, setNativeExceptionHandler } from 'react-native-exception-handler';

setJSExceptionHandler((error, isFatal) => {
  crashReporter.captureException(error, { tags: { fatal: String(isFatal) } });
  if (isFatal) {
    Alert.alert('应用发生错误', '请重新启动应用', [
      { text: '重启', onPress: () => RNRestart.restart() },
    ]);
  }
}, true);

setNativeExceptionHandler((errorString) => {
  crashReporter.captureMessage(errorString, 'fatal');
});
```

2. 全局错误处理器必须将错误上报到崩溃收集平台（Sentry / Crashlytics）。
3. Promise 未处理的 rejection 必须通过 `global.ErrorUtils` 或 polyfill 捕获并上报。
4. 禁止在全局错误处理器中执行复杂 UI 操作（此时组件树可能已损坏）。

---

## Hook 层错误处理（MUST）

1. Custom Hook 中的异步操作必须使用 try-catch 捕获，并返回结构化的错误状态：

```typescript
interface UseAsyncResult<T> {
  data: T | null;
  error: AppError | null;
  isLoading: boolean;
}
```

2. 使用 TanStack Query 时必须配置全局 `onError` 回调处理通用错误（如 Token 过期自动跳转登录）。
3. 禁止在 Hook 中静默吞掉异常（空 catch 块）。

---

## Result 模式（SHOULD）

1. 推荐在 Service 层使用 Result 类型替代 throw 进行预期错误处理：

```typescript
type Result<T, E = AppError> =
  | { success: true; data: T }
  | { success: false; error: E };

async function login(credentials: LoginCredentials): Promise<Result<User>> {
  try {
    const user = await authApi.login(credentials);
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: toAppError(error) };
  }
}
```

2. 推荐使用 `neverthrow` 或 `ts-results` 库提供更完善的 Result / Either 类型支持。

---

## 用户提示规范（MUST）

1. 网络错误：提示"网络连接异常，请检查网络后重试"+ 重试按钮。
2. 鉴权过期：自动跳转登录页，提示"登录已过期，请重新登录"。
3. 业务错误：展示服务端返回的用户友好提示信息。
4. 未知错误：提示"操作失败，请稍后重试"，同时上报错误详情。
5. 禁止向用户展示技术错误信息（堆栈、错误码、HTTP 状态码）。
6. Toast / Alert 提示必须使用统一的 UI 组件，禁止直接调用 `Alert.alert` 散落在各处。

---

## 禁止事项

1. 禁止空 `catch` 块（吞掉异常无任何处理）。
2. 禁止 `catch (e) {}` 不记录、不上报、不提示。
3. 禁止在组件渲染函数中直接 `try-catch` 网络请求（应在 Hook / Service 层处理）。
4. 禁止在 catch 块中丢失原始错误的堆栈信息（必须传递 `originalError`）。
5. 禁止向用户展示原始技术错误信息。
