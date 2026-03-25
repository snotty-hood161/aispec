# rules/android/common/architecture.md

## 整体架构

Android 应用采用 **Clean Architecture** 分层设计，结合 **MVVM / MVI** 表现层模式：
- **UI Layer**：Activity/Fragment/Composable 负责 UI 渲染，ViewModel 负责 UI 状态管理。
- **Domain Layer**（可选）：UseCase 封装可复用的业务逻辑。
- **Data Layer**：Repository 聚合数据源（本地 + 远程），对上层屏蔽实现细节。

## 分层规则（MUST）

### 模块化分层
```text
app/
├── src/main/java/com/example/app/
│   ├── di/                      # Hilt 依赖注入模块
│   ├── ui/                      # UI Layer
│   │   ├── navigation/          # 导航图定义
│   │   ├── theme/               # Material Theme 定义
│   │   └── feature/             # 按功能分包
│   │       ├── home/
│   │       │   ├── HomeScreen.kt        # Composable UI
│   │       │   ├── HomeViewModel.kt     # ViewModel
│   │       │   └── HomeUiState.kt       # UI State
│   │       └── profile/
│   │           ├── ProfileScreen.kt
│   │           ├── ProfileViewModel.kt
│   │           └── ProfileUiState.kt
│   ├── domain/                  # Domain Layer（可选）
│   │   ├── model/               # 领域模型
│   │   ├── usecase/             # UseCase
│   │   └── repository/          # Repository 接口定义
│   └── data/                    # Data Layer
│       ├── local/               # 本地数据源（Room DAO、DataStore）
│       ├── remote/              # 远程数据源（Retrofit Service）
│       ├── model/               # 数据传输对象（DTO、Entity）
│       ├── mapper/              # DTO ↔ Domain Model 映射
│       └── repository/          # Repository 实现
```

### 依赖方向
```
UI (Composable/Fragment) → ViewModel → UseCase → Repository Interface
                                                        ↑
                                        Repository Implementation
                                       ┌────────┴────────┐
                                  LocalDataSource    RemoteDataSource
```

1. 依赖方向单向向下，禁止反向依赖。
2. Domain Layer 不依赖 Android Framework（纯 Kotlin）。
3. Data Layer 实现 Domain Layer 定义的 Repository 接口。
4. UI Layer 仅通过 ViewModel 访问数据，禁止直接调用 Repository。

## 依赖注入（MUST）

1. 必须使用 **Hilt** 作为依赖注入框架。
2. 所有依赖通过构造函数注入，禁止字段注入（`@Inject lateinit var` 仅限 Android 组件）。
3. Module 按职责拆分（`NetworkModule`、`DatabaseModule`、`RepositoryModule`）。

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient =
        OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor())
            .build()

    @Provides
    @Singleton
    fun provideRetrofit(client: OkHttpClient): Retrofit =
        Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
}
```

## ViewModel 规范（MUST）

1. ViewModel 必须继承 `androidx.lifecycle.ViewModel`。
2. UI 状态使用 `StateFlow<UiState>` 暴露，禁止使用 `LiveData`（新项目）。
3. 一次性事件（导航、Toast）使用 `SharedFlow` 或 `Channel`，禁止在 `StateFlow` 中传递。
4. ViewModel 禁止持有 `Context`、`View`、`Activity` 引用（需要 Application Context 使用 `@HiltViewModel` + `@ApplicationContext`）。

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private val _events = Channel<HomeEvent>(Channel.BUFFERED)
    val events: Flow<HomeEvent> = _events.receiveAsFlow()

    fun loadUser(userId: Long) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            getUserUseCase(userId)
                .onSuccess { user -> _uiState.update { it.copy(user = user, isLoading = false) } }
                .onFailure { error -> _events.send(HomeEvent.ShowError(error.message)) }
        }
    }
}

data class HomeUiState(
    val user: User? = null,
    val isLoading: Boolean = false,
)

sealed interface HomeEvent {
    data class ShowError(val message: String?) : HomeEvent
    data class NavigateTo(val route: String) : HomeEvent
}
```

## 导航规范（MUST）

1. 使用 Navigation Compose（Compose 项目）或 Navigation Component（XML 项目）。
2. 路由定义集中管理，禁止硬编码路由字符串。
3. 跨模块导航通过接口或 DeepLink 解耦。
