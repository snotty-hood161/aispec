# rules/frontend/common/testing.md

## 文档目标
1. 定义三端前端项目的测试策略、覆盖率要求、Mock 规范。
2. 框架特定测试模式参见 `frameworks/*.md`。

## 单元测试（MUST）
1. 工具函数、composable/hook、service 层必须有单元测试。
2. 覆盖率门槛：
   - 核心业务逻辑（services/、composables/、utils/）：行覆盖率 ≥ **80%**。
   - 项目整体：行覆盖率 ≥ **60%**。
   - 新增代码（增量覆盖率）：≥ **80%**。
3. 覆盖率不达标时 CI 阻断合并。
4. 测试必须是确定性的，禁止依赖外部服务、系统时间、随机数（需 Mock）。
检查方式：CI 覆盖率报告（vitest --coverage）
阻断级别：阻断合并

## 组件测试（MUST）
1. 所有公共组件（`components/base/`、`components/business/`）必须有组件测试。
2. 使用 `@testing-library/vue`（Vue 项目）或 `@testing-library/react`（React 项目）。
3. 测试用户行为，不测试实现细节：
   - **正确**：`getByRole('button')` → `click` → 断言页面变化。
   - **错误**：直接访问组件内部 `ref`、调用私有方法。
4. 每个公共组件至少覆盖：正常态、空态、加载态、异常态。
5. 禁止在测试中直接操作组件内部状态（如 `wrapper.vm.xxx = ...`）。
检查方式：CI + 人工审查
阻断级别：阻断合并

## 快照测试（SHOULD）
1. 仅用于 UI 回归检测（样式/结构变化的安全网）。
2. 适用场景：基础组件、布局组件等变更频率低的组件。
3. 禁止对以下组件使用快照测试：
   - 频繁变更的业务组件。
   - 包含动态数据（日期、随机 ID）的组件。
4. 快照变更必须在 Code Review 中人工确认，禁止盲目 `--update`。
5. 快照文件（`__snapshots__/`）必须提交到仓库。
检查方式：人工审查
阻断级别：告警记录

## E2E 测试（SHOULD）
1. 关键业务路径必须有 E2E 测试覆盖：
   - 后台管理：登录 → 核心列表 CRUD → 退出。
   - H5：授权登录 → 核心业务流程 → 分享。
2. 工具选型：Playwright（后台管理）或 Cypress。
3. E2E 测试独立于单元测试执行，不阻断日常 CI，在发布前流水线中执行。
4. 小程序端通过真机调试 + 手动测试覆盖核心路径，不强制自动化 E2E。
检查方式：发布前 CI 流水线
阻断级别：告警记录

## 测试文件组织（MUST）
1. 工具函数/composable 测试：与源文件同目录，命名 `{name}.test.ts`。
2. 组件测试：组件目录下 `__tests__/{ComponentName}.test.ts`。
3. E2E 测试：项目根目录 `e2e/` 下按页面/流程组织。
4. 测试辅助工具：`tests/helpers/` 或 `tests/fixtures/`。

```
src/
  utils/
    format.ts
    format.test.ts          ← 工具函数测试（同目录）
  composables/
    useOrder.ts
    useOrder.test.ts        ← composable 测试（同目录）
  components/
    base/
      BaseEmpty.vue
      __tests__/
        BaseEmpty.test.ts   ← 组件测试（__tests__ 子目录）
e2e/
  login.spec.ts             ← E2E 测试（项目根目录）
  order-crud.spec.ts
tests/
  helpers/
    render-with-providers.ts ← 测试辅助工具
  fixtures/
    mock-order.ts            ← 测试数据
```

检查方式：人工审查
阻断级别：告警记录

## Mock 策略（MUST）
1. **必须 Mock**：
   - 外部 HTTP API 调用（使用 `msw` 或 `vi.mock`）。
   - 浏览器/平台特有 API（localStorage、uni.xxx、wx.xxx）。
   - 定时器、日期（`vi.useFakeTimers`）。
2. **禁止 Mock**：
   - 被测模块自身（自己 Mock 自己无意义）。
   - 语言原生能力（Array.map、Promise 等）。
3. **优先真实调用**：
   - 内部 composable/service 之间优先真实调用，仅在隔离测试边界时 Mock。
   - Pinia store 优先使用 `createTestingPinia` 而非手写 Mock。
4. Mock 数据统一放在 `tests/fixtures/`，禁止在测试文件中硬编码大段 JSON。
检查方式：人工审查
阻断级别：阻断合并

## 测试命名规范（SHOULD）
1. `describe` 块以被测模块/组件名命名。
2. `it`/`test` 以"should + 行为描述"命名（英文）或"当...时，应该..."（中文）。
3. 同一项目统一中文或英文，不混用。

```ts
// 英文风格
describe('useOrder', () => {
  it('should return loading state initially', () => { ... })
  it('should fetch orders on mount', () => { ... })
})

// 中文风格
describe('useOrder', () => {
  it('初始状态应为加载中', () => { ... })
  it('挂载后应自动获取订单列表', () => { ... })
})
```

检查方式：人工审查
阻断级别：告警记录

## 配套模板
1. Vitest 配置 + testing-library 样板 + 常见测试模式示例 → `rules/templates/frontend/testing-toolkit.md`
