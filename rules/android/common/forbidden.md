# rules/android/common/forbidden.md

## 文档目标
1. 汇总 Android 应用开发中的禁止事项，便于快速检查。

---

## 语言禁止事项

1. 禁止新项目新增 Java 源文件（旧项目维护允许修改已有 Java 文件）。
2. 禁止使用 `!!`（非空断言），必须使用安全调用（`?.`）、`requireNotNull()` 或 `checkNotNull()`。
3. 禁止使用 `var` 定义可被 `val` 替代的变量。
4. 禁止使用 `Any` 类型替代具体类型定义。
5. 禁止使用 `@Suppress("UNCHECKED_CAST")` 绕过类型检查而不加注释说明。
6. 禁止使用 `GlobalScope.launch`，必须使用结构化并发（`viewModelScope`、`lifecycleScope`）。

## 架构禁止事项

7. 禁止 UI 层（Activity/Fragment/Composable）直接访问 DAO 或 API Service。
8. 禁止 ViewModel 持有 `Context`、`View`、`Activity`、`Fragment` 引用。
9. 禁止在 ViewModel 中使用 `LiveData`（新项目，使用 `StateFlow`）。
10. 禁止循环依赖（模块间单向依赖）。
11. 禁止使用 `EventBus` / `LocalBroadcastManager` 进行组件通信。

## 主线程禁止事项

12. 禁止在主线程执行网络请求。
13. 禁止在主线程执行数据库读写。
14. 禁止在主线程执行文件 IO 操作。
15. 禁止使用 `Thread.sleep()` 在主线程等待。

## 安全禁止事项

16. 禁止硬编码 API 密钥、Token、密码到源代码。
17. 禁止使用明文 HTTP 传输数据（必须 HTTPS）。
18. 禁止关闭 SSL 证书校验。
19. 禁止使用 `MODE_WORLD_READABLE` / `MODE_WORLD_WRITEABLE`。
20. 禁止在日志中输出敏感信息（Token、密码、用户隐私数据）。
21. 禁止在 Release 构建中启用 `debuggable = true`。

## 存储禁止事项

22. 禁止使用 `SharedPreferences` 存储敏感信息（使用 EncryptedSharedPreferences）。
23. 禁止将敏感数据写入外部存储（`/sdcard/`）。
24. 禁止在生产环境使用 `fallbackToDestructiveMigration()`。

## UI 禁止事项

25. 禁止硬编码字符串到布局或代码中（必须使用 `strings.xml`）。
26. 禁止在 XML 布局中硬编码颜色值（必须通过 Theme 属性引用）。
27. 禁止使用 `ScrollView` 嵌套动态长列表（使用 `RecyclerView` / `LazyColumn`）。
28. 禁止使用 `px` 单位定义尺寸（使用 `dp` / `sp`）。

## 发布禁止事项

29. 禁止发布未经混淆的 Release 构建。
30. 禁止跳过代码签名直接分发 APK。
31. 禁止将签名密钥提交到版本控制。
32. 禁止发布未经 `./gradlew testDebugUnitTest` 验证的代码。
