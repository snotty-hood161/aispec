# rules/android/common/data-access.md

## 文档目标
1. 定义 Android 应用的数据访问规范，覆盖本地数据库、网络请求、数据持久化等。

---

## Room 数据库（MUST）

1. 本地持久化必须使用 **Room** 作为 SQLite 抽象层。
2. Entity 必须使用 `@Entity` 注解并明确指定 `tableName`。
3. DAO 方法必须使用挂起函数（`suspend fun`）或返回 `Flow`。
4. 数据库版本变更必须提供 Migration，禁止使用 `fallbackToDestructiveMigration()`（生产环境）。
5. 复杂查询必须使用 `@RawQuery` 或 `@Query` 并做 SQL 注入防护。

```kotlin
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :userId")
    suspend fun getUserById(userId: Long): UserEntity?

    @Query("SELECT * FROM users ORDER BY name ASC")
    fun observeAllUsers(): Flow<List<UserEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)

    @Delete
    suspend fun deleteUser(user: UserEntity)
}
```

---

## 网络请求（MUST）

1. 必须使用 **Retrofit** + **OkHttp** 作为网络层。
2. API 接口定义使用 Retrofit `interface`，方法返回 `Response<T>` 或配合自定义 CallAdapter。
3. OkHttp Interceptor 按职责分离（认证、日志、重试）。
4. 网络请求必须在 IO 调度器（`Dispatchers.IO`）上执行。
5. 超时配置必须显式设置（连接 10s、读取 30s、写入 30s）。

```kotlin
interface UserApiService {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") userId: Long): Response<UserDto>

    @POST("users")
    suspend fun createUser(@Body request: CreateUserRequest): Response<UserDto>
}
```

---

## DataStore（MUST）

1. 键值配置存储必须使用 **Preferences DataStore** 替代 SharedPreferences。
2. 结构化配置存储推荐使用 **Proto DataStore**。
3. DataStore 实例必须通过 Hilt 注入，禁止在使用处直接创建。
4. 读取使用 `Flow`，写入使用 `suspend fun edit`。

```kotlin
val Context.settingsDataStore by preferencesDataStore(name = "settings")

class SettingsRepository @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    val themeMode: Flow<ThemeMode> = context.settingsDataStore.data
        .map { prefs -> ThemeMode.fromValue(prefs[THEME_KEY] ?: "system") }

    suspend fun setThemeMode(mode: ThemeMode) {
        context.settingsDataStore.edit { prefs ->
            prefs[THEME_KEY] = mode.value
        }
    }

    companion object {
        private val THEME_KEY = stringPreferencesKey("theme_mode")
    }
}
```

---

## Repository 模式（MUST）

1. 所有数据访问必须通过 Repository 层封装，UI 层禁止直接访问 DAO 或 API。
2. Repository 负责协调本地与远程数据源，对上层屏蔽数据来源。
3. Repository 接口定义在 Domain Layer，实现在 Data Layer。
4. 缓存策略在 Repository 内部实现，上层无需感知。

```kotlin
class UserRepositoryImpl @Inject constructor(
    private val userApi: UserApiService,
    private val userDao: UserDao,
    private val mapper: UserMapper,
) : UserRepository {

    override suspend fun getUser(id: Long): Result<User> = runCatching {
        val cached = userDao.getUserById(id)
        if (cached != null) return@runCatching mapper.toDomain(cached)

        val response = userApi.getUser(id)
        if (!response.isSuccessful) throw ServerException(response.code())

        val dto = response.body() ?: throw EmptyResponseException()
        val entity = mapper.toEntity(dto)
        userDao.insertUser(entity)
        mapper.toDomain(entity)
    }
}
```

---

## 禁止事项

1. 禁止在主线程执行数据库查询或网络请求。
2. 禁止在 Repository 中直接操作 UI（Toast、Dialog）。
3. 禁止使用 `SQLiteOpenHelper` 直接操作数据库（应使用 Room）。
4. 禁止在 Interceptor 中修改业务数据（仅限 Header、日志、重试）。
