# rules/frontend/frameworks/react-typescript.md

## 文档目标
1. 定义 React + TypeScript 项目的框架层专用约束。
2. 仅当应用端已锁定 React 时启用本文件；通用编码规范仍以 `common/baseline.md` 为准。
3. 本文件不重复 `common/` 已定义的内容，仅补充 React 特有约束。

---

## 1. 函数组件与模块组织

### MUST
1. 所有组件必须使用函数组件；禁止使用 Class 组件（第三方库封装的 ErrorBoundary 除外）。
2. 组件文件使用 PascalCase 命名（如 `UserProfile.tsx`），一个文件只导出一个组件。
3. 组件内代码顺序：类型定义 → Props 解构 → Hook 调用 → 事件处理函数 → 渲染辅助函数 → return JSX。
4. 单个组件文件超过 200 行时，必须将逻辑拆分到同目录自定义 Hook 中。
5. 禁止在组件函数体外定义组件（嵌套组件定义）；子组件必须拆分为独立文件或在同文件顶层定义。

### SHOULD
1. 导出组件优先使用具名导出（`export function UserProfile`），减少 `default export` 导致的重命名混乱。
2. 纯展示组件和容器组件保持物理分离（`components/` vs `containers/` 或 `views/`）。

检查方式：ESLint（`react/function-component-definition`）+ 人工审查
阻断级别：阻断合并

---

## 2. Props 与泛型组件类型约束

### MUST
1. Props 必须使用 `interface` 或 `type` 显式定义，禁止 `any` 或内联匿名类型。
2. Props 接口命名统一为 `<ComponentName>Props`（如 `UserProfileProps`）。
3. 子组件 Props 必须标注可选性（`?`）和默认值；默认值通过参数解构赋值，禁止在组件内部用 `?? / ||` 二次兜底。
4. 回调 Props 命名以 `on` 开头（如 `onSubmit`、`onChange`），类型必须显式声明参数。
5. `children` 类型优先使用 `React.ReactNode`；需要限制子元素类型时使用 `React.ReactElement`。
6. 泛型组件必须约束泛型边界（`<T extends BaseItem>`），禁止无约束的 `<T>`。

### SHOULD
1. 复杂 Props 类型提取到同目录 `types.ts`，组件文件内只引用。
2. 组件对外暴露的 ref 方法通过 `forwardRef` + `useImperativeHandle`，并导出 Handle 类型。

检查方式：TypeScript 编译 + 人工审查
阻断级别：阻断合并

---

## 3. Hooks 约束与副作用管理

### MUST
1. 自定义 Hook 以 `use` 开头命名（如 `useUserList.ts`），放在 `hooks/` 目录。
2. 自定义 Hook 必须显式声明输入参数类型和返回值类型。
3. `useEffect` 必须明确声明依赖数组，禁止省略依赖数组（空数组 `[]` 是合法的，表示仅挂载时执行）。
4. `useEffect` 中创建的副作用（事件监听、定时器、订阅、AbortController）必须在 cleanup 函数中释放。
5. `useEffect` 内禁止直接 async（`useEffect(async () => ...)`）；异步操作必须在内部定义 async 函数后调用。
6. 禁止在条件语句、循环、嵌套函数中调用 Hook（React Rules of Hooks）。
7. 自定义 Hook 禁止直接操作 DOM（`document.querySelector` 等），DOM 访问必须通过 `useRef`。

### SHOULD
1. Hook 职责单一，单个 Hook 不超过 150 行；超过应再拆分。
2. 跨页面共享的 Hook 放 `src/hooks/`；页面私有的放 `views/<page>/hooks/`。
3. 数据获取类 Hook 统一返回 `{ data, loading, error, refetch }` 结构。

检查方式：ESLint（`react-hooks/rules-of-hooks`、`react-hooks/exhaustive-deps`）
阻断级别：阻断合并

---

## 4. 状态管理边界

### MUST
1. 项目必须选定唯一的全局状态方案（Context / Redux Toolkit / Zustand，三选一），禁止混用。
2. 全局状态仅存放跨页面共享数据；页面私有状态留在页面组件或页面级 Hook 中，禁止提升到全局。
3. Store 按业务领域拆分（如 `useUserStore`、`useOrderStore`），禁止创建万能 Store。
4. Store 之间禁止循环依赖；如需跨 Store 数据，通过自定义 Hook 在页面层组合。
5. `useContext` 仅用于低频变化的数据（主题、国际化、权限）；高频变化数据禁止放 Context（导致全树重渲染）。
6. 异步 action 必须处理 loading 态与 error 态，调用方可感知结果。

### SHOULD
1. 优先考虑 `useState` + `useReducer` 解决局部状态，不必事事上全局 Store。
2. Store 文件统一放 `stores/` 目录，文件名与 Store 标识一致。
3. 复杂 Store 补单测覆盖关键 action 和 selector。

检查方式：人工审查
阻断级别：阻断合并

---

## 5. 路由与页面级边界

### MUST
1. 路由配置集中在 `router/` 目录，禁止在页面组件内动态注册路由。
2. 路由守卫（认证、权限）统一放 `router/guards/` 或 `router/middleware/`，禁止散落在页面中。
3. 页面组件（`views/`）只负责数据装配与子组件编排，业务逻辑提取到 Hook 或 service。
4. 路由参数通过 `useParams`、`useSearchParams` 获取并做类型断言，禁止直接操作 `window.location`。
5. 路由跳转统一使用 `useNavigate()`，禁止直接操作 `window.history`。

### SHOULD
1. 路由懒加载使用 `React.lazy(() => import(...))`，每个路由对应一个 chunk。
2. 路由元信息（如页面标题、权限标识）通过路由配置对象的 `meta` / `handle` 字段统一管理。

检查方式：ESLint + 人工审查
阻断级别：阻断合并

---

## 6. 组件渲染模式约束

### MUST
1. 组件必须保持渲染纯净性：相同 props + 相同 state 必须产出相同 JSX，禁止在渲染过程中修改外部变量或发起请求。
2. 条件渲染优先使用早返回（`if (!data) return <Loading />`），避免深层三元嵌套。
3. 列表渲染的 `key` 必须使用唯一且稳定的业务标识，禁止使用数组 `index`（静态列表除外）。
4. `React.Fragment`（`<>...</>`）仅用于无需额外 DOM 节点的场景；需要 `key` 时必须使用 `<Fragment key={...}>`。

### SHOULD
1. 超过 3 层的条件渲染拆分为独立子组件，保持 JSX 可读性。
2. render prop 模式仅在需要跨组件共享渲染逻辑时使用；优先考虑自定义 Hook 替代。

检查方式：ESLint + 人工审查
阻断级别：阻断合并

---

## 7. 表单架构：Schema-Driven Forms（声明描述与渲染分离）

### 原则
1. 表单开发必须遵循"声明描述 + 通用渲染"的分层架构，将"表单有什么"与"表单怎么画"解耦。
2. 本章约束适用于所有包含表单的场景（CRUD、配置页、向导流程、审批单等）。

### 分层定义

| 层 | 职责 | 产出物 |
|----|------|--------|
| **Schema 层（描述）** | 声明字段列表、类型、校验规则、联动条件、布局提示 | 纯 TypeScript 对象/数组，不含任何 React 组件引用 |
| **Renderer 层（渲染）** | 消费 Schema 生成 UI、绑定表单状态、执行校验 | 通用 `<FormRenderer>` 组件或项目内等效实现 |
| **业务层（消费）** | 定义具体业务的 Schema、提交逻辑、页面编排 | 页面/业务组件 |

### MUST
1. 超过 3 个字段的表单禁止在 JSX 中逐个手写字段标签，必须通过 Schema 驱动渲染。
2. Schema 必须是纯数据结构（对象/数组/JSON），禁止在 Schema 中内联 React 组件或 JSX。
3. Schema 中的字段联动（显示/隐藏、禁用、选项过滤）必须通过声明式条件表达（如 `visible: (model) => model.type === 'vip'`），禁止在 JSX 中散写联动逻辑。
4. 校验规则必须声明在 Schema 中随字段定义，禁止在提交回调里临时拼装校验。
5. Renderer 组件必须是通用的，不得包含特定业务逻辑；业务差异通过 Schema 配置或插槽/render prop 扩展点解决。
6. Schema 对象必须有 TypeScript 类型定义（`FormSchema`、`FormFieldDef` 等），字段类型、校验规则类型必须受类型约束。
7. 动态表单场景（后端下发配置）必须复用同一套 Renderer，禁止为动态表单单独写一套渲染逻辑。

### SHOULD
1. Schema 支持布局提示（如 `span`、`group`、`section`），由 Renderer 统一消费，业务层不关心具体栅格实现。
2. 复杂自定义字段通过 Renderer 的字段类型注册机制扩展（如 `registerFieldType('richtext', RichTextField)`），而非在 Schema 中嵌入组件。
3. 高频使用的表单 Schema（如通用搜索栏、分页参数）抽象为共享 Schema 片段，跨页面复用。
4. 表单状态管理推荐使用 `react-hook-form` 或等效方案，避免自行维护大量 `useState`。

### MAY
1. 简单场景（3 个及以下字段的搜索栏、登录框）允许直接 JSX 编写，不强制 Schema 驱动。
2. 项目可选用成熟方案（ProForm / react-jsonschema-form / Formily React 等），也可自建轻量 Renderer，但必须满足上述 MUST 约束。

检查方式：人工审查 + 代码评审
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 8. 异步数据与错误边界

### MUST
1. 数据获取逻辑封装到自定义 Hook 或数据层（如 `react-query` / `swr`），页面组件禁止直接写 `fetch/axios` 调用。
2. 所有异步渲染路径必须处理三态：加载中（Loading）、成功（Data）、失败（Error）。
3. 页面级必须包裹 `ErrorBoundary`，捕获子树渲染崩溃并展示降级 UI，禁止白屏。
4. `ErrorBoundary` 必须提供重试入口（如"重新加载"按钮），不得仅展示错误信息。
5. 网络请求必须支持取消（`AbortController`），路由切换时自动取消进行中的请求。

### SHOULD
1. 数据获取 Hook 统一返回 `{ data, isLoading, error, refetch }` 接口。
2. 乐观更新（Optimistic Update）场景必须实现回滚逻辑。
3. 考虑使用 `Suspense` + `ErrorBoundary` 组合简化加载/错误态处理（React 18+）。

检查方式：人工审查 + 代码评审
阻断级别：阻断合并

---

## 9. React 性能约束

### MUST
1. 大列表（100+ 项）必须使用虚拟滚动（如 `react-window` / `react-virtuoso`）或分页，禁止全量渲染。
2. 高频触发的事件处理（`scroll`、`resize`、`input`）必须做防抖或节流。
3. 不参与渲染的大对象存储在 `useRef` 中，避免触发不必要的重渲染。
4. `useCallback` 和 `useMemo` 仅用于确有性能问题的场景（传递给 `memo` 子组件的回调、高开销计算），禁止无脑包裹所有函数和值。
5. `React.memo` 仅用于被频繁重渲染且 props 稳定的纯展示组件，禁止给所有组件加 `memo`。

### SHOULD
1. 使用 React DevTools Profiler 定期检查不必要的组件重渲染。
2. 非响应式常量（配置项、枚举映射）提取到模块顶层或单独 `.ts` 文件，不放在组件函数体内。
3. 避免在 JSX 中创建内联对象或箭头函数作为 props（如 `style={{ ... }}`、`onClick={() => ...}`），高频渲染组件中必须提取。

检查方式：人工审查 + 性能测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 10. React 测试规范

### MUST
1. 组件测试使用 `@testing-library/react` + `vitest`（或 `jest`）。
2. 公共组件（`components/` 下的 Base/Business 组件）必须覆盖：渲染、props 传入、用户交互、条件渲染分支。
3. 自定义 Hook 测试使用 `@testing-library/react` 的 `renderHook`。
4. 测试中禁止直接操作组件内部状态，必须通过 props 和用户交互（`fireEvent` / `userEvent`）驱动。
5. 查询 DOM 优先使用无障碍查询（`getByRole`、`getByLabelText`），避免 `getByTestId`。

### SHOULD
1. 页面组件用集成测试覆盖核心路径，不要求逐行单测。
2. 快照测试仅用于样式敏感组件，每次更新必须人工审查 diff。
3. Mock 优先使用 `vi.mock` / `jest.mock` 模块级 mock，减少测试耦合。
4. 异步测试使用 `waitFor` / `findBy*`，禁止硬编码 `setTimeout` 等待。

检查方式：CI 阻断（覆盖率门禁）+ 人工审查
阻断级别：阻断合并

---

## 11. ESLint 规则级别定义

### MUST
1. 启用 `eslint-plugin-react` 的 `recommended` 预设 + `eslint-plugin-react-hooks`。
2. 以下规则必须为 `error`：
   - `react-hooks/rules-of-hooks`
   - `react-hooks/exhaustive-deps`
   - `react/jsx-key`
   - `react/no-array-index-key`
   - `react/no-direct-mutation-state`
   - `react/jsx-no-target-blank`
   - `react/no-unstable-nested-components`
   - `react/function-component-definition` (named-function)
   - `@typescript-eslint/no-explicit-any`

### SHOULD
1. 以下规则建议为 `warn`：
   - `react/jsx-no-useless-fragment`
   - `react/self-closing-comp`
   - `react/jsx-curly-brace-presence`
   - `react/hook-use-state` (解构命名约束)
   - `react/no-unused-prop-types`

检查方式：CI ESLint 阻断
阻断级别：阻断合并（error 级）/ 告警记录（warn 级）
