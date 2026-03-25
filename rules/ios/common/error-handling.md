# rules/ios/common/error-handling.md

## 文档目标
1. 定义 iOS 应用的错误处理规范，覆盖 Swift Error 建模、async throws、用户提示等。

---

## 错误建模（MUST）

### Swift Error 类型
1. 使用 `enum` 遵循 `Error` 协议建模业务错误。
2. 每种错误类型携带结构化信息（错误码、消息、上下文）。
3. 推荐同时遵循 `LocalizedError` 提供用户友好描述。

```swift
enum AppError: Error, LocalizedError {
    case network(underlying: Error)
    case server(httpCode: Int, message: String)
    case business(code: String, message: String)
    case unexpected(message: String)

    var errorDescription: String? {
        switch self {
        case .network:
            return "网络连接失败，请检查网络后重试"
        case .server(_, let message):
            return message
        case .business(_, let message):
            return message
        case .unexpected(let message):
            return message
        }
    }
}
```

### Result 类型
1. Repository 层方法优先使用 `async throws`，也可使用 `Result<T, AppError>`。
2. 禁止在 Repository 层使用 `fatalError()` 或 `preconditionFailure()` 处理业务错误。

```swift
protocol UserRepository {
    func getUser(id: Int) async throws -> User
    func updateUser(_ user: User) async throws
}
```

---

## Swift Concurrency 错误处理（MUST）

1. `async throws` 函数的调用方必须在 `do-catch` 中处理错误或继续向上传播。
2. `Task` 中的错误必须在 Task 内部捕获处理。
3. 禁止使用 `try!`（force try），必须使用 `try` + `do-catch` 或 `try?`。
4. `Task.detached` 中的错误必须显式处理，不会自动传播。

```swift
func loadUser(id: Int) async {
    do {
        let user = try await userRepository.getUser(id: id)
        await MainActor.run { self.uiState.user = user }
    } catch let error as AppError {
        await MainActor.run { self.uiState.errorMessage = error.localizedDescription }
    } catch {
        await MainActor.run { self.uiState.errorMessage = "未知错误" }
    }
}
```

---

## 全局异常捕获（MUST）

1. 必须设置 `NSSetUncaughtExceptionHandler` 进行全局未捕获异常兜底。
2. 全局捕获仅用于日志记录和崩溃报告上传，禁止用于业务逻辑恢复。
3. 集成崩溃报告服务（Firebase Crashlytics / Sentry），生产环境崩溃自动上报。

---

## 用户提示规范（MUST）

1. 错误信息必须对用户友好，禁止展示堆栈、Exception 类名或内部错误码。
2. 网络错误统一提示"网络连接失败，请检查网络后重试"。
3. 服务端错误统一提示"服务暂时不可用，请稍后重试"，可附加服务端返回的用户可读消息。
4. 操作失败提供重试入口。

---

## 禁止事项

1. 禁止使用 `try!`（force try）。
2. 禁止使用 `fatalError()` 处理可恢复错误。
3. 禁止使用空 `catch` 块吞掉错误（`catch { }`）。
4. 禁止在 `catch` 中仅 `print(error)`（应使用日志框架）。
5. 禁止用异常控制正常业务流程。
