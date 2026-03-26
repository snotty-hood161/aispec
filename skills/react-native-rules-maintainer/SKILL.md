---
name: react-native-rules-maintainer
description: 维护并执行 React Native 跨平台应用约束规范。用于用户要求新增、修改、重构、审计或对齐 `react-native` 规则体系时触发，适用于 TypeScript 编码规范、跨平台架构、原生模块桥接、导航、状态管理等规则维护场景；当需求涉及 API 契约、联调、发布顺序时需联动 `rules/frontend-backend-collaboration.md`。
workflow: _templates/rules-maintainer-workflow.md
---

# React Native 规则执行器

## 域参数

- **domain**: react-native
- **rules_index**: `rules/react-native/index.md`
- **scope_map**: `references/scope-map.md`
- **structure**: `references/structure.md`
- **change_modes**: `skills/_templates/rules-maintainer-refs-template.md`
- **output_contract**: `skills/_templates/rules-maintainer-refs-template.md`
- **checklist**: `skills/_templates/rules-maintainer-refs-template.md`
- **validate_script**: `scripts/validate_rules.sh`
- **lint_script**: `scripts/semantic_lint_rules.sh`
- **cross_domain_trigger**: 需求涉及 API 契约/错误码协同/联调/发布顺序
- **cross_domain_file**: `rules/frontend-backend-collaboration.md`
- **priority**: profile > common；数据库迁移规则以 `database/database.md` 为准

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
