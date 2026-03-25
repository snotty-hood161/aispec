# rules/ios/common/testing-and-release.md

## 文档目标
1. 定义 iOS 应用的测试策略和发布流程。

---

## 测试策略（MUST）

### 单元测试
1. Domain Layer（UseCase）和 Data Layer（Repository）必须有单元测试。
2. 测试框架使用 **XCTest**（内置）或 **swift-testing**（Swift 6+）。
3. Mock 依赖使用协议 + 手动 Mock 或 swift-dependencies。
4. ViewModel 测试验证状态变化和错误处理。

```swift
final class GetUserUseCaseTests: XCTestCase {
    func test_execute_returnsUser() async throws {
        let mockRepo = MockUserRepository()
        mockRepo.stubbedUser = User(id: 1, name: "test")
        let useCase = GetUserUseCase(repository: mockRepo)

        let result = try await useCase.execute(id: 1)

        XCTAssertEqual(result.name, "test")
    }
}
```

### UI 测试
1. 关键用户流程（登录、核心业务操作）必须有 **XCUITest** 覆盖。
2. 测试使用 Accessibility Identifier 定位元素，禁止依赖文本内容（多语言兼容）。
3. SwiftUI Preview 用于快速验证 UI 组件。

```swift
final class LoginUITests: XCUITestCase {
    func test_login_success() {
        let app = XCUIApplication()
        app.launch()

        app.textFields["email_input"].tap()
        app.textFields["email_input"].typeText("user@example.com")
        app.secureTextFields["password_input"].tap()
        app.secureTextFields["password_input"].typeText("password123")
        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["welcome_label"].waitForExistence(timeout: 5))
    }
}
```

### 测试覆盖率
1. Domain Layer 覆盖率 >= 80%。
2. Data Layer 覆盖率 >= 70%。
3. ViewModel 覆盖率 >= 60%。
4. 覆盖率通过 Xcode Coverage 或 `xccov` 采集。

---

## CI 流水线（MUST）

```yaml
# 每次 PR 必须通过的检查
- swiftlint lint --strict       # 代码规范
- swiftformat --lint .          # 代码格式
- xcodebuild test               # 单元测试
- xcodebuild build              # 构建验证
```

1. 以上检查全部通过才允许合并 PR。
2. 推荐使用 **Fastlane** 编排 CI 流程。
3. CI 环境使用 macOS Runner（GitHub Actions macOS / 自建 Mac Mini）。

---

## 发布流程（MUST）

### 版本号规范
1. 遵循 SemVer（`MAJOR.MINOR.PATCH`），对应 `CFBundleShortVersionString`。
2. Build Number（`CFBundleVersion`）单调递增，推荐使用 CI 构建号。
3. 版本号通过 xcconfig 或 Fastlane 自动管理。

### 发布检查清单
1. 所有测试通过。
2. CHANGELOG 已更新。
3. 版本号已递增。
4. 签名证书和 Provisioning Profile 已配置。
5. dSYM 已上传到崩溃报告平台。

### 发布渠道

| 阶段 | 渠道 | 说明 |
|------|------|------|
| 内部测试 | TestFlight 内部测试 | 团队内部验证（最多 100 人） |
| 外部测试 | TestFlight 外部测试 | Beta 用户验证（最多 10000 人） |
| 正式发布 | App Store | 分阶段发布（推荐 7 天自动分阶段） |

### 代码签名（MUST）
1. 必须使用 Apple Distribution Certificate 签名发布构建。
2. 推荐使用 Fastlane Match 统一团队签名管理。
3. 签名证书通过 CI/CD Secret 管理，禁止提交到版本控制。
4. 发布到 App Store 必须经过 Apple 审核。

### App Store 审核注意事项（MUST）
1. 隐私政策 URL 必须有效且内容完整。
2. 应用描述与实际功能一致。
3. 权限申请必须附带使用说明（Info.plist Usage Description）。
4. 不使用私有 API。
