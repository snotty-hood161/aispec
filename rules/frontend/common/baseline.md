# rules/frontend/common/baseline.md

## 文档目标
1. 定义三端共用的编码规范，不绑定具体业务端和 UI 框架。
2. 结构相关规则请参考 `common/project-structure.md` 与 `project-structure/*.md`。
3. 命名、工具链、流程与规范化改造分别参考 `common/naming.md`、`common/tooling.md`、`common/workflow.md`、`common/normalization.md`。

## TypeScript 基线
1. `MUST`：开启 `strict`。
2. `MUST`：禁止无边界 `any`；确需使用时必须写注释说明原因。
3. `MUST`：导出的函数、类、hook/composable 必须显式声明输入输出类型。
4. `SHOULD`：DTO 与视图模型分离，避免在组件中直接操作原始接口数据。

## 命名与文件规范
1. `MUST`：变量与函数使用 `camelCase`，类型与组件使用 `PascalCase`。
2. `MUST`：常量使用 `UPPER_SNAKE_CASE`。
3. `MUST`：同一目录下禁止出现语义重复文件名（如 `util.ts`、`utils.ts` 同时存在）。
4. `SHOULD`：单文件职责单一，超过 300 行应拆分。

## API 与数据约束
1. `MUST`：统一通过 `services` 层访问接口，组件内禁止直接写请求实现。
2. `MUST`：统一错误结构和错误码映射，禁止在页面到处写魔法字符串。
3. `MUST`：所有请求必须支持超时和异常兜底。
4. `SHOULD`：关键接口加请求/响应日志埋点（脱敏后）。

## 状态与副作用约束
1. `MUST`：全局状态只放跨页面共享数据，页面私有状态禁止提升到全局。
2. `MUST`：副作用逻辑必须可清理（事件、定时器、订阅）。
3. `SHOULD`：异步流程统一封装，避免页面层散落并发控制代码。

## 注释与调试代码规范

### 注释要求（MUST）
1. 所有函数、组件、Hook/Composable、复杂逻辑块必须添加中文注释，说明"做什么"和"为什么"。
2. 注释语言统一使用中文；与外部开源库交互的类型声明文件（`.d.ts`）允许使用英文。
3. 文件头部必须包含模块用途说明注释（一句话概括文件职责）。
4. 复杂业务逻辑、非直觉的条件判断、临时方案（workaround）必须注释说明背景和原因。
5. 禁止无意义注释（如 `// 设置名称` 后面跟 `setName()`），注释必须提供代码本身未表达的信息。

### 调试代码清理（MUST）
1. 生产构建必须移除所有 `console.log`、`console.debug`、`console.info`、`console.warn` 调用。仅允许保留 `console.error` 用于运行时异常上报。
2. 生产构建必须移除所有代码注释，确保产物体积最小化。
3. 上述清理必须通过构建工具自动完成，禁止依赖人工手动删除：
   - **Vite 项目**：通过 `build.terserOptions`（Terser）或 `esbuild.drop` 配置移除 console 和注释。
   - **Webpack 项目**：通过 `TerserPlugin` 的 `terserOptions.compress.drop_console` 和 `terserOptions.format.comments: false` 配置。
   - **uni-app 项目**：在对应构建配置中启用等效选项。
4. 开发环境允许使用 `console.log` 调试，但禁止提交到主分支；CI 阶段通过 ESLint 规则 `no-console`（`error` 级别，`allow: ['error']`）阻断。

### SHOULD
1. TODO/FIXME 注释必须附带责任人和预计回收时间（如 `// TODO(zhangsan): 2026-04 迁移到新接口`）。
2. 注释随代码同步更新；代码逻辑变更后，对应注释必须同步修改，禁止过期注释残留。

检查方式：ESLint（`no-console`）+ 构建配置审查 + 人工审查
阻断级别：阻断合并

## 质量门禁
1. `MUST`：提交前通过 `lint + typecheck + test`。
2. `MUST`：PR 必须包含变更说明、影响范围、回滚方案。
3. `SHOULD`：关键链路补 E2E；核心组件补单测。

## 安全与合规
1. `MUST`：禁止在前端硬编码密钥、token、私有地址。
2. `MUST`：日志和埋点中禁止输出手机号、证件号等明文敏感信息。
3. `SHOULD`：输入输出统一做 XSS 与注入类风险过滤。

## 配套模板
1. ESLint / Prettier 配置基线 → `rules/templates/frontend/eslint-prettier-baseline.md`
2. 规范例外申请模板 → `rules/templates/exception-request-template.md`
3. PR 评审清单 → `rules/templates/frontend/pr-review-checklist.md`
