# rules/react-native/common/baseline.md

## 文档目标
1. 定义 React Native 项目的技术基线，覆盖运行时、语言、工具链、依赖管理。

---

## React Native 版本（MUST）

1. React Native 版本以项目根目录 `package.json` 中 `react-native` 字段声明为准，推荐使用最新 stable 版本。
2. 项目必须指定精确的 React Native 版本号（如 `"react-native": "0.76.3"`），禁止使用 `^` 或 `~` 前缀。
3. React Native 版本升级必须单独提交，附变更日志与兼容性验证结果（含 Android / iOS 双端验证）。
4. 禁止使用 nightly / canary 版本用于生产构建。
5. 升级 React Native 版本时必须同步升级 `@react-native-community/*` 系列依赖至兼容版本。

---

## TypeScript 配置（MUST）

1. 所有项目必须使用 TypeScript，禁止纯 JavaScript 编写业务代码。
2. `tsconfig.json` 必须启用严格模式：

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "jsx": "react-jsx"
  }
}
```

3. 禁止在 `tsconfig.json` 中设置 `"strict": false` 或单独关闭 `noImplicitAny` / `strictNullChecks`。
4. 禁止使用 `@ts-ignore`，确需时使用 `@ts-expect-error` 并附注释说明原因。
5. 所有 `.js` / `.jsx` 文件必须在迁移计划内逐步转换为 `.ts` / `.tsx`。

---

## 引擎与运行时（MUST）

1. Android 端必须使用 **Hermes** 引擎（React Native 0.70+ 默认启用），禁止回退到 JSC。
2. iOS 端同样推荐使用 Hermes 引擎以保持双端一致性。
3. 启用 Hermes 后必须验证所有第三方库与 Hermes 的兼容性。
4. 禁止在生产构建中开启 Remote JS Debugging（影响性能且使用 Chrome V8 而非 Hermes）。

---

## 静态分析与格式化（MUST）

1. 项目根目录必须包含 `.eslintrc.js`（或 `eslint.config.mjs`），基于 `@react-native/eslint-config` 扩展：

```js
module.exports = {
  root: true,
  extends: [
    '@react-native',
    'plugin:@typescript-eslint/recommended-type-checked',
  ],
  parserOptions: {
    project: './tsconfig.json',
  },
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-floating-promises': 'error',
    'no-console': 'error',
  },
};
```

2. 必须集成 **Prettier**，统一代码格式化规则（`printWidth: 100`、`singleQuote: true`、`trailingComma: 'all'`）。
3. CI 流水线必须执行 `eslint --max-warnings 0`，任何 warning 级别以上问题阻断合并。
4. 推荐配置 `lint-staged` + `husky`，提交前自动执行 lint 与格式化。
5. 禁止提交含 `eslint-disable` 注释的代码（确需时必须附原因并经评审）。

---

## Metro 打包器（MUST）

1. 项目必须使用 **Metro** 作为 JavaScript 打包器（React Native 默认），禁止替换为 Webpack / Vite 等。
2. `metro.config.js` 必须纳入版本控制。
3. 自定义 Metro 配置（如路径别名、资源转换）必须经团队评审。
4. 推荐启用 Metro 的 `inline requires` 优化以改善启动性能。

---

## 依赖管理（MUST）

1. 推荐使用 **yarn** (v3+) 或 **pnpm** 作为包管理器，团队内统一使用一种。
2. `yarn.lock` / `pnpm-lock.yaml` 必须纳入版本控制，确保构建可重复。
3. 第三方依赖引入必须经过团队评审，评估：
   - npm 周下载量、GitHub Stars、最后更新时间。
   - 是否提供 TypeScript 类型定义。
   - 是否支持 New Architecture（Fabric / TurboModules）。
   - 许可证兼容性（MIT / BSD / Apache 2.0 优先）。
4. 禁止使用已废弃（deprecated）或长期未维护（> 12 个月无更新）的包。
5. 必须定期运行 `npx npm-check-updates` 或 `yarn upgrade-interactive` 检查过期依赖。
6. 原生依赖（含 native code 的包）安装后必须在 Android / iOS 双端验证编译通过。
7. Monorepo 项目推荐使用 **Turborepo** / **Nx** 管理多 Package 构建与依赖。

---

## 项目创建标准（MUST）

1. 新项目必须通过 `npx react-native init` 或 `npx create-expo-app` 创建，禁止手动拼凑项目结构。
2. 项目名使用 `PascalCase`（如 `MyAwesomeApp`），package name 使用反向域名风格（如 `com.company.myapp`）。
3. 创建后必须立即初始化 TypeScript 配置与 ESLint 配置。
4. `.gitignore` 必须包含 `node_modules/`、`android/app/build/`、`ios/Pods/`、`.expo/`。
