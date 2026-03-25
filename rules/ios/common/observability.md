# rules/ios/common/observability.md

## 文档目标
1. 定义 iOS 应用的日志、崩溃报告、性能监控规范。

---

## 日志框架（MUST）

1. 必须使用 **os.Logger**（iOS 14+）作为统一日志框架，禁止直接使用 `print()` 或 `NSLog()`。
2. 日志按子系统和分类组织，便于过滤。
3. 日志级别规范：
   - `.debug`：仅开发调试，Release 自动剥离。
   - `.info`：一般信息（用户操作、页面访问）。
   - `.error`：错误（需关注但不崩溃）。
   - `.fault`：严重错误（系统级问题）。

```swift
import os

extension Logger {
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Network")
    static let data = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Data")
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "UI")
}

// 使用
Logger.network.info("请求开始: \(endpoint, privacy: .public)")
Logger.network.error("请求失败: \(error.localizedDescription, privacy: .public)")
```

4. 敏感数据日志使用 `privacy: .private`（默认），禁止标记为 `.public`。

---

## 崩溃报告（MUST）

1. 必须集成 **Firebase Crashlytics** 或等效崩溃报告服务。
2. dSYM 文件必须在每次发布时上传到崩溃报告平台，确保堆栈符号化。
3. 自定义 Key 标注当前用户状态（登录状态、页面路径），便于问题定位。
4. 非致命异常通过 `Crashlytics.crashlytics().record(error:)` 上报。
5. 崩溃报告中禁止包含敏感用户数据。

---

## MetricKit 性能监控（SHOULD）

1. 推荐集成 **MetricKit** 收集应用性能指标和诊断报告。
2. 关注指标：启动时间、内存峰值、CPU 使用率、磁盘写入。
3. 收到 Diagnostic Payload 时上传到分析平台。

```swift
class MetricsManager: NSObject, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Logger.data.info("启动时间: \(payload.applicationLaunchMetrics?.histogrammedResumeTime.description ?? "N/A")")
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            // 上传诊断数据到分析平台
            uploadDiagnostics(payload)
        }
    }
}
```

---

## Analytics 埋点（SHOULD）

1. 关键用户行为（注册、登录、核心功能使用）添加分析埋点。
2. 埋点事件名称使用 `snake_case`，集中定义为常量。
3. 禁止在埋点数据中包含 PII（个人身份信息）。

---

## 禁止事项

1. 禁止在生产代码中使用 `print()` / `debugPrint()` / `dump()`。
2. 禁止在日志中输出完整的请求/响应 Body（仅限 Debug 构建）。
3. 禁止在崩溃报告中附带用户敏感数据。
4. 禁止忽略 MetricKit 诊断报告中的 Hang/CPU 异常。
