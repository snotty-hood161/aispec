# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ktlint/detekt/lint）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Gradle Kotlin DSL（.kts 后缀） | 静态扫描：构建文件后缀检查 |
| BL-02 | P0 | Version Catalog 管理依赖 | 静态扫描：libs.versions.toml 存在检查 |
| BL-03 | P0 | ktlint 检查通过 | 静态扫描：./gradlew ktlintCheck |
| BL-04 | P0 | detekt 检查通过 | 静态扫描：./gradlew detekt |
| BL-05 | P0 | 无动态版本号（`+`） | 模式匹配：依赖声明中 `+` 扫描 |

## 二、代码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 类名 PascalCase | 静态扫描：detekt naming 规则 |
| CS-02 | P0 | 函数名 camelCase | 静态扫描：detekt naming 规则 |
| CS-03 | P0 | Composable 函数 PascalCase | 模式匹配：@Composable 函数名检查 |
| CS-04 | P0 | 公开 API 有 KDoc | 模式匹配：public/internal 声明前 KDoc 检查 |
| CS-05 | P0 | 无 TODO / FIXME 遗留 | 模式匹配：关键词扫描 |

## 三、架构（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AR-01 | P0 | 依赖注入使用 Hilt | 模式匹配：@HiltViewModel / @Inject 检查 |
| AR-02 | P0 | UI 层不直接访问 DAO/API | 模式匹配：Activity/Fragment 中无 Dao/ApiService 引用 |
| AR-03 | P0 | ViewModel 使用 StateFlow 暴露状态 | 模式匹配：ViewModel 中 StateFlow 声明检查 |
| AR-04 | P0 | ViewModel 不持有 Context/View 引用 | 模式匹配：ViewModel 类中 Context/View 类型检查 |
| AR-05 | P0 | 无循环依赖 | 人工审查 |

## 四、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | Repository 返回 Result 类型 | 模式匹配：Repository 方法返回值签名 |
| EH-02 | P0 | 无空 catch 块 | 模式匹配：catch 块体为空检查 |
| EH-03 | P0 | 无 e.printStackTrace() | 模式匹配：关键词扫描 |
| EH-04 | P0 | Coroutine 异常已捕获 | 模式匹配：launch/async 内 try-catch 检查 |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | Release 启用 R8 混淆 | 静态扫描：build.gradle.kts isMinifyEnabled 检查 |
| SC-02 | P0 | 无硬编码密钥/Token | 模式匹配：密钥关键词扫描 |
| SC-03 | P0 | Network Security Config 已配置 | 静态扫描：XML 文件存在检查 |
| SC-04 | P0 | 无 TrustAllCerts | 模式匹配：SSL 校验禁用扫描 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库使用 Room | 模式匹配：@Dao / @Entity 检查 |
| DA-02 | P0 | DAO 方法使用 suspend/Flow | 模式匹配：Dao 方法签名检查 |
| DA-03 | P0 | 网络请求通过 Retrofit | 模式匹配：API 接口声明检查 |
| DA-04 | P0 | 无主线程数据库操作 | 人工审查 |

## 七、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 列表使用 LazyColumn/RecyclerView | 模式匹配：ScrollView + 动态列表检查 |
| PF-02 | P0 | 无主线程阻塞操作 | 人工审查 |
| PF-03 | P1 | Compose 使用 remember 缓存 | 模式匹配：Composable 中计算检查 |
| PF-04 | P1 | 图片使用 Coil/Glide | 模式匹配：Bitmap.decode 调用检查 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 使用 Timber 日志 | 模式匹配：Log.d/Log.v 调用检查 |
| OB-02 | P0 | 日志无敏感信息 | 人工审查 |
| OB-03 | P0 | Crashlytics 已集成 | 人工审查 |

## 九、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 无 !!（非空断言） | 模式匹配：!! 操作符扫描 |
| FB-02 | P0 | 无 GlobalScope.launch | 模式匹配：关键词扫描 |
| FB-03 | P0 | 无新增 Java 文件（新项目） | 模式匹配：.java 文件新增检查 |
| FB-04 | P0 | 无 println() / Log.d() | 模式匹配：关键词扫描 |

---

## 十、框架专项检查

### Compose 追加项（profiles/compose/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CP-01 | P0 | 无状态 Composable 优先（状态提升） | 人工审查 |
| CP-02 | P0 | Screen 有 @Preview 函数 | 模式匹配：@Preview 存在检查 |
| CP-03 | P0 | LazyColumn 提供 key 参数 | 模式匹配：items() 调用中 key 参数检查 |

### XML Views 追加项（profiles/xml-views/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| XV-01 | P0 | 使用 ViewBinding，无 findViewById | 模式匹配：findViewById 调用扫描 |
| XV-02 | P0 | RecyclerView 使用 ListAdapter + DiffUtil | 模式匹配：notifyDataSetChanged 调用检查 |
| XV-03 | P0 | ViewBinding 在 onDestroyView 中置空 | 人工审查 |
