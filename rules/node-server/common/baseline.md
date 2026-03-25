# rules/node-server/common/baseline.md

## 技术基线

### MUST
1. 项目必须锁定 Node.js LTS 版本，在 `package.json` 中通过 `engines.node` 声明最低版本（如 `>=20.0.0`），CI 必须校验运行时版本一致。
2. 必须启用 TypeScript `strict` 模式（`tsconfig.json` 中 `"strict": true`），禁止关闭 `strictNullChecks`、`noImplicitAny` 等子选项。
3. 必须使用 `pnpm` 作为统一包管理器，`pnpm-lock.yaml` 必须纳入版本控制，禁止在 `.gitignore` 中忽略。
4. CI 流水线必须使用 `pnpm install --frozen-lockfile`，禁止自动修改 lockfile。
5. 必须配置 ESLint + Prettier，代码提交前必须通过 lint 和格式化检查。
6. ESLint 配置必须启用 `@typescript-eslint/recommended` 规则集，并启用 `no-unused-vars`、`no-explicit-any`、`no-floating-promises` 规则。
7. 必须配置 husky + lint-staged，在 `pre-commit` 阶段执行 lint 和格式化。

### SHOULD
1. 推荐使用 `nvm` 或 `volta` 管理 Node.js 版本，项目根目录放置 `.nvmrc` 或 `volta` 配置。
2. 推荐使用 `@trivago/prettier-plugin-sort-imports` 或 `eslint-plugin-import` 统一 import 排序。
3. 推荐启用 TypeScript `noUncheckedIndexedAccess` 选项，强制索引访问返回 `T | undefined`。

检查方式：CI lint + `tsc --noEmit` 编译检查
阻断级别：阻断合并

---

## 依赖安全审查（MUST）

1. CI 流水线必须集成 `npm audit` 或 `pnpm audit`，发现高危漏洞（CVSS ≥ 7.0）阻断合并。
2. 新增或升级第三方依赖前，必须确认其许可证兼容项目发布方式（商用项目禁止引入 GPL/AGPL 依赖）。
3. 禁止引入已归档（archived）、超过 12 个月无维护更新的依赖，确需使用须在 PR 中说明风险并附回收计划。
4. 禁止将 `devDependencies` 中的包引入生产代码（通过 `eslint-plugin-import/no-extraneous-dependencies` 检查）。
5. 依赖更新必须单独提交（与业务代码分离），便于审查和回滚。

### SHOULD
1. 定期（每月）执行全量依赖安全扫描，输出漏洞报告并限时修复。
2. 使用 `license-checker` 或 `license-report` 自动检测依赖许可证合规性，纳入 CI 检查。
3. 核心依赖（NestJS、Express、Prisma、数据库驱动等）锁定主版本，升级需经评审。

检查方式：`pnpm audit` + 许可证扫描 + CI 阻断
阻断级别：阻断合并（高危漏洞）/ 告警记录（中低危）

---

## 基础工程要求

### MUST
1. 启动入口（`main.ts` / `bootstrap.ts`）仅做依赖组装和生命周期管理，不承载业务逻辑。
2. 业务代码必须按分层组织（controller → service → repository），禁止横向耦合和循环依赖。
3. 必须配置路径别名（`paths` 或 `@` 前缀），禁止超过三层的相对路径导入（如 `../../../`）。
4. 必须在 `tsconfig.json` 中启用 `declaration` 和 `sourceMap`，便于调试和类型推导。
5. `package.json` 的 `scripts` 必须包含 `dev`、`build`、`start`、`lint`、`test` 命令。
6. 项目必须包含 `.editorconfig` 文件，统一缩进（2 空格）、换行符（LF）和尾行空行设置。
7. 组件初始化必须遵循 `common/component-initialization.md`，采用依赖注入与统一生命周期管理。
