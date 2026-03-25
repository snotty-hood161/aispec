# uni.request 标准封装模板

## 文档目标
1. 定义 uni-app 项目（H5 + 小程序）统一请求层封装，替代直接调用 `uni.request`。
2. 适用于 `applications/wechat-h5.md` 和 `applications/miniprogram.md`，两端共用一套封装。
3. 禁止在 uni-app 项目中使用 Axios，统一使用本封装。

---

## 目录结构（MUST）

```
src/
  services/
    request/
      index.ts          # 统一导出
      instance.ts       # 核心请求封装
      interceptors.ts   # 拦截器（请求/响应）
      types.ts          # 类型定义
      error-codes.ts    # 错误码映射
    modules/
      order.ts          # 订单接口
      user.ts           # 用户接口
```

---

## 类型定义（`types.ts`）

```ts
// services/request/types.ts

/** 请求配置 */
export interface RequestConfig {
  /** 接口路径（不含 baseURL） */
  url: string
  /** 请求方法 */
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
  /** 请求参数（GET 拼接 query，POST 放 body） */
  data?: Record<string, unknown>
  /** 自定义请求头 */
  header?: Record<string, string>
  /** 超时时间（毫秒），默认 15000 */
  timeout?: number
  /** 是否显示全局 loading，默认 false */
  showLoading?: boolean
  /** loading 提示文字 */
  loadingText?: string
  /** 是否静默处理错误（不弹 toast），默认 false */
  silent?: boolean
}

/** 后端统一响应格式 */
export interface ApiResponse<T = unknown> {
  /** 业务状态码，0 表示成功 */
  code: number
  /** 提示信息 */
  message: string
  /** 响应数据 */
  data: T
}

/** 请求错误 */
export class RequestError extends Error {
  /** HTTP 状态码（网络层错误时为 0） */
  statusCode: number
  /** 业务错误码（非业务错误时为 -1） */
  bizCode: number

  constructor(message: string, statusCode: number, bizCode: number = -1) {
    super(message)
    this.name = 'RequestError'
    this.statusCode = statusCode
    this.bizCode = bizCode
  }
}
```

---

## 核心封装（`instance.ts`）

```ts
// services/request/instance.ts

import type { RequestConfig, ApiResponse } from './types'
import { RequestError } from './types'
import { requestInterceptor, responseInterceptor } from './interceptors'

/** 环境变量读取 baseURL */
const BASE_URL = import.meta.env.VITE_API_BASE_URL as string

/** 默认超时 15 秒 */
const DEFAULT_TIMEOUT = 15000

/**
 * 核心请求函数
 * 所有接口调用统一走此函数，禁止直接调用 uni.request
 */
export function request<T = unknown>(config: RequestConfig): Promise<T> {
  const { url, method = 'GET', data, header, timeout, showLoading = false, loadingText = '加载中...', silent = false } = config

  /** 请求前拦截（注入 token、公共参数等） */
  const finalHeader = requestInterceptor(header)

  if (showLoading) {
    uni.showLoading({ title: loadingText, mask: true })
  }

  return new Promise<T>((resolve, reject) => {
    uni.request({
      url: `${BASE_URL}${url}`,
      method,
      data,
      header: finalHeader,
      timeout: timeout ?? DEFAULT_TIMEOUT,
      success: (res) => {
        try {
          const result = responseInterceptor<T>(res, silent)
          resolve(result)
        } catch (error) {
          reject(error)
        }
      },
      fail: (err) => {
        /** 网络异常统一处理 */
        const error = new RequestError(
          err.errMsg || '网络异常，请检查网络连接',
          0,
        )
        if (!silent) {
          uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
        }
        reject(error)
      },
      complete: () => {
        if (showLoading) {
          uni.hideLoading()
        }
      },
    })
  })
}

/** GET 快捷方法 */
export function get<T = unknown>(url: string, data?: Record<string, unknown>, config?: Partial<RequestConfig>): Promise<T> {
  return request<T>({ url, method: 'GET', data, ...config })
}

/** POST 快捷方法 */
export function post<T = unknown>(url: string, data?: Record<string, unknown>, config?: Partial<RequestConfig>): Promise<T> {
  return request<T>({ url, method: 'POST', data, ...config })
}

/** PUT 快捷方法 */
export function put<T = unknown>(url: string, data?: Record<string, unknown>, config?: Partial<RequestConfig>): Promise<T> {
  return request<T>({ url, method: 'PUT', data, ...config })
}

/** DELETE 快捷方法 */
export function del<T = unknown>(url: string, data?: Record<string, unknown>, config?: Partial<RequestConfig>): Promise<T> {
  return request<T>({ url, method: 'DELETE', data, ...config })
}
```

---

## 拦截器（`interceptors.ts`）

```ts
// services/request/interceptors.ts

import type { ApiResponse } from './types'
import { RequestError } from './types'
import { ERROR_CODE_MAP } from './error-codes'

/** Token 存储 key */
const TOKEN_KEY = 'user_token'

/**
 * 请求拦截器
 * 注入公共请求头（Authorization、平台标识等）
 */
export function requestInterceptor(
  header?: Record<string, string>,
): Record<string, string> {
  const token = uni.getStorageSync(TOKEN_KEY) as string
  const merged: Record<string, string> = {
    'Content-Type': 'application/json',
    ...header,
  }

  if (token) {
    merged['Authorization'] = `Bearer ${token}`
  }

  return merged
}

/**
 * 响应拦截器
 * 统一处理业务错误码、鉴权过期、服务端异常
 */
export function responseInterceptor<T>(
  res: UniApp.RequestSuccessCallbackResult,
  silent: boolean,
): T {
  const { statusCode } = res
  const body = res.data as ApiResponse<T>

  /** HTTP 状态码非 2xx */
  if (statusCode < 200 || statusCode >= 300) {
    handleHttpError(statusCode, silent)
    throw new RequestError(
      `HTTP 错误：${statusCode}`,
      statusCode,
    )
  }

  /** 业务状态码非成功 */
  if (body.code !== 0) {
    handleBizError(body.code, body.message, silent)
    throw new RequestError(
      body.message || '请求失败',
      statusCode,
      body.code,
    )
  }

  return body.data
}

/** HTTP 层错误处理 */
function handleHttpError(statusCode: number, silent: boolean): void {
  /** 401：token 过期，跳转登录 */
  if (statusCode === 401) {
    uni.removeStorageSync(TOKEN_KEY)
    /** 延迟跳转，避免并发请求重复触发 */
    redirectToLogin()
    return
  }

  if (!silent) {
    const msg = statusCode === 403
      ? '无权限访问'
      : statusCode === 500
        ? '服务器异常，请稍后重试'
        : `请求错误（${statusCode}）`
    uni.showToast({ title: msg, icon: 'none' })
  }
}

/** 业务层错误处理 */
function handleBizError(code: number, message: string, silent: boolean): void {
  /** 特殊业务码：登录过期 */
  if (code === 10401) {
    uni.removeStorageSync(TOKEN_KEY)
    redirectToLogin()
    return
  }

  if (!silent) {
    /** 优先使用错误码映射表，兜底使用服务端返回的 message */
    const displayMsg = ERROR_CODE_MAP[code] ?? message ?? '操作失败'
    uni.showToast({ title: displayMsg, icon: 'none' })
  }
}

/** 防重复跳转标记 */
let isRedirecting = false

/** 跳转登录页（防并发重复跳转） */
function redirectToLogin(): void {
  if (isRedirecting) {
    return
  }
  isRedirecting = true
  uni.reLaunch({
    url: '/pages/login/index',
    complete: () => {
      isRedirecting = false
    },
  })
}
```

---

## 错误码映射（`error-codes.ts`）

```ts
// services/request/error-codes.ts

/**
 * 业务错误码 → 用户可读提示
 * 由服务端统一定义，前端维护映射表
 * 新增错误码时在此文件追加，禁止在组件中硬编码
 */
export const ERROR_CODE_MAP: Record<number, string> = {
  10401: '登录已过期，请重新登录',
  10403: '无权限执行此操作',
  20001: '参数校验失败',
  20002: '数据不存在',
  20003: '数据已存在，请勿重复提交',
  30001: '操作频繁，请稍后重试',
}
```

---

## 统一导出（`index.ts`）

```ts
// services/request/index.ts

export { request, get, post, put, del } from './instance'
export type { RequestConfig, ApiResponse } from './types'
export { RequestError } from './types'
```

---

## 业务接口调用示例

```ts
// services/modules/order.ts

import { get, post } from '@/services/request'

/** 订单列表项 */
export interface OrderItem {
  id: string
  orderNo: string
  status: number
  amount: number
  createdAt: string
}

/** 订单列表查询参数 */
export interface OrderListParams {
  page: number
  pageSize: number
  status?: number
}

/** 获取订单列表 */
export function getOrderList(params: OrderListParams): Promise<{
  list: OrderItem[]
  total: number
}> {
  return get('/api/v1/orders', params as Record<string, unknown>)
}

/** 取消订单 */
export function cancelOrder(orderId: string): Promise<void> {
  return post(`/api/v1/orders/${orderId}/cancel`)
}
```

### 页面中使用

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getOrderList } from '@/services/modules/order'
import type { OrderItem } from '@/services/modules/order'

const list = ref<OrderItem[]>([])
const loading = ref(false)

/** 加载订单列表 */
async function loadOrders(): Promise<void> {
  loading.value = true
  try {
    const res = await getOrderList({ page: 1, pageSize: 20 })
    list.value = res.list
  } catch {
    /** 错误已在拦截器统一处理，此处仅做 UI 状态恢复 */
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadOrders()
})
</script>
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | uni-app 项目禁止直接调用 `uni.request`，统一通过本封装调用 |
| 2 | MUST | uni-app 项目禁止引入 Axios，请求层仅使用 `uni.request` 封装 |
| 3 | MUST | 所有接口定义在 `services/modules/` 下，组件内禁止直接写请求 |
| 4 | MUST | 接口函数必须声明入参和返回值类型，禁止 `any` |
| 5 | MUST | 错误码映射统一维护在 `error-codes.ts`，禁止在组件中硬编码错误提示 |
| 6 | MUST | Token 过期（HTTP 401 或业务码 10401）自动跳转登录，防止并发重复跳转 |
| 7 | MUST | 请求超时必须设置上限（默认 15 秒），禁止无超时请求 |
| 8 | SHOULD | 支持 `silent` 模式，允许调用方自行处理特定错误 |
| 9 | SHOULD | 文件上传使用 `uni.uploadFile` 单独封装，不混入本请求层 |

检查方式：代码审查 + ESLint 自定义规则（禁止直接调用 `uni.request`）
阻断级别：MUST 条款阻断合并
