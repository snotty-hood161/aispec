# Android 应用 PR 评审清单模板

## 文档目标
1. 用于 Android 应用 PR 评审，评审人逐项核对，确保代码质量达标。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 Android 应用 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。

---

## PR 基本信息
- [ ] [P0] 已说明变更目的、影响范围、测试结果
- [ ] [P0] 已附关键场景测试结果

## Kotlin 代码质量
- [ ] [P0] `./gradlew ktlintCheck` 通过
- [ ] [P0] `./gradlew detekt` 通过
- [ ] [P0] `./gradlew lint` 无 Error 级别问题
- [ ] [P0] `./gradlew testDebugUnitTest` 全部通过
- [ ] [P0] 无 `!!`（非空断言）出现在生产代码中
- [ ] [P0] 无 `GlobalScope.launch` 使用
- [ ] [P0] 公开 API 有 KDoc 文档注释

## 架构与分层
- [ ] [P0] 依赖方向单向向下（UI → ViewModel → UseCase → Repository）
- [ ] [P0] UI 层不直接访问 DAO 或 API Service
- [ ] [P0] ViewModel 不持有 Context/View/Activity/Fragment 引用
- [ ] [P0] 依赖通过 Hilt 构造函数注入，无字段注入（Android 组件除外）
- [ ] [P0] 无循环依赖

## 安全
- [ ] [P0] 无硬编码 API 密钥、Token、密码
- [ ] [P0] 敏感数据使用 EncryptedSharedPreferences 或 Keystore 存储
- [ ] [P0] Network Security Config 已配置，禁止明文 HTTP
- [ ] [P0] Release 构建启用 R8 混淆
- [ ] [P0] 签名密钥未提交到版本控制

## 错误处理
- [ ] [P0] Repository 层使用 Result 类型返回，无异常控制流
- [ ] [P0] Coroutine 异常已捕获处理
- [ ] [P0] 无空 catch 块
- [ ] [P0] 错误信息对用户友好，无堆栈/内部错误码泄露

## 主线程安全
- [ ] [P0] 无主线程网络请求
- [ ] [P0] 无主线程数据库读写
- [ ] [P0] 无主线程文件 IO

## 性能
- [ ] [P0] 列表使用 LazyColumn/RecyclerView，无 ScrollView 嵌套动态列表
- [ ] [P1] Compose 使用 remember/derivedStateOf 缓存计算
- [ ] [P1] 大图使用 Coil/Glide 加载，无手动 Bitmap decode
- [ ] [P1] IPC/网络传输数据量合理

## UI 质量
- [ ] [P0] 支持深色模式
- [ ] [P0] 可交互元素有 contentDescription
- [ ] [P0] 无硬编码字符串（使用 strings.xml）
- [ ] [P0] 无硬编码颜色值（使用 Theme 属性）
- [ ] [P1] 触摸目标 >= 48dp

## 数据访问
- [ ] [P0] 数据库使用 Room，无直接 SQLiteOpenHelper
- [ ] [P0] 网络请求使用 Retrofit + OkHttp
- [ ] [P0] 配置存储使用 DataStore，无 SharedPreferences（新代码）
- [ ] [P1] Room Migration 已提供（数据库版本变更时）

## 测试
- [ ] [P0] 单元测试通过
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] UseCase/Repository 关键逻辑有单元测试
- [ ] [P1] 关键 UI 有 Compose Test / Espresso 覆盖

## 可观测性
- [ ] [P0] 使用 Timber 日志，无 `Log.d()` / `println()` 调试代码
- [ ] [P0] 日志中无敏感信息
- [ ] [P1] Firebase Crashlytics 已集成

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
