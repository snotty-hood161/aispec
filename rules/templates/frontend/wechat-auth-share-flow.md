# 微信授权与分享流程规范

## 文档目标
1. 定义公众号 H5 项目中微信授权登录、JSSDK 签名、分享配置的标准流程与时序。
2. 微信生态规则约束参见 `applications/wechat-h5.md` 第 5 章。
3. 所有微信能力必须封装在 `platform/h5/wechat/` 适配层，页面禁止直连 JSSDK。

---

## 目录结构（MUST）

```
src/
  platform/
    h5/
      wechat/
        index.ts          # 统一导出
        auth.ts           # 授权登录
        jssdk.ts          # JSSDK 初始化与签名
        share.ts          # 分享配置
        payment.ts        # 微信支付
        types.ts          # 类型定义
```

---

## 一、微信授权登录流程

### 时序图

```
用户              前端 H5             服务端              微信开放平台
 │                  │                  │                    │
 │  访问页面         │                  │                    │
 │─────────────────>│                  │                    │
 │                  │                  │                    │
 │                  │ 检查本地 token    │                    │
 │                  │ (uni.getStorage) │                    │
 │                  │                  │                    │
 │          [无 token 或已过期]         │                    │
 │                  │                  │                    │
 │                  │ GET /api/wechat/ │                    │
 │                  │ auth-url?redirect│                    │
 │                  │────────────────> │                    │
 │                  │                  │                    │
 │                  │ 返回授权 URL      │                    │
 │                  │ <────────────────│                    │
 │                  │                  │                    │
 │  302 跳转微信授权页                  │                    │
 │ <────────────────│                  │                    │
 │                  │                  │                    │
 │  用户同意授权     │                  │                    │
 │ ─────────────────────────────────────────────────────> │
 │                  │                  │                    │
 │  302 回调 redirect_uri?code=xxx     │                    │
 │ ─────────────────>                  │                    │
 │                  │                  │                    │
 │                  │ POST /api/wechat/│                    │
 │                  │ login { code }   │                    │
 │                  │────────────────> │                    │
 │                  │                  │                    │
 │                  │                  │ 用 code 换 token    │
 │                  │                  │ ──────────────────>│
 │                  │                  │                    │
 │                  │                  │ 返回 openid 等      │
 │                  │                  │ <──────────────────│
 │                  │                  │                    │
 │                  │ 返回业务 token    │                    │
 │                  │ + 用户信息        │                    │
 │                  │ <────────────────│                    │
 │                  │                  │                    │
 │                  │ 存储 token        │                    │
 │                  │ (uni.setStorage) │                    │
 │                  │                  │                    │
 │  展示登录后页面   │                  │                    │
 │ <────────────────│                  │                    │
```

### 核心代码（`auth.ts`）

```ts
// platform/h5/wechat/auth.ts

const TOKEN_KEY = 'user_token'

/**
 * 微信授权登录入口
 * 检测 URL 中是否有 code 参数，有则换 token，无则跳转授权
 */
export async function handleWechatAuth(): Promise<void> {
  const token = uni.getStorageSync(TOKEN_KEY) as string

  /** 已有有效 token，跳过授权 */
  if (token) {
    return
  }

  const code = getUrlParam('code')

  if (code) {
    /** 有 code，向服务端换取 token */
    await exchangeCodeForToken(code)
  } else {
    /** 无 code，跳转微信授权页 */
    await redirectToWechatAuth()
  }
}

/** 从 URL 中提取参数 */
function getUrlParam(name: string): string | null {
  const url = new URL(window.location.href)
  return url.searchParams.get(name)
}

/** 跳转微信授权页 */
async function redirectToWechatAuth(): Promise<void> {
  const currentUrl = encodeURIComponent(window.location.href)
  const { data } = await uni.request({
    url: `${import.meta.env.VITE_API_BASE_URL}/api/wechat/auth-url`,
    data: { redirect: currentUrl },
  })
  /** 服务端返回完整授权 URL，前端直接跳转 */
  window.location.href = (data as { url: string }).url
}

/** 用 code 换取业务 token */
async function exchangeCodeForToken(code: string): Promise<void> {
  try {
    const { data } = await uni.request({
      url: `${import.meta.env.VITE_API_BASE_URL}/api/wechat/login`,
      method: 'POST',
      data: { code },
    })
    const result = data as { token: string }
    uni.setStorageSync(TOKEN_KEY, result.token)

    /** 清理 URL 中的 code 参数，防止刷新重复使用 */
    cleanUrlParams(['code', 'state'])
  } catch {
    uni.showToast({ title: '登录失败，请重试', icon: 'none' })
  }
}

/** 清理 URL 参数（防止 code 重复使用） */
function cleanUrlParams(params: string[]): void {
  const url = new URL(window.location.href)
  params.forEach((p) => url.searchParams.delete(p))
  window.history.replaceState({}, '', url.toString())
}
```

---

## 二、JSSDK 签名流程

### 时序图

```
前端 H5             服务端              微信开放平台
 │                  │                    │
 │ 页面加载 / 路由切换                    │
 │                  │                    │
 │ POST /api/wechat/│                    │
 │ jssdk-signature  │                    │
 │ { url }          │                    │
 │─────────────────>│                    │
 │                  │                    │
 │                  │ 用 jsapi_ticket    │
 │                  │ + url 生成签名      │
 │                  │ (ticket 需缓存)     │
 │                  │                    │
 │ 返回 appId,      │                    │
 │ timestamp,       │                    │
 │ nonceStr,        │                    │
 │ signature        │                    │
 │<─────────────────│                    │
 │                  │                    │
 │ wx.config({...}) │                    │
 │                  │                    │
 │ wx.ready(() => { │                    │
 │   // 注册分享等   │                    │
 │ })               │                    │
```

### 核心代码（`jssdk.ts`）

```ts
// platform/h5/wechat/jssdk.ts

import wx from 'weixin-js-sdk'
import type { JssdkSignature } from './types'

/** 签名缓存，同一 URL 不重复请求 */
let lastSignedUrl = ''

/**
 * 初始化 JSSDK
 * 每次路由切换后必须重新签名（iOS 单页应用使用首次进入 URL）
 */
export async function initJssdk(apiList: string[]): Promise<void> {
  const signUrl = getSignUrl()

  /** 同一 URL 不重复签名 */
  if (signUrl === lastSignedUrl) {
    return
  }

  try {
    const signature = await fetchSignature(signUrl)
    await configWx(signature, apiList)
    lastSignedUrl = signUrl
  } catch {
    console.error('[JSSDK] 签名初始化失败')
  }
}

/**
 * 获取签名用 URL
 * iOS 微信 SPA 签名 URL 为首次进入页面的 URL（非当前路由）
 * Android 使用当前 URL
 */
function getSignUrl(): string {
  const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent)
  if (isIOS) {
    /** iOS 首次进入 URL 需在 App 初始化时记录 */
    return window.__INITIAL_URL__ || window.location.href.split('#')[0]
  }
  return window.location.href.split('#')[0]
}

/** 请求服务端生成签名 */
async function fetchSignature(url: string): Promise<JssdkSignature> {
  const { data } = await uni.request({
    url: `${import.meta.env.VITE_API_BASE_URL}/api/wechat/jssdk-signature`,
    method: 'POST',
    data: { url },
  })
  return data as JssdkSignature
}

/** 调用 wx.config 注册 */
function configWx(signature: JssdkSignature, apiList: string[]): Promise<void> {
  return new Promise((resolve, reject) => {
    wx.config({
      debug: import.meta.env.DEV,
      appId: signature.appId,
      timestamp: signature.timestamp,
      nonceStr: signature.nonceStr,
      signature: signature.signature,
      jsApiList: apiList,
    })

    wx.ready(() => resolve())
    wx.error((err: { errMsg: string }) => {
      console.error('[JSSDK] config 失败:', err.errMsg)
      reject(new Error(err.errMsg))
    })
  })
}
```

### iOS 首次 URL 记录

```ts
// App.vue 或入口文件
// iOS 微信浏览器 SPA 签名必须使用首次进入的 URL
declare global {
  interface Window {
    __INITIAL_URL__?: string
  }
}

if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
  window.__INITIAL_URL__ = window.location.href.split('#')[0]
}
```

---

## 三、分享配置流程

### 时序图

```
前端 H5             微信 JSSDK
 │                    │
 │ 页面加载 / 路由切换 │
 │                    │
 │ initJssdk([        │
 │   'updateAppMessage│ShareData',
 │   'updateTimeline  │ShareData'
 │ ])                 │
 │───────────────────>│
 │                    │
 │ wx.ready 回调       │
 │<───────────────────│
 │                    │
 │ wx.updateAppMessage│ShareData({
 │   title, desc,     │
 │   link, imgUrl     │
 │ })                 │
 │───────────────────>│
 │                    │
 │ wx.updateTimeline  │ShareData({
 │   title, link,     │
 │   imgUrl           │
 │ })                 │
 │───────────────────>│
 │                    │
 │ 分享配置完成        │
```

### 核心代码（`share.ts`）

```ts
// platform/h5/wechat/share.ts

import wx from 'weixin-js-sdk'
import { initJssdk } from './jssdk'

/** 分享参数 */
export interface ShareConfig {
  /** 分享标题 */
  title: string
  /** 分享描述（发送给朋友时显示） */
  desc: string
  /** 分享链接（必须与当前页面同域名） */
  link?: string
  /** 分享图标 URL（建议 300×300px） */
  imgUrl: string
}

/** 默认分享配置 */
const DEFAULT_SHARE: ShareConfig = {
  title: '',
  desc: '',
  imgUrl: '',
}

/**
 * 设置页面分享配置
 * 每个需要分享的页面在 onMounted / onShow 中调用
 */
export async function setupShare(config: ShareConfig): Promise<void> {
  const shareData = { ...DEFAULT_SHARE, ...config }

  /** 分享链接默认为当前页面 URL */
  if (!shareData.link) {
    shareData.link = window.location.href
  }

  try {
    await initJssdk([
      'updateAppMessageShareData',
      'updateTimelineShareData',
    ])

    /** 分享给朋友 */
    wx.updateAppMessageShareData({
      title: shareData.title,
      desc: shareData.desc,
      link: shareData.link,
      imgUrl: shareData.imgUrl,
      success: () => {
        /** 分享配置成功（非用户点击分享） */
      },
      fail: () => {
        console.error('[Share] 分享给朋友配置失败')
      },
    })

    /** 分享到朋友圈 */
    wx.updateTimelineShareData({
      title: shareData.title,
      link: shareData.link,
      imgUrl: shareData.imgUrl,
      success: () => {
        /** 分享配置成功 */
      },
      fail: () => {
        console.error('[Share] 分享到朋友圈配置失败')
      },
    })
  } catch {
    /** JSSDK 初始化失败，分享降级为微信默认行为 */
    console.error('[Share] JSSDK 初始化失败，使用默认分享')
  }
}
```

### 页面使用示例

```vue
<script setup lang="ts">
import { onMounted } from 'vue'
import { setupShare } from '@/platform/h5/wechat/share'

onMounted(() => {
  setupShare({
    title: '商品详情 - XXX',
    desc: '快来看看这个商品',
    imgUrl: 'https://cdn.example.com/share/product.png',
  })
})
</script>
```

---

## 四、异常处理（MUST）

### 必须覆盖的三类核心异常

| 异常类型 | 触发场景 | 处理方式 |
|----------|----------|----------|
| **授权拒绝** | 用户在微信授权页点击「拒绝」 | 展示引导页，说明授权用途，提供「重新授权」按钮 |
| **签名过期** | JSSDK config 失败，errMsg 包含 `invalid signature` | 清除签名缓存，重新请求签名，最多重试 1 次 |
| **弱网超时** | 授权/签名接口超时 | 展示「网络异常」提示 + 重试按钮，不自动重试 |

### 授权拒绝处理

```ts
// 路由守卫中检测授权结果
function handleAuthDenied(): void {
  const error = getUrlParam('error')
  if (error === 'access_denied') {
    /** 跳转到授权引导页，而非死循环重新授权 */
    uni.redirectTo({ url: '/pages/auth-guide/index' })
  }
}
```

### 签名失败重试

```ts
/** 签名失败自动重试（仅 1 次） */
async function initJssdkWithRetry(apiList: string[]): Promise<void> {
  try {
    await initJssdk(apiList)
  } catch {
    /** 清除缓存后重试一次 */
    lastSignedUrl = ''
    await initJssdk(apiList)
  }
}
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 微信授权、JSSDK、分享、支付统一封装在 `platform/h5/wechat/`，页面禁止直连 JSSDK |
| 2 | MUST | 授权 code 换 token 由服务端完成，前端禁止持有 AppSecret |
| 3 | MUST | 授权回调后清理 URL 中的 `code` 和 `state` 参数，防止刷新重复使用 |
| 4 | MUST | iOS 微信 SPA 必须在入口记录首次进入 URL，签名使用该 URL |
| 5 | MUST | 路由切换后必须重新初始化 JSSDK 签名（Android） |
| 6 | MUST | 覆盖授权拒绝、签名过期、弱网超时三类核心异常 |
| 7 | MUST | 分享链接必须与当前页面同域名，否则微信静默忽略 |
| 8 | SHOULD | 分享图片建议 300×300px，避免被微信裁剪 |
| 9 | SHOULD | JSSDK debug 模式仅在开发环境开启 |

检查方式：代码审查 + 功能测试（真机微信环境）
阻断级别：MUST 条款阻断合并
