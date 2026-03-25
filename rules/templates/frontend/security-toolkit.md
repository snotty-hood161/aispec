# 安全工具包模板

## 文档目标
1. 提供 CSP 配置、XSS 净化工具封装、依赖审计脚本、密钥泄露检测配置。
2. 安全规则参见 `common/security.md`。

## 使用方式
- **谁用**：项目初始化者、前端开发者。
- **何时用**：新建项目配置安全基线时；需要富文本净化、依赖审计时。
- **怎么用**：按需复制配置和工具到项目中，CI 中集成审计脚本。

---

## 一、Content-Security-Policy（CSP）配置

### 1.1 Meta 标签方式（适用于纯前端项目）

```html
<!-- index.html -->
<!-- CSP 策略：限制资源加载来源，防御 XSS -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' https://cdn.example.com;
  style-src 'self' 'unsafe-inline' https://cdn.example.com;
  img-src 'self' data: https: blob:;
  font-src 'self' https://cdn.example.com;
  connect-src 'self' https://api.example.com https://*.sentry.io;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
">
```

### 1.2 服务端 Header 方式（推荐）

```nginx
# nginx 配置
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self' https://cdn.example.com;
  style-src 'self' 'unsafe-inline' https://cdn.example.com;
  img-src 'self' data: https: blob:;
  font-src 'self' https://cdn.example.com;
  connect-src 'self' https://api.example.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
" always;
```

### 1.3 CSP 指令说明

| 指令 | 说明 | 建议值 |
|------|------|--------|
| `default-src` | 默认加载策略 | `'self'` |
| `script-src` | JS 来源 | `'self'` + 可信 CDN，禁止 `'unsafe-eval'` |
| `style-src` | CSS 来源 | `'self' 'unsafe-inline'`（CSS-in-JS 需要 unsafe-inline） |
| `img-src` | 图片来源 | `'self' data: https: blob:` |
| `connect-src` | XHR/Fetch 来源 | `'self'` + API 域名 + 监控上报域名 |
| `frame-src` | iframe 来源 | `'none'`（除非业务需要嵌入） |
| `object-src` | 插件来源 | `'none'` |

### 1.4 其他安全响应头

```nginx
# 防止 MIME 类型嗅探
add_header X-Content-Type-Options "nosniff" always;

# 防止点击劫持
add_header X-Frame-Options "SAMEORIGIN" always;

# 启用浏览器 XSS 过滤器
add_header X-XSS-Protection "1; mode=block" always;

# HTTPS 强制（仅生产环境）
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Referrer 策略
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

---

## 二、DOMPurify XSS 净化封装

### 2.1 安装

```bash
npm install dompurify
npm install -D @types/dompurify
```

### 2.2 封装工具（`src/utils/sanitize.ts`）

```ts
// src/utils/sanitize.ts
// XSS 净化工具，所有 v-html 渲染前必须调用

import DOMPurify from 'dompurify'

/** 默认允许的 HTML 标签（富文本场景） */
const ALLOWED_TAGS = [
  'p', 'br', 'strong', 'em', 'u', 's', 'del',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'ul', 'ol', 'li',
  'blockquote', 'pre', 'code',
  'a', 'img',
  'table', 'thead', 'tbody', 'tr', 'th', 'td',
  'div', 'span',
]

/** 默认允许的属性 */
const ALLOWED_ATTR = [
  'href', 'src', 'alt', 'title', 'class', 'style',
  'target', 'rel', 'width', 'height',
  'colspan', 'rowspan',
]

/**
 * 净化 HTML 内容（用于富文本展示）
 * @param dirty 原始 HTML 字符串
 * @returns 净化后的安全 HTML
 */
export function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS,
    ALLOWED_ATTR,
    /** 禁止 javascript: 伪协议 */
    ALLOW_UNKNOWN_PROTOCOLS: false,
    /** 链接强制添加 rel="noopener noreferrer" */
    ADD_ATTR: ['target'],
  })
}

/**
 * 净化纯文本（去除所有 HTML 标签）
 * @param dirty 原始字符串
 * @returns 纯文本
 */
export function sanitizeText(dirty: string): string {
  return DOMPurify.sanitize(dirty, { ALLOWED_TAGS: [] })
}
```

### 2.3 使用示例

```vue
<template>
  <!-- ✅ 正确：经过净化后渲染 -->
  <div v-html="safeContent" />

  <!-- ❌ 错误：直接渲染用户输入 -->
  <!-- <div v-html="rawContent" /> -->
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { sanitizeHtml } from '@/utils/sanitize'

const props = defineProps<{ rawContent: string }>()

/** 净化后的安全内容 */
const safeContent = computed(() => sanitizeHtml(props.rawContent))
</script>
```

---

## 三、敏感信息脱敏工具

```ts
// src/utils/mask.ts
// 敏感信息脱敏工具

/** 手机号脱敏：138****1234 */
export function maskPhone(phone: string): string {
  if (!phone || phone.length < 7) return phone
  return phone.replace(/(\d{3})\d{4}(\d+)/, '$1****$2')
}

/** 身份证脱敏：310***********1234 */
export function maskIdCard(idCard: string): string {
  if (!idCard || idCard.length < 8) return idCard
  return idCard.replace(/(\d{3})\d+(\d{4})/, '$1***********$2')
}

/** 银行卡脱敏：**** **** **** 5678 */
export function maskBankCard(card: string): string {
  if (!card || card.length < 4) return card
  const last4 = card.slice(-4)
  return `**** **** **** ${last4}`
}

/** 邮箱脱敏：u***@example.com */
export function maskEmail(email: string): string {
  const [name, domain] = email.split('@')
  if (!name || !domain) return email
  return `${name[0]}***@${domain}`
}
```

---

## 四、依赖审计 CI 脚本

### 4.1 npm audit 脚本（`scripts/check-audit.sh`）

```bash
#!/bin/bash
# scripts/check-audit.sh
# 依赖漏洞扫描，High/Critical 级别阻断 CI

echo "执行依赖漏洞扫描..."

# 执行审计（JSON 输出便于解析）
AUDIT_RESULT=$(npm audit --json 2>/dev/null)

# 提取各级别漏洞数量
CRITICAL=$(echo "$AUDIT_RESULT" | node -e "
  const data = require('fs').readFileSync('/dev/stdin', 'utf-8');
  try {
    const json = JSON.parse(data);
    console.log(json.metadata?.vulnerabilities?.critical || 0);
  } catch { console.log(0); }
")

HIGH=$(echo "$AUDIT_RESULT" | node -e "
  const data = require('fs').readFileSync('/dev/stdin', 'utf-8');
  try {
    const json = JSON.parse(data);
    console.log(json.metadata?.vulnerabilities?.high || 0);
  } catch { console.log(0); }
")

MODERATE=$(echo "$AUDIT_RESULT" | node -e "
  const data = require('fs').readFileSync('/dev/stdin', 'utf-8');
  try {
    const json = JSON.parse(data);
    console.log(json.metadata?.vulnerabilities?.moderate || 0);
  } catch { console.log(0); }
")

echo "扫描结果："
echo "  Critical: $CRITICAL"
echo "  High:     $HIGH"
echo "  Moderate: $MODERATE"

# Critical 或 High 漏洞阻断
if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
  echo ""
  echo "❌ 发现 Critical/High 级别漏洞，必须修复后再合并"
  echo ""
  npm audit --production 2>/dev/null
  exit 1
fi

if [ "$MODERATE" -gt 0 ]; then
  echo ""
  echo "⚠️  发现 Moderate 级别漏洞，请在 30 天内处理"
fi

echo ""
echo "✅ 依赖审计通过"
```

### 4.2 CI 集成

```yaml
# .github/workflows/ci.yml 片段
- name: 依赖漏洞扫描
  run: bash scripts/check-audit.sh
```

---

## 五、密钥泄露检测（secretlint）

### 5.1 安装

```bash
npm install -D @secretlint/secretlint-rule-preset-recommend secretlint
```

### 5.2 配置文件（`.secretlintrc.json`）

```json
{
  "rules": [
    {
      "id": "@secretlint/secretlint-rule-preset-recommend"
    }
  ]
}
```

### 5.3 package.json 脚本

```json
{
  "scripts": {
    "check:secrets": "secretlint '**/*'"
  }
}
```

### 5.4 husky pre-commit 追加

```bash
# .husky/pre-commit 中追加（在 lint-staged 之后）
npx secretlint --staged
```

---

## 六、ESLint 安全相关规则

### 6.1 Vue 项目

```js
// eslint.config.js 中追加安全规则
export default [
  {
    rules: {
      /** v-html 使用告警（提醒需要净化） */
      'vue/no-v-html': 'warn',
      /** 禁止 eval */
      'no-eval': 'error',
      /** 禁止 implied eval（setTimeout/setInterval 传字符串） */
      'no-implied-eval': 'error',
      /** 禁止 new Function */
      'no-new-func': 'error',
      /** 禁止 script: URL */
      'no-script-url': 'error',
    },
  },
]
```

---

## 七、.env.example 模板

```bash
# .env.example
# 环境变量模板 — 复制为 .env.local 后填写实际值
# 注意：.env.local 已被 .gitignore 排除，不会提交到仓库

# API 基础地址
VITE_API_BASE_URL=

# 微信公众号 AppID（H5 项目）
VITE_WECHAT_APP_ID=

# 错误监控 DSN（Sentry）
VITE_SENTRY_DSN=

# 环境标识（development / staging / production）
VITE_APP_ENV=development
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | v-html 渲染用户输入前必须经过 DOMPurify 净化 |
| 2 | MUST | Token 禁止存储在 localStorage/sessionStorage |
| 3 | MUST | 生产环境禁止 `Access-Control-Allow-Origin: *` |
| 4 | MUST | CI 中必须执行依赖漏洞扫描，Critical/High 阻断合并 |
| 5 | MUST | 代码中禁止硬编码密钥，.env.local 必须 gitignore |
| 6 | MUST | 敏感信息显示必须脱敏 |
| 7 | SHOULD | 后台管理项目配置 CSP 响应头 |
| 8 | SHOULD | 接入 secretlint 检测代码中的密钥泄露 |

检查方式：ESLint + CI 审计脚本 + 人工审查
阻断级别：MUST 条款阻断合并
