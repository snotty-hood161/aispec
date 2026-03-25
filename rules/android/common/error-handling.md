# rules/android/common/error-handling.md

## 文档目标
1. 定义 Android 应用的错误处理规范，覆盖 Kotlin 错误建模、Coroutine 异常、用户提示等。

---

## 错误建模（MUST）

### Kotlin sealed class 错误
1. 使用 `sealed interface` 或 `sealed class` 建模业务错误类型。
2. 每种错误类型携带结构化信息（错误码、消息、上下文）。

```kotlin
sealed interface AppError {
    val message: String

    data class Network(
        override val message: String = "网络连接失败",
        val code: Int? = null,
    ) : AppError

    data class Server(
        override val message: String,
        val httpCode: Int,
        val errorCode: String? = null,
    ) : AppError

    data class Business(
        override val message: String,
        val code: String,
    ) : AppError

    data class Unexpected(
        override val message: String = "未知错误",
        val cause: Throwable? = null,
    ) : AppError
}
```

### Result 类型
1. Repository 层方法返回 `Result<T>` 或自定义 `Either<AppError, T>`。
2. 禁止在 Repository 层抛出异常作为正常控制流。

```kotlin
interface UserRepository {
    suspend fun getUser(id: Long): Result<User>
    suspend fun updateUser(user: User): Result<Unit>
}
```

---

## Coroutine 异常处理（MUST）

1. ViewModel 中使用 `viewModelScope.launch` 启动协程，异常在协程内部捕获。
2. 禁止使用全局 `CoroutineExceptionHandler` 替代局部异常处理。
3. `async` 调用必须在 `await()` 处捕获异常。
4. 网络请求和 IO 操作必须在 `try-catch` 中执行或使用 `runCatching`。

```kotlin
viewModelScope.launch {
    val result = runCatching { userRepository.getUser(userId) }
    result
        .onSuccess { user -> _uiState.update { it.copy(user = user) } }
        .onFailure { error -> _events.send(UiEvent.ShowError(error.toAppError())) }
}
```

---

## 全局异常捕获（MUST）

1. 必须设置 `Thread.setDefaultUncaughtExceptionHandler` 进行全局未捕获异常兜底。
2. 全局捕获仅用于日志记录和崩溃报告上传，禁止用于业务逻辑恢复。
3. 集成 Firebase Crashlytics 或等效崩溃报告服务，生产环境崩溃自动上报。

---

## 用户提示规范（MUST）

1. 错误信息必须对用户友好，禁止展示堆栈、异常类名或内部错误码。
2. 网络错误统一提示"网络连接失败，请检查网络后重试"。
3. 服务端错误统一提示"服务暂时不可用，请稍后重试"，可附加服务端返回的用户可读消息。
4. 操作失败提供重试入口（按钮或下拉刷新）。

---

## 禁止事项

1. 禁止使用空 `catch` 块吞掉异常（`catch (e: Exception) { }`）。
2. 禁止捕获 `Throwable`（应捕获 `Exception`，`Error` 子类不应被捕获）。
3. 禁止在 `catch` 中仅 `e.printStackTrace()`（应使用 Timber 或日志框架）。
4. 禁止用异常控制正常业务流程。
