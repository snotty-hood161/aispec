# rules/android/profiles/compose/project-structure.md

## 文档目标
1. 定义 Jetpack Compose 项目的标准目录结构与最佳实践。

---

## 项目结构（MUST）

```text
app/
├── build.gradle.kts
├── proguard-rules.pro
└── src/
    ├── main/
    │   ├── AndroidManifest.xml
    │   ├── java/com/example/app/
    │   │   ├── App.kt                          # Application 入口
    │   │   ├── MainActivity.kt                 # 单 Activity 入口
    │   │   ├── di/                             # Hilt 模块
    │   │   │   ├── NetworkModule.kt
    │   │   │   ├── DatabaseModule.kt
    │   │   │   └── RepositoryModule.kt
    │   │   ├── ui/                             # UI Layer
    │   │   │   ├── navigation/                 # 导航
    │   │   │   │   ├── AppNavHost.kt
    │   │   │   │   └── Routes.kt
    │   │   │   ├── theme/                      # Material 3 主题
    │   │   │   │   ├── Theme.kt
    │   │   │   │   ├── Color.kt
    │   │   │   │   ├── Typography.kt
    │   │   │   │   └── Shape.kt
    │   │   │   ├── components/                 # 通用 Composable 组件
    │   │   │   │   ├── LoadingIndicator.kt
    │   │   │   │   └── ErrorView.kt
    │   │   │   └── feature/                    # 按功能分包
    │   │   │       ├── home/
    │   │   │       │   ├── HomeScreen.kt
    │   │   │       │   ├── HomeViewModel.kt
    │   │   │       │   └── HomeUiState.kt
    │   │   │       └── profile/
    │   │   │           ├── ProfileScreen.kt
    │   │   │           ├── ProfileViewModel.kt
    │   │   │           └── ProfileUiState.kt
    │   │   ├── domain/                         # Domain Layer
    │   │   │   ├── model/
    │   │   │   ├── usecase/
    │   │   │   └── repository/                 # Repository 接口
    │   │   └── data/                           # Data Layer
    │   │       ├── local/
    │   │       │   ├── db/
    │   │       │   │   ├── AppDatabase.kt
    │   │       │   │   └── dao/
    │   │       │   └── datastore/
    │   │       ├── remote/
    │   │       │   ├── api/
    │   │       │   ├── dto/
    │   │       │   └── interceptor/
    │   │       ├── mapper/
    │   │       └── repository/                 # Repository 实现
    │   └── res/
    │       ├── values/
    │       │   ├── strings.xml
    │       │   ├── colors.xml
    │       │   └── themes.xml
    │       └── xml/
    │           └── network_security_config.xml
    ├── test/                                   # 单元测试
    │   └── java/com/example/app/
    └── androidTest/                            # UI 测试
        └── java/com/example/app/
```

---

## Compose 最佳实践（MUST）

### 单 Activity 架构
1. 使用单 Activity + Navigation Compose 管理所有页面。
2. `MainActivity` 仅负责设置 `setContent` 和全局配置。

### 状态管理
1. 每个 Screen 对应一个 ViewModel，通过 `hiltViewModel()` 注入。
2. UI State 使用不可变 `data class`，通过 `StateFlow` 暴露。
3. 用户操作封装为 Event/Intent（MVI 模式推荐）。

### Composable 函数规范
1. 无状态 Composable 优先：接收状态和回调作为参数。
2. 有状态 Composable 仅在 Screen 级别（连接 ViewModel）。
3. Preview 函数必须提供（`@Preview` 注解）。

```kotlin
@Composable
fun UserCard(
    user: User,
    onEditClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(modifier = modifier) {
        Text(text = user.name)
        IconButton(onClick = onEditClick) {
            Icon(Icons.Default.Edit, contentDescription = "编辑")
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun UserCardPreview() {
    AppTheme {
        UserCard(user = User(name = "Preview"), onEditClick = {})
    }
}
```

### 性能注意事项
1. 使用 `remember` 缓存计算结果，`derivedStateOf` 派生状态。
2. 列表使用 `LazyColumn` / `LazyRow`，必须提供 `key`。
3. 避免在 Composition 中创建新对象（lambda 稳定性）。
4. 使用 `@Stable` / `@Immutable` 注解帮助 Compose 编译器优化。

---

## 多模块项目结构（SHOULD）

大型项目推荐按功能拆分模块：

```text
project/
├── app/                    # 壳模块（组装 + 导航）
├── core/
│   ├── core-ui/            # 通用 Composable 组件 + Theme
│   ├── core-data/          # 通用数据层（网络、数据库基础）
│   ├── core-domain/        # 通用领域模型
│   └── core-common/        # 工具类、扩展函数
├── feature/
│   ├── feature-home/       # 首页功能模块
│   ├── feature-profile/    # 个人中心功能模块
│   └── feature-settings/   # 设置功能模块
├── gradle/
│   └── libs.versions.toml  # Version Catalog
└── build-logic/            # Convention Plugins
    └── convention/
```
