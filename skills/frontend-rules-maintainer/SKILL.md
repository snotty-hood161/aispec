---
name: frontend-rules-maintainer
description: 维护并执行前端项目规范。用于用户要求新增、修改、重构、审计或对齐 `rules/frontend` 规则体系时触发，尤其适用于需要按需加载规则文件、映射到 common/applications、并给出可合并结论（含 P0/P1 风险）的场景；当需求涉及 API 契约、联调、发布顺序时需联动 `rules/frontend-backend-collaboration.md`。
workflow: _templates/rules-maintainer-workflow.md
---

# 前端规则执行器

## 域参数

- **domain**: frontend
- **rules_index**: `rules/frontend/index.md`
- **load_map**: `references/load-map.md`
- **change_modes**: `skills/_templates/rules-maintainer-refs-template.md`
- **output_contract**: `skills/_templates/rules-maintainer-refs-template.md`
- **checklist**: `skills/_templates/rules-maintainer-refs-template.md`
- **validate_script**: `scripts/validate_rules.sh`
- **lint_script**: `scripts/semantic_lint_rules.sh`
- **cross_domain_trigger**: 需求涉及接口契约/错误码/联调/发布回滚
- **cross_domain_file**: `rules/frontend-backend-collaboration.md`

## 域特有说明

前端规则体系采用 `load-map.md`（按需加载映射）而非 `scope-map.md`（主题落点映射），因为前端存在 applications × frameworks × project-structure 的多维组合，规则加载路径取决于应用类型与框架选型的组合，而非单一主题到文件的固定映射。

## 资源

1. 任务映射：`references/load-map.md`
2. 变更模式：`skills/_templates/rules-maintainer-refs-template.md`
3. 输出协议：`skills/_templates/rules-maintainer-refs-template.md`
4. 执行核对：`skills/_templates/rules-maintainer-refs-template.md`
5. 结构校验脚本：`scripts/validate_rules.sh`
6. 语义校验脚本：`scripts/semantic_lint_rules.sh`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
