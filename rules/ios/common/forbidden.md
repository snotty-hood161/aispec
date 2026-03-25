# rules/ios/common/forbidden.md

## 文档目标
1. 汇总 iOS 应用开发中的禁止事项，便于快速检查。

---

## 语言禁止事项

1. 禁止新项目新增 Objective-C 源文件（旧项目维护允许修改已有 ObjC 文件）。
2. 禁止使用 `!`（force unwrap），必须使用 `guard let` / `if let` / `??`。
3. 禁止使用 `try!`（force try），必须使用 `do-catch` 或 `try?`。
4. 禁止使用 `as!`（force cast），必须使用 `as?` + `guard`。
5. 禁止使用隐式解包可选值（`var name: String!`），除非 `@IBOutlet`（UIKit 遗留）。
6. 禁止使用 `Any` / `AnyObject` 替代具体类型（泛型或协议约束）。

## 架构禁止事项

7. 禁止 View / ViewController 直接访问网络层或数据库层。
8. 禁止 ViewModel 持有 View / UIViewController 引用。
9. 禁止使用 Singleton 模式管理可变状态（依赖注入替代）。
10. 禁止循环依赖（模块间单向依赖）。
11. 禁止使用 NotificationCenter 替代标准数据流（Combine / async-await）。

## 主线程禁止事项

12. 禁止在主线程执行网络请求。
13. 禁止在主线程执行数据库读写。
14. 禁止在主线程执行文件 IO 操作。
15. 禁止使用 `DispatchQueue.main.sync` 从后台线程同步调度（死锁风险）。

## 安全禁止事项

16. 禁止硬编码 API 密钥、Token、密码到源代码。
17. 禁止使用 `NSAllowsArbitraryLoads = YES`（ATS 全局豁免）。
18. 禁止关闭 SSL 证书校验。
19. 禁止使用 `UserDefaults` 存储密码、Token（使用 Keychain）。
20. 禁止在日志中输出敏感信息（Token、密码、用户隐私数据）。
21. 禁止使用 Method Swizzling（除非经评审批准并注释说明）。

## 存储禁止事项

22. 禁止将大量数据存储在 UserDefaults。
23. 禁止在 Documents 目录存储缓存数据（应使用 Caches 目录）。
24. 禁止硬编码文件路径。

## UI 禁止事项

25. 禁止硬编码字符串到代码中（必须使用 Localizable.strings / String Catalog）。
26. 禁止硬编码颜色值（必须使用 Asset Catalog Color Set）。
27. 禁止使用 `dp` / `px` 等非 iOS 单位（使用 `pt`，系统自动适配）。
28. 禁止忽略 Safe Area（内容不能被刘海/Home Indicator 遮挡）。

## 发布禁止事项

29. 禁止使用私有 API（App Store 审核拒绝）。
30. 禁止跳过代码签名直接分发 IPA。
31. 禁止将签名证书/私钥提交到版本控制。
32. 禁止发布未经测试验证的构建。
33. 禁止在生产构建中保留测试后门接口。
