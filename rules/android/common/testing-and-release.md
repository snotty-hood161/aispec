# rules/android/common/testing-and-release.md

## 文档目标
1. 定义 Android 应用的测试策略和发布流程。

---

## 测试策略（MUST）

### 单元测试
1. Domain Layer（UseCase）和 Data Layer（Repository）必须有单元测试。
2. 测试框架使用 **JUnit 5** + **MockK**（或 Mockito-Kotlin）。
3. 测试文件与源文件同包名，放在 `src/test/` 目录。
4. ViewModel 测试使用 `Turbine`（测试 StateFlow/SharedFlow）。

```kotlin
class GetUserUseCaseTest {
    private val repository = mockk<UserRepository>()
    private val useCase = GetUserUseCase(repository)

    @Test
    fun `returns user when repository succeeds`() = runTest {
        val expected = User(id = 1, name = "test")
        coEvery { repository.getUser(1) } returns Result.success(expected)

        val result = useCase(1)

        assertTrue(result.isSuccess)
        assertEquals(expected, result.getOrNull())
    }
}
```

### UI 测试
1. Compose UI 测试使用 **Compose Test** 库（`createComposeRule`）。
2. XML UI 测试使用 **Espresso**。
3. 关键用户流程（登录、核心业务操作）必须有 UI 测试覆盖。

```kotlin
class HomeScreenTest {
    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun displaysUserName() {
        composeRule.setContent {
            HomeScreen(uiState = HomeUiState(user = User(name = "Alice")))
        }
        composeRule.onNodeWithText("Alice").assertIsDisplayed()
    }
}
```

### 测试覆盖率
1. Domain Layer 覆盖率 >= 80%。
2. Data Layer 覆盖率 >= 70%。
3. UI Layer（ViewModel）覆盖率 >= 60%。
4. 覆盖率通过 **JaCoCo** 采集，CI 中生成报告。

---

## CI 流水线（MUST）

```yaml
# 每次 PR 必须通过的检查
- ./gradlew ktlintCheck      # 代码格式
- ./gradlew detekt            # 静态分析
- ./gradlew lint               # Android Lint
- ./gradlew testDebugUnitTest  # 单元测试
- ./gradlew assembleRelease    # 构建验证
```

1. 以上检查全部通过才允许合并 PR。
2. 定期（每周或每次 Release）执行完整 UI 测试。

---

## 发布流程（MUST）

### 版本号规范
1. 遵循 SemVer（`MAJOR.MINOR.PATCH`）。
2. `versionCode` 单调递增，`versionName` 与 SemVer 同步。
3. 推荐使用 CI 自动计算 `versionCode`（如基于 commit count 或构建号）。

### 发布检查清单
1. 所有测试通过。
2. CHANGELOG 已更新。
3. 版本号已递增。
4. 签名密钥已配置到 CI/CD。
5. ProGuard mapping 文件已上传到 Crashlytics。

### 发布渠道

| 阶段 | 渠道 | 说明 |
|------|------|------|
| 内部测试 | Firebase App Distribution | 团队内部验证 |
| 预发布 | Google Play 内部测试轨道 | 小范围用户验证 |
| 正式发布 | Google Play 生产轨道 | 分阶段发布（推荐 10% → 50% → 100%） |

### 代码签名（MUST）
1. Release APK/AAB 必须使用正式签名密钥签名。
2. 推荐启用 Google Play App Signing，上传密钥与签名密钥分离。
3. 签名密钥通过 CI/CD Secret 管理，禁止提交到版本控制。
4. 必须使用 **App Bundle**（`.aab`）格式上架 Google Play。
