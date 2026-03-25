# rules/react-native/common/testing-and-release.md

## 文档目标
1. 定义 React Native 应用的测试与发布规范，覆盖单元测试、E2E 测试、CI/CD、OTA 更新。

---

## 单元测试（MUST）

1. 必须使用 **Jest** 作为测试框架，项目根目录包含 `jest.config.js`。
2. 测试文件与源文件同目录，命名为 `*.test.ts(x)` 或 `*.spec.ts(x)`。
3. 核心业务逻辑（Service / Utils / Custom Hook）的单元测试覆盖率要求 ≥ 80%。
4. Custom Hook 测试使用 `@testing-library/react-hooks` 的 `renderHook`。
5. 异步逻辑测试必须正确处理 Promise / Timer（使用 `jest.useFakeTimers()`）。
6. Mock 外部依赖（API 调用、原生模块）使用 `jest.mock()` 或 MSW（Mock Service Worker）。
7. 测试文件禁止包含业务逻辑代码。

```typescript
// useAuth.test.ts
import { renderHook, act } from '@testing-library/react-hooks';
import { useAuth } from './useAuth';

jest.mock('@/services/authService');

describe('useAuth', () => {
  it('should login successfully', async () => {
    const { result } = renderHook(() => useAuth());
    await act(async () => {
      await result.current.login({ phone: '13800138000', code: '123456' });
    });
    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

---

## 组件测试（MUST）

1. 必须使用 **React Native Testing Library**（`@testing-library/react-native`）进行组件测试。
2. 组件测试关注用户交互行为，禁止测试组件内部实现细节（state / ref）。
3. 查询元素优先使用 `getByRole` / `getByText` / `getByTestId`，禁止使用 `getByType` 等实现相关查询。
4. 所有可交互元素必须设置 `testID` 属性，供测试和 E2E 使用。
5. 组件测试必须覆盖：正常渲染、空状态、加载状态、错误状态。

```typescript
import { render, fireEvent } from '@testing-library/react-native';
import { OrderCard } from './OrderCard';

describe('OrderCard', () => {
  it('should display order info and handle cancel', () => {
    const onCancel = jest.fn();
    const { getByText, getByTestId } = render(
      <OrderCard order={mockOrder} onCancel={onCancel} />,
    );
    expect(getByText('订单号: 12345')).toBeTruthy();
    fireEvent.press(getByTestId('cancel-button'));
    expect(onCancel).toHaveBeenCalledWith('12345');
  });
});
```

---

## E2E 测试（MUST）

1. 必须使用 **Detox**（Wix）或 **Maestro** 进行端到端测试。
2. E2E 测试必须覆盖核心用户路径：注册 / 登录 → 首页浏览 → 核心操作（下单/支付）→ 登出。
3. E2E 测试在 CI 中使用模拟器 / 真机运行，每次 PR 合并前必须通过。
4. 测试数据必须使用独立的测试环境，禁止使用生产数据。
5. E2E 测试中页面元素定位使用 `testID`，禁止使用文本内容匹配（多语言场景不稳定）。

```typescript
// e2e/login.test.ts (Detox)
describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('should login with phone number', async () => {
    await element(by.id('phone-input')).typeText('13800138000');
    await element(by.id('code-input')).typeText('123456');
    await element(by.id('login-button')).tap();
    await expect(element(by.id('home-screen'))).toBeVisible();
  });
});
```

---

## CI/CD 流水线（MUST）

1. 每次 PR 必须执行以下检查，全部通过才允许合并：
   - TypeScript 类型检查（`tsc --noEmit`）。
   - ESLint 检查（`eslint --max-warnings 0`）。
   - 单元测试（`jest --coverage`）。
   - 组件测试。
2. 合并到主分支后自动触发：
   - E2E 测试（Detox / Maestro）。
   - Android / iOS 构建。
   - 构建产物上传到分发平台（Firebase App Distribution / Testflight / 蒲公英）。
3. 推荐使用 **Fastlane** 管理 iOS / Android 构建与分发流程。
4. 禁止从本地开发机直接构建并上传应用商店，必须通过 CI 流水线。
5. 禁止跳过 CI 检查直接合并代码。

---

## OTA 更新（SHOULD）

1. 推荐使用 **EAS Update**（Expo）或 **CodePush**（`react-native-code-push`）实现热更新。
2. OTA 更新仅限 JS Bundle 和资源文件变更，原生代码变更必须走应用商店发版。
3. OTA 更新必须配置灰度发布策略（按用户百分比逐步推送）。
4. OTA 更新包必须签名校验，防止中间人攻击篡改。
5. 必须配置回滚机制：OTA 更新后崩溃率异常时自动回滚到上一版本。
6. OTA 更新的版本号必须与原生版本兼容性对齐（`targetBinaryVersion`）。

---

## 发版流程（MUST）

1. 发版必须遵循以下流程：
   1. 从主分支创建 `release/x.y.z` 分支。
   2. 更新版本号（`package.json` + `build.gradle` + `Info.plist`）。
   3. 执行全量测试（单元 + E2E）。
   4. CI 构建 Release 产物。
   5. 上传到应用商店审核（App Store Connect / Google Play Console）。
   6. 审核通过后打 Git Tag，合并回主分支。
2. 生产构建禁止使用 debug 签名。
3. 每次发版必须编写 Release Notes，记录新功能 / Bug 修复 / 已知问题。
4. 发版后必须监控 24 小时崩溃率，异常时启动回滚。

---

## 测试环境管理（MUST）

1. 测试环境必须与生产环境隔离（独立的 API / 数据库 / 第三方服务）。
2. 测试账号必须使用专用测试数据，禁止使用真实用户数据。
3. E2E 测试必须在每次运行前重置测试数据。

---

## 禁止事项

1. 禁止从本地开发机直接构建并上传应用商店。
2. 禁止生产构建使用 debug 签名。
3. 禁止跳过 CI 检查直接合并。
4. 禁止 OTA 更新包含原生代码变更。
5. 禁止 E2E 测试使用生产环境数据。
6. 禁止发版时不上传 Source Map 到崩溃收集平台。
