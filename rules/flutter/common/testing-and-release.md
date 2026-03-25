# rules/flutter/common/testing-and-release.md

## 文档目标
1. 定义 Flutter 应用的测试策略与发布流程规范。

---

## 测试策略（MUST）

### 测试金字塔
1. 必须遵循测试金字塔原则：Unit Tests > Widget Tests > Integration Tests。

| 测试类型 | 覆盖目标 | 最低覆盖率 |
|---------|---------|-----------|
| Unit Test | 纯 Dart 逻辑（UseCase / Repository / Util） | 核心业务 ≥ 70% |
| Widget Test | 单个 Widget 的渲染与交互 | 关键页面组件 ≥ 50% |
| Integration Test | 端到端用户流程 | 核心业务路径 100% |

### 单元测试（MUST）
1. 所有 UseCase / BLoC / Cubit / ViewModel 必须有单元测试。
2. 使用 **mocktail** 或 **mockito** 进行依赖 Mock。
3. 测试文件命名：`{源文件名}_test.dart`，位于 `test/` 对应目录结构下。
4. 使用 `group()` 组织测试用例，`test()` 描述使用 `should xxx when xxx` 格式。

```dart
void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  group('LoginRequested', () {
    test('should emit [loading, authenticated] when login succeeds', () {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => testUser);

      authBloc.add(const LoginRequested(phone: '13800138000', code: '123456'));

      expect(
        authBloc.stream,
        emitsInOrder([
          const AuthState.loading(),
          AuthState.authenticated(testUser),
        ]),
      );
    });
  });
}
```

### Widget 测试（MUST）
1. 关键页面组件必须有 Widget Test，验证渲染结果和交互行为。
2. 使用 `testWidgets()` + `WidgetTester` 驱动 Widget 测试。
3. 使用 `find.byType` / `find.text` / `find.byKey` 定位 Widget。

### Integration 测试（SHOULD）
1. 核心业务流程（登录 → 下单 → 支付）必须有 Integration Test。
2. 使用 `integration_test` 包在真机或模拟器上运行。
3. CI 中至少包含核心路径的 Integration Test。

### Golden 测试（SHOULD）
1. 推荐对关键 UI 组件添加 Golden Test（截图对比），防止 UI 回归。
2. 使用 `matchesGoldenFile()` 比对渲染输出。
3. Golden 文件纳入版本控制。

---

## CI/CD 流水线（MUST）

### CI（每次 PR / Push 触发）
1. 流水线阶段顺序：`analyze → format check → test → build`。
2. 必须包含以下检查：

```yaml
# GitHub Actions 示例
jobs:
  ci:
    steps:
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart analyze --fatal-infos
      - run: dart format --set-exit-if-changed .
      - run: flutter test --coverage
      - run: flutter build apk --debug  # 构建验证
```

3. 测试覆盖率低于阈值时阻断合并。
4. 推荐使用 Melos（Monorepo）或 Very Good CLI 管理 CI 任务。

### CD（发布流程）
1. 生产构建必须从 CI 流水线产出，禁止本地手动构建发布。
2. 构建产物签名必须通过 CI Secret 注入，禁止提交签名文件到代码仓库。
3. 推荐使用 **Fastlane** 或 **Codemagic** 自动化发布到 App Store / Google Play。

---

## 发布规范（MUST）

### 版本管理
1. 版本号遵循语义化版本：`major.minor.patch+buildNumber`。
2. `pubspec.yaml` 中 `version` 字段为唯一版本来源。
3. 每次发布必须更新 CHANGELOG.md。
4. 使用 Git Tag 标记每次发布版本。

### 应用商店发布
1. Google Play：使用 App Bundle（.aab）格式，启用 Play App Signing。
2. App Store：使用 Xcode Archive 或 Fastlane 上传。
3. 首次发布前必须完成：
   - 隐私政策页面。
   - 应用截图（各设备尺寸）。
   - 数据安全声明（Google Play）/ 隐私营养标签（App Store）。

### 灰度发布
1. 推荐使用 Google Play 分阶段发布（Staged Rollout）。
2. 推荐使用 TestFlight 进行 iOS 内测分发。
3. 灰度期间监控崩溃率和关键业务指标。

---

## 禁止事项

1. 禁止从本地开发机直接构建并上传应用商店。
2. 禁止跳过 CI 检查直接合并（`--no-verify`）。
3. 禁止生产构建使用 debug 签名。
4. 禁止发布没有对应 CHANGELOG 条目的版本。
