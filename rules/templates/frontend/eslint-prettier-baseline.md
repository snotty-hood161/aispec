# ESLint / Prettier 配置基线

## 文档目标
1. 定义所有前端项目的 ESLint 和 Prettier 统一配置标准。
2. 具体框架层规则（Vue/React）参见 `frameworks/*.md` 的 ESLint 章节。

---

## Prettier 基线配置

所有前端项目必须使用统一的 Prettier 配置：

```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "htmlWhitespaceSensitivity": "css"
}
```

### MUST
1. 配置文件统一使用 `.prettierrc`（JSON 格式），放在项目根目录。
2. 团队内所有项目使用相同的 Prettier 配置，禁止项目级自定义覆盖（除非经评审批准）。
3. 编辑器必须配置保存时自动格式化（Format on Save）。

---

## ESLint 基线配置

### 通用规则（所有项目适用）

以下规则必须为 `error` 级别：

**TypeScript**
- `@typescript-eslint/no-explicit-any` — 禁止无边界 any
- `@typescript-eslint/no-unused-vars` — 禁止未使用变量（允许 `_` 前缀）
- `@typescript-eslint/explicit-function-return-type` — 导出函数必须显式返回类型（仅 `allowExpressions: true`）
- `@typescript-eslint/no-non-null-assertion` — 禁止非空断言（`!`）

**通用质量**
- `no-console` — 禁止 console（`allow: ['error']`）
- `no-debugger` — 禁止 debugger
- `no-alert` — 禁止 alert/confirm/prompt
- `eqeqeq` — 强制使用 `===`
- `no-var` — 禁止 var
- `prefer-const` — 优先使用 const

**导入管理**
- `import/no-duplicates` — 禁止重复导入
- `import/no-cycle` — 禁止循环依赖（建议 `maxDepth: 3`）

### Vue 项目追加规则
参见 `frameworks/vue3-typescript.md` 第 11 章 ESLint 规则级别定义。

### React 项目追加规则
参见 `frameworks/react-typescript.md` 第 11 章 ESLint 规则级别定义。

---

## 配置文件模板

### Vue 项目（`eslint.config.js`）

```js
import eslint from '@eslint/js'
import tseslint from 'typescript-eslint'
import pluginVue from 'eslint-plugin-vue'
import importPlugin from 'eslint-plugin-import'

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  {
    rules: {
      // 通用基线
      'no-console': ['error', { allow: ['error'] }],
      'no-debugger': 'error',
      'no-alert': 'error',
      'eqeqeq': 'error',
      'no-var': 'error',
      'prefer-const': 'error',

      // TypeScript
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],

      // Vue（参见 frameworks/vue3-typescript.md）
      'vue/define-props-declaration': ['error', 'type-based'],
      'vue/define-emits-declaration': ['error', 'type-based'],
      'vue/block-order': ['error', { order: ['script', 'template', 'style'] }],
      'vue/no-mutating-props': 'error',
      'vue/no-side-effects-in-computed-properties': 'error',
      'vue/require-v-for-key': 'error',
      'vue/no-use-v-if-with-v-for': 'error',

      // 导入
      'import/no-duplicates': 'error',
    },
  },
)
```

### React 项目（`eslint.config.js`）

```js
import eslint from '@eslint/js'
import tseslint from 'typescript-eslint'
import pluginReact from 'eslint-plugin-react'
import pluginReactHooks from 'eslint-plugin-react-hooks'

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: {
      react: pluginReact,
      'react-hooks': pluginReactHooks,
    },
    rules: {
      // 通用基线
      'no-console': ['error', { allow: ['error'] }],
      'no-debugger': 'error',
      'no-alert': 'error',
      'eqeqeq': 'error',
      'no-var': 'error',
      'prefer-const': 'error',

      // TypeScript
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],

      // React（参见 frameworks/react-typescript.md）
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'react/jsx-key': 'error',
      'react/no-array-index-key': 'error',
      'react/no-unstable-nested-components': 'error',

      // 导入
      'import/no-duplicates': 'error',
    },
  },
)
```

---

## 注意事项
1. 以上为基线配置，项目可在此基础上追加规则，但禁止降低基线规则级别（如将 `error` 改为 `warn` 或 `off`）。
2. ESLint 配置变更必须单独提交 PR，附变更说明。
3. 配置升级（ESLint / 插件版本）必须验证现有代码无新增违规后再合并。
