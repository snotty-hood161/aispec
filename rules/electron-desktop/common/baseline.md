# rules/electron-desktop/common/baseline.md

## 技术基线

1. Electron 版本：新项目必须使用 **Electron v30+**，禁止新建 Electron v28 以下项目。
2. Node.js 版本以 Electron 内置版本为准，外部工具链推荐 LTS 最新版。
3. 渲染进程前端框架推荐 React 或 Vue，必须使用 TypeScript。
4. 包管理：推荐 pnpm（首选）或 npm，禁止混用包管理器。
5. 提交前必须确保主进程编译和渲染进程构建均无错误。

## TypeScript 工具链要求（MUST）

1. `tsconfig.json` 必须启用 `"strict": true`，禁止 `any` 类型。
2. 主进程与 preload 脚本必须使用 TypeScript 编写，编译输出到独立目录。
3. 必须启用 ESLint + Prettier，CI 流水线中执行 `eslint --max-warnings 0` 和格式化检查。
4. 必须使用 `npm audit` 或 `pnpm audit` 检测已知漏洞依赖，高危漏洞（CVSS >= 7.0）阻断合并。

## 构建工具要求（MUST）

1. 主进程与 preload 脚本推荐使用 `electron-vite` 或 `tsup` 构建，禁止直接发布 TypeScript 源码。
2. 渲染进程使用 Vite 或 Webpack 构建，推荐 Vite。
3. 必须配置 `electron-builder` 或 `electron-forge` 作为打包工具。
4. `package.json` 中 `main` 字段必须指向编译后的主进程入口。
