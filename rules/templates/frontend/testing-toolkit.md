# 测试工具包模板

## 文档目标
1. 提供 Vitest 配置、testing-library 安装、常见测试模式示例，支撑测试规范落地。
2. 测试规则参见 `common/testing.md`。

## 使用方式
- **谁用**：项目初始化者、前端开发者。
- **何时用**：新建项目配置测试框架时；编写组件/composable/工具函数测试时参考模式。
- **怎么用**：复制配置文件到项目根目录，按示例编写测试。

---

## 一、依赖安装

### 1.1 Vue 项目

```bash
# 测试框架
npm install -D vitest @vue/test-utils

# testing-library（推荐）
npm install -D @testing-library/vue @testing-library/jest-dom @testing-library/user-event

# 覆盖率
npm install -D @vitest/coverage-v8

# HTTP Mock（推荐）
npm install -D msw
```

### 1.2 React 项目

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event
npm install -D @vitest/coverage-v8 msw jsdom
```

---

## 二、Vitest 配置

### 2.1 配置文件（`vitest.config.ts`）

```ts
// vitest.config.ts
// 测试框架配置，含覆盖率门槛

import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  test: {
    /** 测试环境 */
    environment: 'jsdom',

    /** 全局导入（无需每个文件 import describe/it/expect） */
    globals: true,

    /** setup 文件 */
    setupFiles: ['./tests/setup.ts'],

    /** 包含的测试文件 */
    include: ['src/**/*.test.ts', 'src/**/*.spec.ts'],

    /** 排除 E2E 测试 */
    exclude: ['e2e/**', 'node_modules/**'],

    /** 覆盖率配置 */
    coverage: {
      /** 覆盖率工具 */
      provider: 'v8',

      /** 覆盖率报告格式 */
      reporter: ['text', 'text-summary', 'lcov', 'html'],

      /** 纳入覆盖率统计的文件 */
      include: ['src/**/*.{ts,tsx,vue}'],

      /** 排除的文件 */
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.test.ts',
        'src/**/*.spec.ts',
        'src/**/types.ts',
        'src/**/index.ts',     // 纯导出文件
        'src/main.ts',
        'src/App.vue',
      ],

      /** 覆盖率门槛 — 与 testing.md 规则一致 */
      thresholds: {
        /** 项目整体 */
        lines: 60,
        branches: 60,
        functions: 60,
        statements: 60,
      },
    },
  },
})
```

### 2.2 setup 文件（`tests/setup.ts`）

```ts
// tests/setup.ts
// 全局测试 setup，所有测试文件执行前运行

import { cleanup } from '@testing-library/vue'
import '@testing-library/jest-dom/vitest'
import { afterEach, vi } from 'vitest'

/** 每个测试后自动清理 DOM */
afterEach(() => {
  cleanup()
})

/** Mock 浏览器 API（按需启用） */
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})

/** Mock IntersectionObserver（懒加载组件需要） */
class MockIntersectionObserver {
  observe = vi.fn()
  unobserve = vi.fn()
  disconnect = vi.fn()
}
Object.defineProperty(window, 'IntersectionObserver', {
  writable: true,
  value: MockIntersectionObserver,
})
```

---

## 三、常见测试模式示例

### 3.1 工具函数测试

```ts
// src/utils/format.test.ts
import { describe, it, expect } from 'vitest'
import { formatPrice, formatDate } from './format'

describe('formatPrice', () => {
  it('应将分转换为元并保留两位小数', () => {
    expect(formatPrice(1999)).toBe('19.99')
    expect(formatPrice(100)).toBe('1.00')
    expect(formatPrice(0)).toBe('0.00')
  })

  it('应处理负数', () => {
    expect(formatPrice(-500)).toBe('-5.00')
  })
})

describe('formatDate', () => {
  it('应格式化为 YYYY-MM-DD', () => {
    expect(formatDate(new Date('2025-03-15'))).toBe('2025-03-15')
  })
})
```

### 3.2 Composable 测试

```ts
// src/composables/useCounter.test.ts
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

/** 辅助函数：在 Vue setup 上下文中执行 composable */
function withSetup<T>(composable: () => T): T {
  let result: T
  const app = createApp({
    setup() {
      result = composable()
      return () => {}
    },
  })
  app.mount(document.createElement('div'))
  return result!
}

describe('useCounter', () => {
  it('初始值应为 0', () => {
    const { count } = withSetup(() => useCounter())
    expect(count.value).toBe(0)
  })

  it('increment 应加 1', () => {
    const { count, increment } = withSetup(() => useCounter())
    increment()
    expect(count.value).toBe(1)
  })

  it('应支持自定义初始值', () => {
    const { count } = withSetup(() => useCounter(10))
    expect(count.value).toBe(10)
  })
})
```

### 3.3 组件测试（testing-library）

```ts
// src/components/base/__tests__/BaseEmpty.test.ts
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/vue'
import BaseEmpty from '../BaseEmpty.vue'

describe('BaseEmpty', () => {
  it('应显示默认提示文字', () => {
    render(BaseEmpty)
    expect(screen.getByText('暂无数据')).toBeInTheDocument()
  })

  it('应显示自定义提示文字', () => {
    render(BaseEmpty, {
      props: { message: '没有订单' },
    })
    expect(screen.getByText('没有订单')).toBeInTheDocument()
  })

  it('应渲染 action 插槽内容', () => {
    render(BaseEmpty, {
      slots: {
        action: '<button>重试</button>',
      },
    })
    expect(screen.getByRole('button', { name: '重试' })).toBeInTheDocument()
  })
})
```

### 3.4 异步组件测试（含 API Mock）

```ts
// src/components/business/__tests__/OrderList.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'
import OrderList from '../OrderList.vue'
import * as orderService from '@/services/order'

/** Mock service 层 */
vi.mock('@/services/order')

/** 测试数据 */
const mockOrders = [
  { id: '1', orderNo: 'ORD-001', status: 1, createdAt: '2025-03-15' },
  { id: '2', orderNo: 'ORD-002', status: 0, createdAt: '2025-03-16' },
]

describe('OrderList', () => {
  beforeEach(() => {
    vi.mocked(orderService.fetchOrders).mockResolvedValue(mockOrders)
  })

  it('加载完成后应显示订单列表', async () => {
    render(OrderList)

    /** 等待异步数据加载 */
    await waitFor(() => {
      expect(screen.getByText('ORD-001')).toBeInTheDocument()
      expect(screen.getByText('ORD-002')).toBeInTheDocument()
    })
  })

  it('加载失败时应显示错误提示和重试按钮', async () => {
    vi.mocked(orderService.fetchOrders).mockRejectedValue(new Error('网络错误'))

    render(OrderList)

    await waitFor(() => {
      expect(screen.getByText('加载失败')).toBeInTheDocument()
    })

    /** 点击重试 */
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: '重试' }))

    expect(orderService.fetchOrders).toHaveBeenCalledTimes(2)
  })
})
```

### 3.5 Pinia Store 测试

```ts
// src/stores/__tests__/useUserStore.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from '../useUserStore'

describe('useUserStore', () => {
  beforeEach(() => {
    /** 每个测试创建独立的 Pinia 实例 */
    setActivePinia(createPinia())
  })

  it('初始状态应为未登录', () => {
    const store = useUserStore()
    expect(store.isLoggedIn).toBe(false)
    expect(store.user).toBeNull()
  })

  it('login 应设置用户信息', async () => {
    const store = useUserStore()
    await store.login({ username: 'test', password: '123' })
    expect(store.isLoggedIn).toBe(true)
    expect(store.user?.username).toBe('test')
  })
})
```

---

## 四、MSW（Mock Service Worker）配置

### 4.1 Mock 处理器（`tests/mocks/handlers.ts`）

```ts
// tests/mocks/handlers.ts
// 定义 API Mock 处理器，统一管理测试用 Mock 数据

import { http, HttpResponse } from 'msw'

/** 订单相关 Mock */
export const orderHandlers = [
  http.get('/api/orders', () => {
    return HttpResponse.json({
      code: 0,
      data: {
        list: [
          { id: '1', orderNo: 'ORD-001', status: 1 },
          { id: '2', orderNo: 'ORD-002', status: 0 },
        ],
        total: 2,
      },
    })
  }),

  http.get('/api/orders/:id', ({ params }) => {
    return HttpResponse.json({
      code: 0,
      data: { id: params.id, orderNo: `ORD-${params.id}`, status: 1 },
    })
  }),
]

/** 汇总所有 handlers */
export const handlers = [...orderHandlers]
```

### 4.2 MSW Server（`tests/mocks/server.ts`）

```ts
// tests/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

### 4.3 在 setup 中启动 MSW

```ts
// tests/setup.ts 中追加
import { server } from './mocks/server'
import { beforeAll, afterAll, afterEach } from 'vitest'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

---

## 五、package.json 脚本

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

---

## 六、CI 集成

```yaml
# .github/workflows/ci.yml 片段
- name: 单元测试 + 覆盖率
  run: npm run test:coverage

- name: 上传覆盖率报告
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage/
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 项目必须配置 Vitest + 覆盖率门槛（整体 ≥ 60%） |
| 2 | MUST | 公共组件必须有 testing-library 测试 |
| 3 | MUST | 测试 Mock 数据统一放在 `tests/fixtures/` 或 `tests/mocks/` |
| 4 | MUST | 新增代码增量覆盖率 ≥ 80% |
| 5 | SHOULD | 使用 MSW 统一管理 HTTP Mock |
| 6 | SHOULD | E2E 测试覆盖核心业务路径（发布前执行） |

检查方式：CI 覆盖率报告 + 人工审查
阻断级别：MUST 条款阻断合并
