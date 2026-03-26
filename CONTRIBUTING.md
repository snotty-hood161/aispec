# 贡献指南

感谢你对 AI 工程规范体系的贡献！以下是参与本项目的指南。

## 项目结构

```
aispec/
├── rules/     ← 规则层（唯一规则真源）
├── skills/    ← 能力层（AI 执行入口）
└── agents/    ← 编排层（多 Agent 模式）
```

## 环境要求

- **校验脚本**依赖 **Bash** 和 **ripgrep（`rg`）**。
- **Windows 用户**：请通过 Git Bash、WSL 或等价 POSIX 环境运行 `validate_rules.sh` 和 `semantic_lint_rules.sh`。
- ripgrep 安装：`scoop install ripgrep`（Windows）/ `brew install ripgrep`（macOS）/ `apt install ripgrep`（Ubuntu）。

## 贡献方式

### 1. 规则贡献（rules/）

规则文件是本体系的核心，贡献时请遵循：

- **格式**：关键条款标注 `MUST`（阻断级）或 `SHOULD`（建议级）。
- **结构**：入口/索引类规则文件包含 `## Skill 协作` 章节，说明哪些 skill 会加载本规则。
- **索引**：新增规则文件后，必须更新对应域的 `index.md` 和 `rules/index.md`。
- **校验**：运行对应域的校验脚本确保通过。脚本位于 `skills/<域>-rules-maintainer/scripts/` 目录下（如 `skills/go-server-rules-maintainer/scripts/validate_rules.sh`）。注意：跨域规范（security、environment、observability、api-versioning、release、testing、i18n、design、monorepo）没有对应的 rules-maintainer skill 和校验脚本，变更时需人工审查。

### 2. Skill 贡献（skills/）

每个 Skill 包含：
- `SKILL.md` — Skill 定义（触发条件、工作流、输出格式）。
- `references/` — 映射表和辅助文件。

### 3. Agent 贡献（agents/）

Agent 定义遵循统一结构：
- 支持 Agent（Product / Spec / Design / Security / QA / DevOps）：身份、核心价值、职责边界、可用 Skills、任务识别、标准工作流、协作接口。
- 域 Agent（各技术栈域）：身份、职责边界、可用 Skills、域识别关键词、关联 Rules、跨域交接、协作接口。

## 提交流程

1. Fork 本仓库。
2. 创建功能分支：`feature/add-{domain}-{feature}`。
3. 编写内容，确保通过校验脚本。
4. 提交 PR，描述变更内容和原因。

## 提交消息规范

```
{type}: {description}

type 取值：
- feat:     新增规则/Skill/Agent
- fix:      修复规则内容或逻辑错误
- refactor: 重构规则结构（无内容变更）
- docs:     文档更新
- chore:    索引、配置等维护性变更
```

## 审查标准

- 新增规则必须有明确的来源依据（业界最佳实践、安全标准等）。
- 规则之间不应存在冲突（参考 `rules/index.md` 的冲突仲裁规则）。
- MUST 级规则必须是可自动化验证的。
- 所有文案使用中文。

## 问题反馈

发现规则错误或有改进建议，请创建 Issue 并标注：
- `bug` — 规则内容错误
- `enhancement` — 改进建议
- `new-domain` — 新增技术域请求
