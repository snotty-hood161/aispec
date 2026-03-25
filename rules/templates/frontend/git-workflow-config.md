# Git 工作流配置模板

## 文档目标
1. 提供 commitlint、husky、lint-staged 配置模板和分支名校验脚本。
2. Git 工作流规则参见 `common/git-workflow.md`。

## 使用方式
- **谁用**：项目初始化者。
- **何时用**：新建前端项目时配置 Git 规范自动化；或老项目接入 Git 规范时。
- **怎么用**：按顺序安装依赖、复制配置文件、初始化 husky hooks。

---

## 一、依赖安装

```bash
# 安装 commitlint（提交消息校验）
npm install -D @commitlint/cli @commitlint/config-conventional

# 安装 husky（Git hooks 管理）
npm install -D husky

# 安装 lint-staged（暂存区文件 lint）
npm install -D lint-staged

# 初始化 husky
npx husky init
```

---

## 二、commitlint 配置

### 2.1 配置文件（`commitlint.config.js`）

```js
// commitlint.config.js
// 提交消息校验配置，遵循 Conventional Commits 规范

/** @type {import('@commitlint/types').UserConfig} */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    /** type 枚举值（与 git-workflow.md 保持一致） */
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新功能
        'fix',      // 缺陷修复
        'docs',     // 文档变更
        'style',    // 代码格式（不影响逻辑）
        'refactor', // 重构
        'perf',     // 性能优化
        'test',     // 测试相关
        'build',    // 构建/依赖变更
        'ci',       // CI 配置变更
        'chore',    // 其他杂项
      ],
    ],
    /** subject 不超过 72 字符 */
    'subject-max-length': [2, 'always', 72],
    /** subject 不以句号结尾 */
    'subject-full-stop': [2, 'never', '.'],
    /** type 必须小写 */
    'type-case': [2, 'always', 'lower-case'],
    /** subject 不能为空 */
    'subject-empty': [2, 'never'],
    /** type 不能为空 */
    'type-empty': [2, 'never'],
  },
}
```

### 2.2 husky commit-msg hook

```bash
# .husky/commit-msg
npx --no -- commitlint --edit $1
```

创建方式：

```bash
# 创建 commit-msg hook
echo 'npx --no -- commitlint --edit $1' > .husky/commit-msg
```

---

## 三、lint-staged 配置

### 3.1 配置文件（`.lintstagedrc`）

```json
{
  "*.{ts,tsx,vue}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{css,scss,less}": [
    "prettier --write"
  ],
  "*.md": [
    "prettier --write"
  ]
}
```

### 3.2 husky pre-commit hook

```bash
# .husky/pre-commit
npx lint-staged
```

创建方式：

```bash
# 创建 pre-commit hook
echo 'npx lint-staged' > .husky/pre-commit
```

---

## 四、分支名校验脚本

### 4.1 脚本（`scripts/check-branch-name.sh`）

```bash
#!/bin/bash
# scripts/check-branch-name.sh
# 校验当前分支名是否符合命名规范
# CI 中执行：bash scripts/check-branch-name.sh

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 允许的分支名模式
PATTERN="^(main|master|develop|feature\/[a-z0-9]+-[a-z0-9-]+|fix\/[a-z0-9]+-[a-z0-9-]+|release\/[0-9]+\.[0-9]+\.[0-9]+|hotfix\/[0-9]+\.[0-9]+\.[0-9]+-[a-z0-9-]+)$"

if [[ ! "$BRANCH" =~ $PATTERN ]]; then
  echo "❌ 分支名不合规：$BRANCH"
  echo ""
  echo "允许的格式："
  echo "  feature/{issue-id}-简要描述  如 feature/123-user-login"
  echo "  fix/{issue-id}-简要描述      如 fix/456-list-scroll"
  echo "  release/{version}            如 release/1.2.0"
  echo "  hotfix/{version}-描述        如 hotfix/1.2.1-token-expire"
  echo "  main / master / develop"
  exit 1
fi

echo "✅ 分支名合规：$BRANCH"
```

### 4.2 CI 集成

```yaml
# .github/workflows/ci.yml 片段
- name: 分支名校验
  run: bash scripts/check-branch-name.sh
```

---

## 五、GitHub 分支保护配置参考

在仓库 Settings → Branches → Branch protection rules 中配置：

```
分支模式：main（或 master）

✅ Require a pull request before merging
   ✅ Require approvals: 1
   ✅ Dismiss stale pull request approvals when new commits are pushed

✅ Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   必选状态检查：lint, typecheck, test（与 CI job 名对应）

✅ Require linear history（强制线性历史，配合 Squash Merge）

❌ Allow force pushes（禁止强制推送）
❌ Allow deletions（禁止删除）
```

对于 `release/*` 分支，创建相同保护规则但 pattern 为 `release/*`。

---

## 六、package.json 脚本

```json
{
  "scripts": {
    "prepare": "husky",
    "check:branch": "bash scripts/check-branch-name.sh"
  }
}
```

---

## 七、.gitignore 补充项

确保以下条目存在：

```gitignore
# 环境变量（敏感信息）
.env.local
.env.*.local

# 编辑器
.vscode/settings.json
.idea/

# 系统文件
.DS_Store
Thumbs.db
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 分支名必须符合 `feature/fix/release/hotfix` + kebab-case 格式 |
| 2 | MUST | 提交消息必须遵循 Conventional Commits 格式 |
| 3 | MUST | commitlint + husky 必须在项目初始化时配置 |
| 4 | MUST | 主分支必须开启分支保护，禁止直接提交和 Force Push |
| 5 | SHOULD | PR 标题遵循 Conventional Commits 格式 |
| 6 | SHOULD | lint-staged 配置暂存区文件自动格式化 |

检查方式：Git hooks + CI 分支名校验
阻断级别：MUST 条款阻断提交/合并
