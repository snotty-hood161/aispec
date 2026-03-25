---
name: node-server-code-reviewer
description: 自动审查 Node.js 服务端代码变更是否符合规则体系。用于 PR 评审、代码审计、变更合规检查场景；读取 diff/变更文件列表，映射命中规则，逐条检查 MUST/SHOULD 合规性，输出结构化审查报告（P0 阻断 / P1 建议 / 通过项）。
workflow: _templates/code-reviewer-workflow.md
---

# Node.js 服务端代码审查器

## 域参数

- **domain**: node-server
- **rules_index**: `rules/node-server/index.md`
- **check_rules**: `references/check-rules.md`
- **report_format**: `skills/_templates/report-format-template.md`
- **pr_checklist**: `rules/templates/node-server/pr-review-checklist.md`
- **context_type**: 部署模式（monolith / microservice）
- **profile_paths**: `profiles/monolith/*.md`, `profiles/microservice/*.md`

## 跨域审查追加

| 变更类型 | 追加规则 |
|---------|---------|
| 接口变更 | `rules/frontend-backend-collaboration.md` |
| 数据库变更 | `rules/database/database.md` |

## 资源
1. 检查规则清单：`references/check-rules.md`
2. 报告输出格式：`skills/_templates/report-format-template.md`
3. PR 评审清单（参考）：`rules/templates/node-server/pr-review-checklist.md`
