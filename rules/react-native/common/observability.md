# rules/react-native/common/observability.md

## 文档目标
1. 定义 React Native 应用的可观测性规范，覆盖日志、崩溃收集、性能监控。

---

## 日志规范（MUST）

1. 禁止在生产代码中使用 `console.log` / `console.warn` / `console.error`，必须使用结构化日志库。
2. 推荐使用 **react-native-logs** 或自定义 Logger 封装：

```typescript
import { logger, consoleTransport, sentryTransport } from 'react-native-logs';

const log = logger.createLogger({
  severity: __DEV__ ? 'debug' : 'error',
  transport: __DEV__ ? consoleTransport : sentryTransport,
  transportOptions: {
    colors: { debug: 'white', info: 'blue', warn: 'yellow', error: 'red' },
  },
});

export const Logger = {
  debug: (tag: string, message: string, data?: Record<string, unknown>) =>
    log.debug(`[${tag}]`, message, data),
  info: (tag: string, message: string, data?: Record<string, unknown>) =>
    log.info(`[${tag}]`, message, data),
  warn: (tag: string, message: string, data?: Record<string, unknown>) =>
    log.warn(`[${tag}]`, message, data),
  error: (tag: string, message: string, error?: unknown) =>
    log.error(`[${tag}]`, message, error),
};
```

3. 日志必须包含 Tag（模块标识），便于按模块过滤。
4. 日志级别定义：

| 级别 | 用途 | 生产环境 |
|------|------|---------|
| debug | 开发调试信息 | 禁止输出 |
| info | 关键业务流程节点 | 按需输出 |
| warn | 可恢复的异常情况 | 输出 |
| error | 不可恢复的错误 | 输出 + 上报 |

5. 禁止在日志中输出敏感信息（Token / 密码 / 手机号 / 身份证号）。
6. 生产环境日志级别必须设置为 `warn` 或 `error`，禁止输出 `debug` / `info` 级别。

---

## 崩溃收集（MUST）

1. 必须集成崩溃收集平台，推荐方案：
   - **Sentry**（`@sentry/react-native`）：全功能崩溃与性能监控。
   - **Firebase Crashlytics**（`@react-native-firebase/crashlytics`）：与 Firebase 生态集成。
2. 崩溃收集必须在应用初始化最早期配置：

```typescript
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: Config.SENTRY_DSN,
  environment: Config.ENV,
  release: `${appName}@${appVersion}`,
  dist: buildNumber,
  tracesSampleRate: Config.ENV === 'production' ? 0.2 : 1.0,
  enableAutoSessionTracking: true,
  attachStacktrace: true,
});
```

3. 崩溃上报必须包含以下上下文信息：
   - 应用版本 / 构建号。
   - 设备型号 / 操作系统版本。
   - 用户 ID（脱敏）。
   - 当前页面路由。
   - 网络状态（WiFi / Cellular / Offline）。
4. Hermes bytecode 构建必须上传 Source Map 到崩溃平台，确保堆栈可还原。
5. 每次发版后必须验证 Source Map 是否正确关联。

---

## 性能监控（MUST）

1. 必须监控以下核心性能指标：
   - **应用启动时间**（冷启动 / 热启动）。
   - **页面加载时间**（导航到首屏内容渲染完成）。
   - **JS 线程帧率**（FPS）。
   - **API 响应时间**。
2. 推荐使用 Sentry Performance 或 Firebase Performance 自动采集。
3. 关键用户路径（登录 → 首页 → 下单）必须配置自定义 Transaction 追踪。
4. 性能指标必须设置告警阈值：
   - 冷启动 > 3s 告警。
   - API P99 > 5s 告警。
   - JS 帧率 < 30fps 告警。

---

## 用户行为追踪（SHOULD）

1. 推荐集成用户行为分析平台（Firebase Analytics / Mixpanel / Amplitude）。
2. 关键事件必须埋点：
   - 页面浏览（Screen View）。
   - 核心操作（注册 / 登录 / 下单 / 支付）。
   - 错误事件（API 失败 / 功能异常）。
3. 埋点数据必须定义统一的事件命名规范（如 `screen_view`、`button_click`、`api_error`）。
4. 禁止在埋点数据中包含 PII（个人身份信息），除非合规允许。

---

## 面包屑（Breadcrumbs）（SHOULD）

1. 推荐在崩溃上报中附加面包屑信息，记录崩溃前的用户操作路径。
2. Sentry 自动收集的面包屑包括：导航事件、网络请求、用户点击。
3. 关键业务操作推荐手动添加面包屑：

```typescript
Sentry.addBreadcrumb({
  category: 'order',
  message: `用户提交订单 ${orderId}`,
  level: 'info',
  data: { orderId, amount },
});
```

4. 面包屑数据禁止包含敏感信息。

---

## 网络监控（SHOULD）

1. 推荐监控 API 请求的成功率、响应时间、错误分布。
2. 推荐使用 axios 拦截器自动上报请求指标。
3. 慢请求（> 3s）推荐自动上报并标记 Tag。
4. 网络状态变化（在线 ↔ 离线）推荐记录到面包屑。

---

## 告警与 On-Call（MUST）

1. 崩溃率超过阈值（如 > 1%）必须触发告警通知。
2. 新版本发布后必须监控崩溃率变化（与上一版本对比）。
3. P0 级崩溃（影响核心功能）必须在 2 小时内响应。
4. 告警渠道推荐：Slack / 飞书 / 钉钉 Webhook + PagerDuty。

---

## 禁止事项

1. 禁止在生产代码中使用 `console.log`。
2. 禁止发布生产版本时不上传 Source Map。
3. 禁止在日志 / 崩溃报告 / 埋点中输出敏感信息。
4. 禁止生产环境输出 debug 级别日志。
5. 禁止在无崩溃收集平台的情况下发布生产版本。
