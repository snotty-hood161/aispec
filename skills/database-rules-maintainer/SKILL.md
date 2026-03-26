---
name: database-rules-maintainer
description: 维护并执行数据库 Schema 与迁移约束规范。用于用户要求新增、修改、审计数据库规则时触发，适用于 Schema 初始化脚本、迁移脚本命名、历史脚本保护等规则维护场景。
workflow: _templates/rules-maintainer-workflow.md
---

# 数据库规则执行器

## 域参数

- **domain**: database
- **rules_index**: `database/database.md`
- **scope_map**: `references/scope-map.md`
- **structure**: `references/structure.md`
- **change_modes**: `skills/_templates/rules-maintainer-refs-template.md`
- **output_contract**: `skills/_templates/rules-maintainer-refs-template.md`
- **checklist**: `skills/_templates/rules-maintainer-refs-template.md`
- **validate_script**: `scripts/validate_rules.sh`
- **lint_script**: `scripts/semantic_lint_rules.sh`
- **cross_domain_trigger**: 需求涉及跨端影响
- **cross_domain_file**: `rules/frontend-backend-collaboration.md`
- **priority**: 数据库规则在跨域冲突中拥有最高优先级

## 资源

1. 结构参考：`references/structure.md`
2. 主题落点：`references/scope-map.md`
3. 变更模式：`skills/_templates/rules-maintainer-refs-template.md`
4. 输出协议：`skills/_templates/rules-maintainer-refs-template.md`
5. 评审核对：`skills/_templates/rules-maintainer-refs-template.md`
6. 结构校验脚本：`scripts/validate_rules.sh`
7. 语义校验脚本：`scripts/semantic_lint_rules.sh`

## 输出要求（MUST）
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯摘要（调用 Skill、任务类型、加载规则、跨域规则、跨域联动）。
