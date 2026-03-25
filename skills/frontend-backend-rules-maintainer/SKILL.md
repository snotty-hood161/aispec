---
name: frontend-backend-rules-maintainer
description: 维护并执行前后端协作约束。用于用户要求定义或调整 API 契约、错误码映射、联调流程、发布顺序与回滚策略时触发，尤其适用于需要联合 `rules/frontend`、`rules/go-server`、`rules/dotnet-server` 与 `rules/frontend-backend-collaboration.md` 做跨端一致性审计并输出可合并结论（含 P0/P1 风险）的场景。
workflow: _templates/rules-maintainer-workflow.md
---

# 前后端协作规则执行器

## 域参数

- **domain**: frontend-backend
- **rules_index**: `rules/frontend-backend-collaboration.md`
- **load_map**: `references/load-map.md`
- **change_modes**: `skills/_templates/rules-maintainer-refs-template.md`
- **output_contract**: `skills/_templates/rules-maintainer-refs-template.md`
- **checklist**: `skills/_templates/rules-maintainer-refs-template.md`
- **validate_script**: `scripts/validate_rules.sh`
- **lint_script**: `scripts/semantic_lint_rules.sh`
- **cross_domain_trigger**: 涉及数据库变更
- **cross_domain_file**: `rules/database/database.md`

## 域特有说明

前后端协作规则采用 `load-map.md`（按需加载映射）而非 `scope-map.md`（主题落点映射），因为跨端任务的规则加载路径取决于变更类型（契约/联调/发布）与涉及的服务端技术栈（Go / .NET / Python / Java / Node.js），需要动态组合前端与服务端规则文件，而非单一主题到文件的固定映射。

## 资源

1. 任务映射：`references/load-map.md`
2. 变更模式：`skills/_templates/rules-maintainer-refs-template.md`
3. 输出协议：`skills/_templates/rules-maintainer-refs-template.md`
4. 执行核对：`skills/_templates/rules-maintainer-refs-template.md`
5. 协作模板：`rules/templates/frontend-backend/`
6. 结构校验脚本：`scripts/validate_rules.sh`
7. 语义校验脚本：`scripts/semantic_lint_rules.sh`
