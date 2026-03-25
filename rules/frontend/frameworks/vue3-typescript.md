# rules/frontend/frameworks/vue3-typescript.md

## 文档目标
1. 定义 Vue3 + TypeScript 项目的框架层专用约束。
2. 仅当应用端已锁定 Vue3 时启用本文件；通用编码规范仍以 `common/baseline.md` 为准。
3. 本文件不重复 `common/` 已定义的内容，仅补充 Vue3 特有约束。

---

## 1. SFC 组织与 `<script setup>`

### MUST
1. 默认使用 `<script setup lang="ts">`；仅在需要 `inheritAttrs: false` 或自定义 `render` 时允许普通 `<script lang="ts">`。
2. `<script setup>` 内代码顺序：类型导入 → 外部导入 → props/emits/expose 定义 → composable 调用 → 响应式状态 → 计算属性 → watcher → 生命周期钩子 → 方法。
3. 单个 SFC 的 `<script setup>` 超过 200 行时，必须将逻辑拆分到同目录 composable 中。
4. `<template>` 中禁止包含复杂表达式（超过一次链式调用或三元嵌套），必须提取为计算属性或方法。

### SHOULD
1. 一个 `.vue` 文件只包含一个 `<script setup>` 和一个 `<template>`，避免混用多个 `<script>` 块。

检查方式：ESLint（`vue/block-order`、`vue/no-complex-expressions`）+ 人工审查
阻断级别：阻断合并

---

## 2. Props / Emits / Expose 类型约束

### MUST
1. `defineProps` 必须使用纯类型声明（`defineProps<{ ... }>()`），禁止运行时声明。
2. `defineEmits` 必须使用纯类型声明（`defineEmits<{ ... }>()`），每个事件显式声明参数类型。
3. Props 默认值通过 `withDefaults` 设置，禁止在组件内部用 `?? / ||` 二次兜底。
4. `defineExpose` 仅用于必须暴露给父组件的方法；暴露的方法必须定义 interface 并导出。
5. 禁止将整个 reactive 对象或 store 通过 `defineExpose` 暴露。

### SHOULD
1. 复杂 Props 类型提取到同目录 `types.ts`，SFC 内只引用。
2. 事件命名使用 `camelCase`（如 `update:modelValue`），与 Vue3 推荐一致。

检查方式：ESLint（`vue/define-props-declaration`、`vue/define-emits-declaration`）
阻断级别：阻断合并

---

## 3. 组合式 API 与 Composable 约束

### MUST
1. Composable 文件以 `use` 开头命名（如 `useUserList.ts`），放在 `composables/` 目录。
2. Composable 必须显式声明输入参数类型和返回值类型。
3. Composable 内创建的副作用（`watch`、`watchEffect`、事件监听、定时器）必须在 `onUnmounted` 或返回的清理函数中释放。
4. `watch` 必须显式声明依赖源，禁止依赖 `watchEffect` 的自动追踪来替代 `watch` 的精确控制。
5. `watchEffect` 仅用于简单的同步派生或一次性副作用；含异步操作或条件分支的副作用必须用 `watch`。
6. Composable 禁止直接操作 DOM（`document.querySelector` 等），DOM 访问必须通过 `ref` 模板引用。

### SHOULD
1. Composable 职责单一，单个 composable 不超过 150 行；超过应再拆分。
2. 跨页面共享的 composable 放 `src/composables/`；页面私有的放 `views/<page>/composables/`。

检查方式：ESLint（`vue/no-watch-after-await`）+ 人工审查
阻断级别：阻断合并

---

## 4. 响应式使用约束

### MUST
1. 优先使用 `ref` 作为基本响应式容器；`reactive` 仅用于不会被整体替换的对象结构。
2. 禁止对 `reactive` 对象做整体赋值（如 `state = newState`），必须逐字段更新或使用 `Object.assign`。
3. 模板引用必须使用 `useTemplateRef` 或 `ref<InstanceType<typeof Component> | null>(null)` 并注明类型。
4. `shallowRef` / `shallowReactive` 仅用于性能敏感的大对象场景，必须注释说明原因。
5. `toRefs` / `toRef` 的解构必须在 setup 顶层执行，禁止在异步回调中解构 reactive 对象。

### SHOULD
1. 避免深层嵌套响应式对象（超过 3 层），必要时通过扁平化或 `computed` 派生简化结构。

检查方式：ESLint + 人工审查
阻断级别：阻断合并

---

## 5. 路由与页面级边界

### MUST
1. 路由配置集中在 `router/` 目录，禁止在页面组件内动态注册路由。
2. 路由守卫中禁止包含业务逻辑；鉴权检查统一放 `router/guards/` 并按职责拆分。
3. 页面组件（`views/`）只负责数据装配与子组件编排，业务逻辑提取到 composable 或 service。
4. 路由参数通过 `useRoute` 获取并做类型断言，禁止使用 `$route` 选项式访问。
5. 路由跳转统一使用 `useRouter().push/replace`，禁止直接操作 `window.location`。

### SHOULD
1. 路由懒加载使用 `() => import()`，每个路由对应一个 chunk。
2. 路由元信息（`meta`）类型通过 `declare module 'vue-router'` 扩展 `RouteMeta` 接口。

检查方式：ESLint + 人工审查
阻断级别：阻断合并

---

## 6. 状态管理（Pinia）边界

### MUST
1. 每个 Store 使用 `defineStore` + Setup Store 语法（组合式），与 `<script setup>` 风格一致。
2. Store 粒度按业务领域划分（如 `useUserStore`、`useOrderStore`），禁止创建 `useGlobalStore` 万能 Store。
3. Store 之间禁止循环依赖；如需跨 Store 数据，通过 composable 或在页面层做组合。
4. Store 中仅存放跨页面共享数据；页面私有状态留在页面 composable，禁止提升到 Store。
5. 持久化（`pinia-plugin-persistedstate`）仅用于用户偏好、缓存型数据；敏感数据（token 等）禁止持久化到 localStorage。
6. Store 的 action 中包含异步操作时，必须处理加载态与错误态。

### SHOULD
1. Store 文件统一放 `stores/` 目录，文件名与 Store ID 一致。
2. 复杂 Store 单测覆盖关键 action 和 getter。

检查方式：人工审查
阻断级别：阻断合并

---

## 7. 动态组件与异步加载

### MUST
1. `<component :is>` 的组件映射必须通过显式 Map 或 `markRaw` 标注，禁止直接传响应式组件对象。
2. `<KeepAlive>` 必须配合 `include/exclude/max` 限制缓存范围，禁止无边界缓存。
3. 异步组件使用 `defineAsyncComponent` 并提供 `loadingComponent` 和 `errorComponent`。
4. 异步组件超时必须设置 `timeout`，超时后展示错误态。

### SHOULD
1. `<Suspense>` 仅在实验特性稳定后用于生产；当前阶段建议使用 `defineAsyncComponent` 替代。

检查方式：人工审查
阻断级别：阻断合并

---

## 8. 表单架构：Schema-Driven Forms（声明描述与渲染分离）

### 原则
1. 表单开发必须遵循"声明描述 + 通用渲染"的分层架构，将"表单有什么"与"表单怎么画"解耦。
2. 本章约束适用于所有包含表单的场景（CRUD、配置页、向导流程、审批单等）。

### 分层定义

| 层 | 职责 | 产出物 |
|----|------|--------|
| **Schema 层（描述）** | 声明字段列表、类型、校验规则、联动条件、布局提示 | 纯 TypeScript 对象/数组，不含任何 Vue 组件引用 |
| **Renderer 层（渲染）** | 消费 Schema 生成 UI、绑定表单状态、执行校验 | 通用 `<FormRenderer>` 组件或项目内等效实现 |
| **业务层（消费）** | 定义具体业务的 Schema、提交逻辑、页面编排 | 页面/业务组件 |

### MUST
1. 超过 3 个字段的表单禁止在 `<template>` 中逐个手写字段标签，必须通过 Schema 驱动渲染。
2. Schema 必须是纯数据结构（对象/数组/JSON），禁止在 Schema 中内联 Vue 组件、JSX 或渲染函数。
3. Schema 中的字段联动（显示/隐藏、禁用、选项过滤）必须通过声明式条件表达（如 `visible: (model) => model.type === 'vip'`），禁止在模板中用 `v-if` 散写联动逻辑。
4. 校验规则必须声明在 Schema 中随字段定义，禁止在提交回调里临时拼装校验。
5. Renderer 组件必须是通用的，不得包含特定业务逻辑；业务差异通过 Schema 配置或插槽扩展点解决。
6. Schema 对象必须有 TypeScript 类型定义（`FormSchema`、`FormFieldDef` 等），字段类型、校验规则类型必须受类型约束。
7. 动态表单场景（后端下发配置）必须复用同一套 Renderer，禁止为动态表单单独写一套渲染逻辑。

### SHOULD
1. Schema 支持布局提示（如 `span`、`group`、`section`），由 Renderer 统一消费，业务层不关心具体栅格实现。
2. 复杂自定义字段通过 Renderer 的字段类型注册机制扩展（如 `registerFieldType('richtext', TiptapField)`），而非在 Schema 中嵌入组件。
3. 高频使用的表单 Schema（如通用搜索栏、分页参数）抽象为共享 Schema 片段，跨页面复用。
4. Schema 变更（新增字段、调整校验）应能通过纯数据修改完成，不需要改动模板代码。

### MAY
1. 简单场景（3 个及以下字段的搜索栏、登录框）允许直接模板编写，不强制 Schema 驱动。
2. 项目可选用成熟方案（FormKit、Formily 等），也可自建轻量 Renderer，但必须满足上述 MUST 约束。

检查方式：人工审查 + 代码评审
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 9. Vue 性能约束

### MUST
1. `v-for` 必须使用唯一且稳定的 `key`，禁止使用 `index` 作为 `key`（静态列表除外）。
2. 大列表（100+ 项）必须使用虚拟滚动或分页，禁止全量渲染。
3. 不参与模板渲染的大对象，使用 `shallowRef` 或 `markRaw` 避免深层响应式追踪。
4. 禁止在 `computed` 中产生副作用（修改外部状态、发起请求）。
5. 高频触发的事件处理（`scroll`、`resize`、`input`）必须做防抖或节流。

### SHOULD
1. 使用 Vue DevTools 的 Performance 面板定期检查不必要的组件重渲染。
2. 非响应式常量（配置项、枚举映射）提取到 `.ts` 文件，不放在 `<script setup>` 内。

检查方式：人工审查 + 性能测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 10. Vue 测试规范

### MUST
1. 组件测试使用 `@vue/test-utils` + `vitest`。
2. 公共组件（`components/` 下的 Base/Business 组件）必须覆盖：渲染、props 传入、事件触发、插槽。
3. Composable 测试直接在 `vitest` 中调用，使用 `createApp` 或 `withSetup` 辅助提供组件上下文。
4. 测试中禁止直接操作组件内部状态（如 `wrapper.vm.xxx = ...`），必须通过 props 和用户交互驱动。

### SHOULD
1. 页面组件用集成测试覆盖核心路径，不要求逐行单测。
2. 快照测试仅用于样式敏感组件，每次更新必须人工审查 diff。
3. Mock 优先使用 `vi.mock` 模块级 mock，减少测试耦合。

检查方式：CI 阻断（覆盖率门禁） + 人工审查
阻断级别：阻断合并

---

## 11. ESLint 规则级别定义

### MUST
1. 启用 `eslint-plugin-vue` 的 `vue3-recommended` 预设。
2. 以下规则必须为 `error`：
   - `vue/no-unused-vars`
   - `vue/no-mutating-props`
   - `vue/no-side-effects-in-computed-properties`
   - `vue/return-in-computed-property`
   - `vue/no-async-in-computed-properties`
   - `vue/require-v-for-key`
   - `vue/no-use-v-if-with-v-for`
   - `vue/define-props-declaration` (type-based)
   - `vue/define-emits-declaration` (type-based)
   - `vue/block-order` (顺序：`script` → `template` → `style`)

### SHOULD
1. 以下规则建议为 `warn`：
   - `vue/component-name-in-template-casing` (PascalCase)
   - `vue/prefer-define-options`
   - `vue/no-required-prop-with-default`
   - `vue/padding-line-between-tags`

检查方式：CI ESLint 阻断
阻断级别：阻断合并（error 级）/ 告警记录（warn 级）
