# rules/android/common/observability.md

## 文档目标
1. 定义 Android 应用的日志、崩溃报告、性能监控规范。

---

## 日志框架（MUST）

1. 必须使用 **Timber** 作为统一日志框架，禁止直接使用 `android.util.Log`。
2. Release 构建中仅保留 `Timber.e()` 和 `Timber.w()` 级别日志。
3. Debug 构建植入 `Timber.DebugTree()`，Release 构建植入自定义 `CrashReportingTree`。

```kotlin
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        } else {
            Timber.plant(CrashReportingTree())
        }
    }
}

class CrashReportingTree : Timber.Tree() {
    override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
        if (priority < Log.WARN) return
        FirebaseCrashlytics.getInstance().log(message)
        t?.let { FirebaseCrashlytics.getInstance().recordException(it) }
    }
}
```

---

## 崩溃报告（MUST）

1. 必须集成 **Firebase Crashlytics** 或等效崩溃报告服务。
2. 崩溃报告必须包含：设备信息、OS 版本、应用版本、堆栈跟踪。
3. 自定义 Key 标注当前用户状态（登录状态、页面路径），便于问题定位。
4. 非致命异常通过 `FirebaseCrashlytics.recordException()` 上报。
5. 崩溃报告中禁止包含敏感用户数据（密码、Token、身份证号）。

---

## ANR 监控（MUST）

1. 启用 ANR 监控，推荐 Firebase Performance 或 ANR-WatchDog。
2. 主线程耗时操作必须异步化，阈值：主线程连续执行 > 100ms 视为潜在 ANR 风险。
3. CI 或开发阶段启用 `StrictMode` 检测主线程违规操作。

```kotlin
if (BuildConfig.DEBUG) {
    StrictMode.setThreadPolicy(
        StrictMode.ThreadPolicy.Builder()
            .detectAll()
            .penaltyLog()
            .build()
    )
    StrictMode.setVmPolicy(
        StrictMode.VmPolicy.Builder()
            .detectAll()
            .penaltyLog()
            .build()
    )
}
```

---

## 性能监控（SHOULD）

1. 推荐集成 **Firebase Performance Monitoring** 采集启动时间、网络请求耗时、自定义 Trace。
2. 关键业务操作（登录、支付、文件上传）添加自定义 Trace 埋点。
3. 网络请求自动追踪通过 OkHttp Interceptor 实现。

---

## 禁止事项

1. 禁止在生产代码中使用 `Log.d()` / `Log.v()` / `println()`。
2. 禁止在日志中输出完整的请求/响应 Body（仅限 Debug 构建）。
3. 禁止在崩溃报告中附带用户敏感数据。
