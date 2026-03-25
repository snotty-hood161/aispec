# iOS 应用 PR 评审清单模板

## 文档目标
1. 用于 iOS 应用 PR 评审，评审人逐项核对，确保代码质量达标。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 iOS 应用 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。

---

## PR 基本信息
- [ ] [P0] 已说明变更目的、影响范围、测试结果
- [ ] [P0] 已附关键场景测试结果

## Swift 代码质量
- [ ] [P0] `swiftlint lint --strict` 通过
- [ ] [P0] `swiftformat --lint` 通过
- [ ] [P0] 单元测试全部通过
- [ ] [P0] 无 `!`（force unwrap）出现在生产代码中
- [ ] [P0] 无 `try!`（force try）
- [ ] [P0] 无 `as!`（force cast）
- [ ] [P0] 公开 API 有 `///` 文档注释

## 架构与分层
- [ ] [P0] 依赖方向单向向下（View → ViewModel → UseCase → Repository）
- [ ] [P0] View/ViewController 不直接访问网络层或数据库层
- [ ] [P0] ViewModel 不持有 View/UIViewController 引用
- [ ] [P0] 依赖通过初始化器注入，无直接创建依赖实例
- [ ] [P0] 无循环依赖

## 安全
- [ ] [P0] 无硬编码 API 密钥、Token、密码
- [ ] [P0] 敏感数据使用 Keychain 存储
- [ ] [P0] ATS 未被全局禁用
- [ ] [P0] 签名证书未提交到版本控制
- [ ] [P0] 日志中无敏感信息

## 错误处理
- [ ] [P0] Repository 层使用 async throws 或 Result 返回
- [ ] [P0] async 调用有 do-catch 错误处理
- [ ] [P0] 无空 catch 块
- [ ] [P0] 错误信息对用户友好，无堆栈/内部错误码泄露

## 主线程安全
- [ ] [P0] 无主线程网络请求
- [ ] [P0] 无主线程数据库读写
- [ ] [P0] 无 DispatchQueue.main.sync 从后台线程调用

## 性能
- [ ] [P0] 列表使用 List/LazyVStack/UICollectionView，无一次性全量渲染
- [ ] [P0] Closure 捕获 self 使用 [weak self]
- [ ] [P1] 异步图片使用 AsyncImage 或缓存库
- [ ] [P1] 无循环中频繁创建 DateFormatter

## UI 质量
- [ ] [P0] 支持深色模式
- [ ] [P0] 可交互元素有 accessibilityLabel
- [ ] [P0] 文本支持 Dynamic Type
- [ ] [P0] 内容在 Safe Area 内
- [ ] [P0] 无硬编码字符串（使用 Localizable）
- [ ] [P1] 触摸目标 >= 44pt

## 数据访问
- [ ] [P0] 网络请求使用 URLSession + async/await
- [ ] [P0] 本地持久化使用 SwiftData/Core Data
- [ ] [P0] UserDefaults 不存储敏感信息
- [ ] [P1] 数据库 Migration 已提供（Schema 变更时）

## 测试
- [ ] [P0] 单元测试通过
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] UseCase/Repository 关键逻辑有单元测试
- [ ] [P1] 关键 UI 有 XCUITest 覆盖

## 可观测性
- [ ] [P0] 使用 os.Logger 日志，无 print() / NSLog() 调试代码
- [ ] [P0] 日志中无敏感信息
- [ ] [P1] Crashlytics 已集成，dSYM 已配置上传

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
