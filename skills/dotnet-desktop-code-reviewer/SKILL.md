---
name: dotnet-desktop-code-reviewer
description: 自动审查 C#/.NET 桌面应用代码变更是否符合规则体系。用于 PR 评审、代码审计、变更合规检查场景；读取 diff/变更文件列表，映射命中规则，逐条检查 MUST/SHOULD 合规性，输出结构化审查报告（P0 阻断 / P1 建议 / 通过项）。
workflow: _templates/code-reviewer-workflow.md
---

# .NET 桌面代码审查器

## 域参数

- **domain**: dotnet-desktop
- **rules_index**: `rules/dotnet-desktop/index.md`
- **check_rules**: `references/check-rules.md`
- **report_format**: `skills/_templates/report-format-template.md`
- **pr_checklist**: `rules/templates/dotnet-desktop/pr-review-checklist.md`
- **context_type**: 框架（WPF / MAUI / WinForms）
- **profile_paths**: `profiles/wpf/*.md`, `profiles/maui/*.md`, `profiles/winforms/*.md`

## 资源
1. 检查规则清单：`references/check-rules.md`
2. 报告输出格式：`skills/_templates/report-format-template.md`
3. PR 评审清单（参考）：`rules/templates/dotnet-desktop/pr-review-checklist.md`
