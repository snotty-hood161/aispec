# rules/frontend/common/git-workflow.md

## 文档目标
1. 统一三端前端项目的 Git 分支、提交、合并策略。
2. 与 CI/CD 流水线衔接，保障发布质量可追溯。

## 分支命名（MUST）
1. 功能分支：`feature/{issue-id}-简要描述`（如 `feature/123-user-login`）。
2. 缺陷修复：`fix/{issue-id}-简要描述`（如 `fix/456-list-scroll`）。
3. 发布分支：`release/{version}`（如 `release/1.2.0`）。
4. 热修复：`hotfix/{version}-简要描述`（如 `hotfix/1.2.1-token-expire`）。
5. 主分支固定为 `main`（或已有项目保持 `master`）。
6. 分支名全小写，单词用 `-` 连接，禁止中文、空格、大写。
7. 禁止在主分支直接提交代码。
检查方式：CI 分支名正则校验 + 分支保护规则
阻断级别：阻断合并

## 提交消息格式（MUST）
1. 遵循 **Conventional Commits** 规范。
2. 格式：`type(scope): description`。
3. `type` 枚举值：

| type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 缺陷修复 |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响逻辑） |
| `refactor` | 重构（非新功能、非修复） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `build` | 构建/依赖变更 |
| `ci` | CI 配置变更 |
| `chore` | 其他杂项 |

4. `scope` 可选，对应模块或功能域（如 `feat(order): 新增订单导出`）。
5. `description` 不超过 72 字符，不加句号，使用中文或英文均可但同一项目需统一。
6. 包含 Breaking Change 时必须在 footer 标注 `BREAKING CHANGE: 说明`。
7. 提交前由 `commitlint` + `husky` 自动校验。
检查方式：commitlint pre-commit hook
阻断级别：阻断提交

## 合并策略（MUST）
1. `feature/*` / `fix/*` → `main`：使用 **Squash Merge**，保持主分支线性。
2. `release/*` → `main`：使用 **Merge Commit**，保留完整发布记录。
3. `hotfix/*` → `main` + `release/*`：使用 **Cherry-pick** 或 **Merge Commit**。
4. 合并前必须通过 CI 全部检查 + 至少 1 人 Code Review Approve。
5. 合并后删除已合并的 feature/fix 分支。
检查方式：GitHub 仓库合并策略设置 + 人工审查
阻断级别：阻断合并

## Tag 与版本号（MUST）
1. 遵循 **SemVer**（语义化版本）：`v{major}.{minor}.{patch}`。
2. `major`：不兼容的 API 变更。
3. `minor`：向后兼容的功能新增。
4. `patch`：向后兼容的缺陷修复。
5. 仅从 `main` 分支打 Tag。
6. Tag 创建必须在 CI 构建通过后执行。
7. 预发布版本使用 `-beta.{n}` 或 `-rc.{n}` 后缀。
检查方式：人工审查
阻断级别：阻断发布

## 受保护分支（MUST）
1. `main`（或 `master`）必须开启分支保护。
2. 保护规则包含：
   - 合并前必须通过 CI 状态检查。
   - 合并前必须至少 1 人 Approve。
   - 禁止 Force Push。
   - 禁止直接删除。
3. `release/*` 分支在存续期间同样开启保护。
检查方式：仓库设置审查
阻断级别：阻断合并

## 建议规则（SHOULD）
1. PR 标题遵循 Conventional Commits 格式，便于自动生成 Changelog。
2. Feature 分支定期 Rebase main，保持分支最新，减少合并冲突。
3. 已合并分支及时删除，保持仓库分支列表简洁。
4. 长期分支（超过 2 周未合并）需在周会中说明原因和计划。
5. 使用 `git rebase -i` 整理本地提交后再推送（避免"wip"提交进入 PR）。
检查方式：人工审查
阻断级别：告警记录

## 配套模板
1. commitlint / husky / lint-staged 配置 + 分支名校验 → `rules/templates/frontend/git-workflow-config.md`
