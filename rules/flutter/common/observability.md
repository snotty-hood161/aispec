# rules/flutter/common/observability.md

## 文档目标
1. 定义 Flutter 应用的可观测性规范，覆盖日志、崩溃报告、性能监控、分析。

---

## 结构化日志（MUST）

1. 禁止使用 `print()` / `debugPrint()` 作为生产日志输出。
2. 必须使用结构化日志库（推荐 **logger** 或 **logging**）。
3. 日志级别分层使用：
   - `verbose` / `debug`：开发调试信息，生产环境不输出。
   - `info`：关键业务流程（登录、下单、支付）。
   - `warning`：非致命异常、降级处理。
   - `error`：需要关注的错误，附堆栈信息。
4. 生产环境日志级别设置为 `info` 及以上。
5. 日志禁止包含敏感信息（Token / 密码 / 手机号）。

---

## 崩溃报告（MUST）

1. 必须集成崩溃收集平台，推荐 **Firebase Crashlytics** 或 **Sentry**。
2. 崩溃报告必须覆盖：
   - Flutter 框架错误（`FlutterError.onError`）。
   - Dart 异步未捕获错误（`PlatformDispatcher.instance.onError`）。
   - 原生层崩溃（iOS Crash / Android ANR）。
3. 混淆构建必须上传符号映射文件（`--split-debug-info` 产出）。
4. 崩溃报告必须附带设备信息、OS 版本、应用版本、用户标识（匿名）。
5. 团队必须设置崩溃率告警：目标 Crash-Free Rate ≥ 99.5%。

---

## 性能监控（SHOULD）

1. 推荐集成 **Firebase Performance Monitoring** 或等效方案。
2. 监控指标：
   - 应用冷启动时间（目标 < 2 秒）。
   - 页面渲染帧率（目标 60fps，高刷设备 120fps）。
   - API 请求成功率与延迟分布。
   - 内存使用峰值。
3. 核心接口推荐添加自定义 Trace：

```dart
final trace = FirebasePerformance.instance.newTrace('order_list_load');
await trace.start();
final orders = await orderRepository.getOrders(page: 1);
trace.setMetric('order_count', orders.length);
await trace.stop();
```

---

## 行为分析（SHOULD）

1. 核心用户行为推荐埋点：页面浏览、关键按钮点击、流程完成率。
2. 推荐方案：Firebase Analytics / 自建埋点。
3. 埋点事件命名使用 `snake_case`，参数使用扁平结构。
4. 禁止在埋点中包含个人可识别信息（PII），遵守 GDPR / 个人信息保护法。

---

## 禁止事项

1. 禁止生产代码中使用 `print()` 输出日志。
2. 禁止在崩溃报告 / 日志 / 埋点中包含敏感信息。
3. 禁止忽略崩溃率告警超过 24 小时不处理。
