# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（SwiftLint/SwiftFormat）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Swift 版本符合基线要求 | 静态扫描：.swift-version / Package.swift 检查 |
| BL-02 | P0 | SwiftLint 检查通过 | 静态扫描：swiftlint lint --strict |
| BL-03 | P0 | SwiftFormat 格式化通过 | 静态扫描：swiftformat --lint |
| BL-04 | P0 | 依赖版本锁定 | 模式匹配：Package.swift 版本范围检查 |

## 二、代码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 类型名 PascalCase | 静态扫描：SwiftLint type_name 规则 |
| CS-02 | P0 | 函数名 camelCase | 静态扫描：SwiftLint identifier_name 规则 |
| CS-03 | P0 | 公开 API 有 /// 文档注释 | 模式匹配：public/open 声明前注释检查 |
| CS-04 | P0 | 使用最严格访问控制 | 人工审查 |
| CS-05 | P0 | 无 TODO / FIXME 遗留 | 模式匹配：关键词扫描 |

## 三、架构（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AR-01 | P0 | MVVM 分层正确 | 人工审查：依赖方向检查 |
| AR-02 | P0 | View 不直接访问网络/数据库层 | 模式匹配：View 文件中 API/DAO 引用检查 |
| AR-03 | P0 | ViewModel 使用 @MainActor | 模式匹配：ViewModel 类声明检查 |
| AR-04 | P0 | ViewModel 不持有 View 引用 | 模式匹配：ViewModel 中 View 类型检查 |
| AR-05 | P0 | 无循环依赖 | 人工审查 |

## 四、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 无 try!（force try） | 静态扫描：SwiftLint force_try 规则 |
| EH-02 | P0 | 无空 catch 块 | 模式匹配：catch 块体为空检查 |
| EH-03 | P0 | async 调用有错误处理 | 模式匹配：do-catch 或 try? 检查 |
| EH-04 | P0 | 无 fatalError() 处理业务错误 | 模式匹配：fatalError 调用扫描 |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 无 NSAllowsArbitraryLoads = YES | 模式匹配：Info.plist 扫描 |
| SC-02 | P0 | 无硬编码密钥/Token | 模式匹配：密钥关键词扫描 |
| SC-03 | P0 | 敏感数据使用 Keychain | 人工审查 |
| SC-04 | P0 | 无 SSL 校验禁用 | 模式匹配：URLSession delegate 检查 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据访问通过 Repository 封装 | 人工审查 |
| DA-02 | P0 | 网络请求使用 async/await | 模式匹配：URLSession 调用方式检查 |
| DA-03 | P0 | UserDefaults 不存储敏感信息 | 人工审查 |
| DA-04 | P0 | 无主线程数据库操作 | 人工审查 |

## 七、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | Closure 使用 [weak self] | 模式匹配：闭包捕获列表检查 |
| PF-02 | P0 | 无主线程阻塞操作 | 人工审查 |
| PF-03 | P1 | 列表使用 List/LazyVStack | 模式匹配：ForEach 容器检查 |
| PF-04 | P1 | 图片使用异步加载 | 模式匹配：UIImage 直接加载检查 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 使用 os.Logger，无 print() / NSLog() | 模式匹配：关键词扫描 |
| OB-02 | P0 | 日志无敏感信息 | 人工审查 |
| OB-03 | P0 | Crashlytics 已集成 | 人工审查 |

## 九、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 无 !（force unwrap） | 静态扫描：SwiftLint force_unwrapping 规则 |
| FB-02 | P0 | 无 as!（force cast） | 静态扫描：SwiftLint force_cast 规则 |
| FB-03 | P0 | 无新增 ObjC 文件（新项目） | 模式匹配：.m / .h 文件新增检查 |
| FB-04 | P0 | 无 print() / debugPrint() | 模式匹配：关键词扫描 |

---

## 十、框架专项检查

### SwiftUI 追加项（profiles/swiftui/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SU-01 | P0 | View body 中无耗时操作 | 人工审查 |
| SU-02 | P0 | View 有 #Preview 预览 | 模式匹配：#Preview 宏存在检查 |
| SU-03 | P0 | LazyVStack/List 用于长列表 | 模式匹配：VStack + ForEach 大数据检查 |

### UIKit 追加项（profiles/uikit/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| UK-01 | P0 | 使用 Coordinator 模式导航 | 人工审查 |
| UK-02 | P0 | DiffableDataSource 替代 reloadData | 模式匹配：reloadData 调用扫描 |
| UK-03 | P0 | 无新增 Storyboard | 模式匹配：.storyboard 文件新增检查 |
