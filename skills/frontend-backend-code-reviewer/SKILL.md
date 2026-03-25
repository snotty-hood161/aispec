---
name: frontend-backend-code-reviewer
description: 自动审查前后端协作变更是否符合跨端规则体系。用于涉及 API 契约变更、错误码映射、联调流程、发布回滚的 PR 评审场景；同时读取前端和服务端变更，对照协作规范逐条检查，输出结构化审查报告（P0 阻断 / P1 建议 / 通过项）。
workflow: _templates/code-reviewer-workflow.md
---

# 前后端协作代码审查器

## 域参数

- **domain**: frontend-backend
- **rules_index**: `rules/frontend-backend-collaboration.md`
- **check_rules**: `references/check-rules.md`
- **report_format**: `skills/_templates/report-format-template.md`
- **pr_checklist**: `rules/templates/frontend-backend/pr-review-checklist.md`

## 域特有说明

1. **同时审视前后端**：需同时读取前端与服务端变更文件，按需追加读取 `rules/frontend/index.md` 和/或对应服务端域的 `rules/<server-domain>/index.md`。
2. **契约一致性检查**：在标准工作流"逐条检查"步骤前，增加契约一致性检查——对照 API 契约模板，检查请求参数、响应结构、错误码是否前后端一致。
3. **变更分级**：识别上下文时标注变更分级（兼容变更 / 非兼容变更）。
4. **跨域委托**：前端侧细节问题交由 `$frontend-code-reviewer` 处理；服务端侧细节问题交由对应域的 code-reviewer 处理。

## 资源
1. 检查规则清单：`references/check-rules.md`
2. 报告输出格式：`skills/_templates/report-format-template.md`
3. API 契约模板：`rules/templates/frontend-backend/api-contract-template.md`
4. 联调检查清单：`rules/templates/frontend-backend/integration-checklist-template.md`
5. 发布回滚记录：`rules/templates/frontend-backend/release-rollback-record-template.md`
