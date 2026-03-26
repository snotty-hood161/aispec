---
name: database-code-reviewer
description: 自动审查数据库 Schema 与迁移脚本变更是否符合规则体系。用于 PR 评审、代码审计、变更合规检查场景；读取 diff/变更文件列表，映射命中规则，逐条检查 MUST 合规性，输出结构化审查报告（P0 阻断 / P1 建议 / 通过项）。
workflow: _templates/code-reviewer-workflow.md
---

# 数据库代码审查器

## 域参数

- **domain**: database
- **rules_index**: `rules/database/index.md`
- **check_rules**: `references/check-rules.md`
- **report_format**: `skills/_templates/report-format-template.md`
- **pr_checklist**: `rules/templates/database/pr-review-checklist.md`

## 资源
1. 检查规则清单：`references/check-rules.md`
2. 报告输出格式：`skills/_templates/report-format-template.md`
3. PR 评审清单（参考）：`rules/templates/database/pr-review-checklist.md`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
