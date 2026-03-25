# 组件化与适配模板

## 文档目标
1. 提供三端组件示例模板、适配层标准接口定义、组件 API 文档生成流程。
2. 组件化规则参见 `common/componentization-and-adaptation.md`。

---

## 一、三端组件示例模板

### 1.1 组件分层示例

```
src/
  components/
    base/               ← 基础组件（无业务逻辑）
      BaseButton.vue
      BaseEmpty.vue
      BaseLoading.vue
    business/            ← 业务组件（含业务逻辑，可调 services）
      OrderCard.vue
      ProductList.vue
      UserAvatar.vue
  views/                 ← 页面组件（路由入口，编排数据）
    order/
      list.vue
      detail.vue
```

### 1.2 基础组件示例（三端通用）

```vue
<!-- components/base/BaseEmpty.vue -->
<!-- 空态组件：所有端共用，样式通过 token 驱动 -->
<template>
  <div class="flex flex-col items-center justify-center py-12">
    <image
      v-if="icon"
      :src="icon"
      class="mb-4 h-24 w-24 opacity-40"
      mode="aspectFit"
    />
    <text class="mb-2 text-sm text-gray-400">{{ message }}</text>
    <slot name="action" />
  </div>
</template>

<script setup lang="ts">
/** 空态提示文字 */
withDefaults(defineProps<{
  /** 提示文字 */
  message?: string
  /** 图标路径（可选） */
  icon?: string
}>(), {
  message: '暂无数据',
  icon: '',
})
</script>
```

### 1.3 业务组件示例（后台管理）

```vue
<!-- components/business/OrderCard.vue -->
<!-- 订单卡片：依赖 services 获取状态文案，通过事件通知父组件 -->
<template>
  <div class="rounded-md border border-gray-200 p-4">
    <!-- 加载态 -->
    <el-skeleton v-if="loading" :rows="3" animated />

    <!-- 异常态 -->
    <BaseEmpty v-else-if="error" message="加载失败">
      <template #action>
        <el-button type="primary" link @click="emit('retry')">重试</el-button>
      </template>
    </BaseEmpty>

    <!-- 正常态 -->
    <template v-else>
      <div class="flex items-center justify-between">
        <span class="text-sm font-medium">{{ order.orderNo }}</span>
        <el-tag :type="statusTag.type" size="small">{{ statusTag.label }}</el-tag>
      </div>
      <div class="mt-2 text-xs text-gray-400">{{ order.createdAt }}</div>
      <div class="mt-3 flex justify-end gap-2">
        <el-button size="small" @click="emit('view', order)">查看</el-button>
        <el-button v-if="order.status === 0" size="small" type="danger" @click="emit('cancel', order)">取消</el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseEmpty from '@/components/base/BaseEmpty.vue'

/** 订单数据 */
export interface OrderData {
  id: string
  orderNo: string
  status: number
  createdAt: string
}

const props = defineProps<{
  order: OrderData
  loading?: boolean
  error?: boolean
}>()

const emit = defineEmits<{
  view: [order: OrderData]
  cancel: [order: OrderData]
  retry: []
}>()

/** 状态映射 */
const STATUS_MAP: Record<number, { label: string; type: 'warning' | 'success' | 'info' | 'danger' }> = {
  0: { label: '待支付', type: 'warning' },
  1: { label: '已支付', type: 'success' },
  2: { label: '已取消', type: 'info' },
  3: { label: '已退款', type: 'danger' },
}

const statusTag = computed(() => STATUS_MAP[props.order.status] ?? { label: '未知', type: 'info' })
</script>
```

### 1.4 业务组件示例（uni-app 小程序端）

```vue
<!-- components/business/OrderCard.vue（uni-app 版本） -->
<!-- 同一业务组件，UI 可不同但交互语义一致 -->
<template>
  <view class="rounded-lg border border-gray-200 p-3">
    <!-- 加载态 -->
    <view v-if="loading" class="py-6 text-center text-sm text-gray-400">加载中...</view>

    <!-- 异常态 -->
    <BaseEmpty v-else-if="error" message="加载失败">
      <template #action>
        <button class="text-sm text-primary" @tap="emit('retry')">点击重试</button>
      </template>
    </BaseEmpty>

    <!-- 正常态 -->
    <template v-else>
      <view class="flex items-center justify-between">
        <text class="text-sm font-medium">{{ order.orderNo }}</text>
        <text class="rounded-sm px-2 py-0.5 text-xs" :class="statusClass">{{ statusLabel }}</text>
      </view>
      <text class="mt-1 block text-xs text-gray-400">{{ order.createdAt }}</text>
      <view class="mt-2 flex justify-end gap-2">
        <button class="text-sm text-primary" @tap="emit('view', order)">查看</button>
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseEmpty from '@/components/base/BaseEmpty.vue'
import type { OrderData } from './types'

const props = defineProps<{
  order: OrderData
  loading?: boolean
  error?: boolean
}>()

const emit = defineEmits<{
  view: [order: OrderData]
  cancel: [order: OrderData]
  retry: []
}>()

const STATUS_MAP: Record<number, { label: string; class: string }> = {
  0: { label: '待支付', class: 'bg-yellow-50 text-yellow-600' },
  1: { label: '已支付', class: 'bg-green-50 text-green-600' },
  2: { label: '已取消', class: 'bg-gray-50 text-gray-500' },
  3: { label: '已退款', class: 'bg-red-50 text-red-600' },
}

const statusLabel = computed(() => STATUS_MAP[props.order.status]?.label ?? '未知')
const statusClass = computed(() => STATUS_MAP[props.order.status]?.class ?? 'bg-gray-50 text-gray-500')
</script>
```

---

## 二、适配层标准接口定义模板

### 2.1 目录结构

```
src/
  platform/
    interface.ts          ← 适配层接口定义（所有端共用）
    h5/
      wechat/             ← H5 微信能力实现
        auth.ts
        share.ts
        payment.ts
      storage.ts          ← H5 存储适配
      location.ts         ← H5 定位适配
    mp-weixin/
      auth.ts             ← 小程序登录实现
      share.ts            ← 小程序分享实现
      payment.ts          ← 小程序支付实现
      storage.ts          ← 小程序存储适配
      location.ts         ← 小程序定位适配
```

### 2.2 接口定义（`interface.ts`）

```ts
// platform/interface.ts
// 所有端特有能力必须实现此接口，页面通过接口调用，不直接引用平台实现

/** 授权登录 */
export interface IAuthAdapter {
  /** 检查登录状态 */
  checkLogin(): Promise<boolean>
  /** 执行登录 */
  login(): Promise<{ token: string }>
  /** 退出登录 */
  logout(): Promise<void>
}

/** 分享 */
export interface IShareAdapter {
  /** 设置分享配置 */
  setupShare(config: ShareConfig): Promise<void>
}

export interface ShareConfig {
  title: string
  desc?: string
  link?: string
  imgUrl?: string
}

/** 支付 */
export interface IPaymentAdapter {
  /** 发起支付 */
  pay(params: PaymentParams): Promise<PaymentResult>
}

export interface PaymentParams {
  orderId: string
  amount: number
}

export interface PaymentResult {
  success: boolean
  message: string
}

/** 定位 */
export interface ILocationAdapter {
  /** 获取当前位置 */
  getLocation(): Promise<{ latitude: number; longitude: number }>
}

/** 存储 */
export interface IStorageAdapter {
  get<T>(key: string): T | null
  set<T>(key: string, value: T): void
  remove(key: string): void
  clear(): void
}
```

### 2.3 H5 端实现示例

```ts
// platform/h5/storage.ts
import type { IStorageAdapter } from '../interface'

/** H5 端存储适配（localStorage） */
export const h5Storage: IStorageAdapter = {
  get<T>(key: string): T | null {
    const val = localStorage.getItem(key)
    if (val === null) return null
    try {
      return JSON.parse(val) as T
    } catch {
      return val as unknown as T
    }
  },
  set<T>(key: string, value: T): void {
    localStorage.setItem(key, JSON.stringify(value))
  },
  remove(key: string): void {
    localStorage.removeItem(key)
  },
  clear(): void {
    localStorage.clear()
  },
}
```

### 2.4 小程序端实现示例

```ts
// platform/mp-weixin/storage.ts
import type { IStorageAdapter } from '../interface'

/** 小程序端存储适配（uni.setStorage） */
export const mpStorage: IStorageAdapter = {
  get<T>(key: string): T | null {
    try {
      return uni.getStorageSync(key) as T || null
    } catch {
      return null
    }
  },
  set<T>(key: string, value: T): void {
    uni.setStorageSync(key, value)
  },
  remove(key: string): void {
    uni.removeStorageSync(key)
  },
  clear(): void {
    uni.clearStorageSync()
  },
}
```

### 2.5 统一导出（根据编译目标自动选择）

```ts
// platform/index.ts
// 根据 uni-app 条件编译自动选择端实现

// #ifdef H5
export { h5Storage as storage } from './h5/storage'
// #endif

// #ifdef MP-WEIXIN
export { mpStorage as storage } from './mp-weixin/storage'
// #endif
```

---

## 三、组件 API 文档生成流程

### 3.1 方案选型

使用 **`vue-docgen-cli`**（基于 `vue-docgen-api`），从 `.vue` 文件中提取 props、events、slots 自动生成 Markdown 文档。

### 3.2 安装

```bash
npm install -D vue-docgen-cli
```

### 3.3 配置文件（`docgen.config.js`）

```js
// docgen.config.js
/** @type {import('vue-docgen-cli').DocgenCLIConfig} */
module.exports = {
  /** 扫描公共组件目录 */
  componentsDir: 'src/components',
  /** 输出目录 */
  outDir: 'docs/components',
  /** 输出文件名模式 */
  getDestFile: (file, config) =>
    file.replace(config.componentsDir, config.outDir).replace(/\.vue$/, '.md'),
  /** 模板 */
  templates: {
    /** 组件文档头部模板 */
    component: (renderedUsage, doc) => {
      const { displayName, description } = doc
      return `# ${displayName}\n\n${description || ''}\n\n${renderedUsage.props}\n${renderedUsage.events}\n${renderedUsage.slots}\n`
    },
  },
}
```

### 3.4 脚本配置

```json
{
  "scripts": {
    "docs:components": "vue-docgen-cli"
  }
}
```

### 3.5 执行与输出

```bash
npm run docs:components
```

输出示例（`docs/components/base/BaseEmpty.md`）：

```markdown
# BaseEmpty

空态提示组件，所有端共用。

## Props

| 名称 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| message | string | '暂无数据' | 提示文字 |
| icon | string | '' | 图标路径（可选） |

## Slots

| 名称 | 说明 |
|------|------|
| action | 操作区域（如重试按钮） |
```

### 3.6 CI 集成

```yaml
# 在 CI 中检查组件文档是否过期
- name: 生成组件文档
  run: npm run docs:components

- name: 检查文档是否有未提交变更
  run: git diff --exit-code docs/components/
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 基础组件不含业务请求，业务组件不被跨页面复用，页面组件只做编排 |
| 2 | MUST | 组件必须覆盖空态/加载态/异常态三种状态 |
| 3 | MUST | 端特有能力必须通过适配层接口调用，页面禁止直接调用平台 API |
| 4 | MUST | 适配层接口定义在 `platform/interface.ts`，各端实现在 `platform/<target>/` |
| 5 | MUST | 同一业务组件跨端时交互语义必须一致（props/events 签名相同） |
| 6 | SHOULD | 公共组件使用 `vue-docgen-cli` 生成 API 文档，CI 中检查文档是否同步 |
| 7 | SHOULD | 公共组件准入需至少两处复用 + 使用示例 + 回归测试 |

检查方式：代码审查 + CI 文档同步检查
阻断级别：MUST 条款阻断合并
