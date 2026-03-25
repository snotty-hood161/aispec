# rules/flutter/common/error-handling.md

## 文档目标
1. 定义 Flutter 应用的错误处理规范，确保异常可追踪、用户体验可控。

---

## 异常建模（MUST）

1. 应用必须定义统一的异常类型体系，禁止直接抛出 `Exception()` 或字符串。
2. 推荐使用 sealed class 构建异常类型：

```dart
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  const AppException(this.message, {this.code, this.originalError});
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode, super.code, super.originalError});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

class BusinessException extends AppException {
  const BusinessException(super.message, {required super.code, super.originalError});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}
```

3. 网络层必须将 HTTP 错误码映射为类型化异常。
4. 业务错误码由服务端定义，前端映射为 `BusinessException`。

---

## 全局错误捕获（MUST）

1. 必须配置 Flutter 全局错误处理器，防止未捕获异常导致白屏：

```dart
void main() {
  FlutterError.onError = (details) {
    // 上报 Flutter 框架错误（渲染、布局等）
    crashReporter.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // 上报异步未捕获错误
    crashReporter.recordError(error, stack);
    return true;
  };

  runApp(const MyApp());
}
```

2. 全局错误处理器必须将错误上报到崩溃收集平台（Crashlytics / Sentry）。
3. 禁止在全局错误处理器中执行 UI 操作（此时 Widget 树可能已损坏）。

---

## 错误边界 Widget（MUST）

1. 核心页面必须包裹错误边界 Widget，捕获子树渲染错误并展示降级 UI：

```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({required this.child, super.key});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ErrorFallbackWidget(onRetry: () => setState(() => _hasError = false));
    }
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ErrorWidget.builder = (details) {
      _hasError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return const SizedBox.shrink();
    };
  }
}
```

2. 错误降级 UI 必须提供重试操作入口。

---

## Result 模式（SHOULD）

1. 推荐使用 Result / Either 类型替代 try-catch 进行预期错误处理：

```dart
// 使用 sealed class 实现 Result
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

// 使用示例
Future<Result<User>> login(String phone, String code) async {
  try {
    final user = await _authRepository.login(phone, code);
    return Success(user);
  } on AppException catch (e) {
    return Failure(e);
  }
}
```

2. 推荐使用 `fpdart` 或 `dartz` 包的 `Either` 类型实现函数式错误处理。

---

## 用户提示规范（MUST）

1. 网络错误：提示"网络连接异常，请检查网络后重试"+ 重试按钮。
2. 鉴权过期：自动跳转登录页，提示"登录已过期，请重新登录"。
3. 业务错误：展示服务端返回的用户友好提示信息。
4. 未知错误：提示"操作失败，请稍后重试"，同时上报错误详情。
5. 禁止向用户展示技术错误信息（堆栈、错误码、HTTP 状态码）。

---

## 禁止事项

1. 禁止空 `catch` 块（吞掉异常无任何处理）。
2. 禁止 `catch (e) {}` 不记录、不上报、不提示。
3. 禁止在 UI 层直接 `try-catch` 网络请求（应在 Repository / UseCase 层处理）。
4. 禁止使用 `rethrow` 时丢失原始堆栈信息。
