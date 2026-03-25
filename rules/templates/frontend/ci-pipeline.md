# CI 流水线模板

## 文档目标
1. 提供 GitHub Actions 完整 CI 流水线配置，串联所有检查脚本，保障交付质量门禁。
2. 工具链规则参见 `common/tooling.md`，交付流程参见 `common/workflow.md`。

## 使用方式
- **谁用**：项目初始化者、DevOps。
- **何时用**：新建项目配置 CI 时；或老项目补齐 CI 检查时。
- **怎么用**：根据应用类型选择对应模板，复制到 `.github/workflows/ci.yml`，按注释调整配置。

---

## 一、通用基础流水线（所有前端项目）

```yaml
# .github/workflows/ci.yml
# 前端 CI 流水线 — 所有前端项目的基础检查
# 参考规则：common/tooling.md（脚本契约）、common/workflow.md（门禁标准）

name: CI

on:
  pull_request:
    branches: [main, master]
  push:
    branches: [main, master]

# 同一 PR 新推送时取消旧的运行
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ============================================================
  # 阶段一：代码质量检查（并行执行）
  # ============================================================
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: ESLint + Prettier 检查
        run: pnpm lint

  typecheck:
    name: TypeCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: TypeScript 类型检查
        run: pnpm typecheck

  # ============================================================
  # 阶段二：测试（依赖代码质量检查通过）
  # ============================================================
  test:
    name: Test
    runs-on: ubuntu-latest
    needs: [lint, typecheck]
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: 单元测试 + 覆盖率
        run: pnpm test:coverage

      - name: 上传覆盖率报告
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 7

  # ============================================================
  # 阶段三：构建验证（依赖测试通过）
  # ============================================================
  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [test]
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: 构建
        run: pnpm build

      - name: 上传构建产物
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
          retention-days: 3
```

---

## 二、后台管理项目（admin-console）扩展

在基础流水线上追加以下 job：

```yaml
  # ============================================================
  # 扩展检查（与 lint/typecheck 并行）
  # ============================================================
  check-branch:
    name: Branch Name
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      - name: 分支名校验
        run: bash scripts/check-branch-name.sh

  check-dependencies:
    name: Dependencies
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: 依赖准入检查
        run: npx ts-node scripts/check-dependencies.ts

      - name: 依赖漏洞扫描
        run: bash scripts/check-audit.sh

  check-page-size:
    name: Page Size
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: 页面行数检查
        run: npx ts-node scripts/check-page-size.ts
```

完整的 `needs` 依赖关系调整：

```yaml
  test:
    needs: [lint, typecheck]

  build:
    needs: [test, check-dependencies, check-page-size]
```

---

## 三、微信 H5 项目（wechat-h5）扩展

在基础流水线上追加：

```yaml
  check-page-size:
    name: Page Size
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: 页面行数检查
        run: npx ts-node scripts/check-page-size.ts

  check-dependencies:
    name: Dependencies
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: 依赖准入检查
        run: npx ts-node scripts/check-dependencies.ts
      - name: 依赖漏洞扫描
        run: bash scripts/check-audit.sh
```

---

## 四、小程序项目（miniprogram）扩展

在基础流水线上追加：

```yaml
  check-mp:
    name: Miniprogram Checks
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: 构建小程序
        run: pnpm build:mp-weixin

      - name: 主包体积检查
        run: npx ts-node scripts/check-mp-size.ts

      - name: 资源格式检查
        run: npx ts-node scripts/check-mp-resources.ts

  check-dependencies:
    name: Dependencies
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: 依赖准入检查
        run: npx ts-node scripts/check-dependencies.ts
      - name: 依赖漏洞扫描
        run: bash scripts/check-audit.sh

  check-page-size:
    name: Page Size
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: 页面行数检查
        run: npx ts-node scripts/check-page-size.ts
```

---

## 五、可复用的 Composite Action

如果多个项目共用相同的 Node + pnpm 初始化步骤，可提取为 Composite Action：

```yaml
# .github/actions/setup-node-pnpm/action.yml
# 可复用的 Node + pnpm 初始化步骤

name: Setup Node & pnpm
description: 安装 Node.js 和 pnpm，启用缓存

inputs:
  node-version:
    description: Node.js 版本
    default: '20'
  pnpm-version:
    description: pnpm 版本
    default: '9'

runs:
  using: composite
  steps:
    - uses: pnpm/action-setup@v4
      with:
        version: ${{ inputs.pnpm-version }}

    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: pnpm

    - name: 安装依赖
      shell: bash
      run: pnpm install --frozen-lockfile
```

使用方式：

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-node-pnpm
  - run: pnpm lint
```

---

## 六、流水线全景图

```
PR 提交 / Push to main
  │
  ├─ lint（ESLint + Prettier）        ─┐
  ├─ typecheck（TypeScript）           ├─ 并行
  ├─ check-branch（分支名校验）        │
  ├─ check-dependencies（依赖准入）    │
  └─ check-page-size（页面行数）       ─┘
          │
          ▼ 全部通过
      test（单元测试 + 覆盖率）
          │
          ▼ 通过
      build（构建验证）
          │
          ▼ 通过（仅小程序）
      check-mp（包体积 + 资源格式）
          │
          ▼ 全部通过
      ✅ 允许合并
```

---

## 七、脚本契约与 CI Job 对照表

| 脚本契约（tooling.md） | CI Job | 阻断行为 |
|------------------------|--------|----------|
| `pnpm lint` | lint | 失败阻断合并 |
| `pnpm typecheck` | typecheck | 失败阻断合并 |
| `pnpm test:coverage` | test | 失败或覆盖率不达标阻断合并 |
| `pnpm build` | build | 失败阻断合并 |
| `scripts/check-branch-name.sh` | check-branch | 分支名不合规阻断 |
| `scripts/check-dependencies.ts` | check-dependencies | 禁用依赖阻断 |
| `scripts/check-audit.sh` | check-dependencies | Critical/High 阻断 |
| `scripts/check-page-size.ts` | check-page-size | >300 行阻断 |
| `scripts/check-mp-size.ts` | check-mp | >2MB 阻断 |
| `scripts/check-mp-resources.ts` | check-mp | 禁止格式阻断 |

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | CI 必须包含 lint + typecheck + test + build 四个基础 job |
| 2 | MUST | 所有基础 job 通过后才允许合并 |
| 3 | MUST | 使用 `--frozen-lockfile` 安装依赖，禁止 CI 中修改 lock 文件 |
| 4 | MUST | 小程序项目必须在构建后执行包体积和资源格式检查 |
| 5 | SHOULD | 提取可复用的 Composite Action，减少配置重复 |
| 6 | SHOULD | 配置 `concurrency` 取消同 PR 的旧运行，节省资源 |

检查方式：CI 配置审查
阻断级别：MUST 条款阻断合并
