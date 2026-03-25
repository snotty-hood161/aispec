---
name: android-rules-maintainer
description: 维护并执行 Android 移动端应用约束规范。用于用户要求新增、修改、重构、审计或对齐 `android` 规则体系时触发，适用于 Kotlin/Java Android 原生应用的架构分层、依赖注入、Compose/XML 规范、安全存储等规则维护场景。
workflow: _templates/rules-maintainer-workflow.md
---

# Android 规则执行器

## 域参数

- **domain**: android
- **rules_index**: `rules/android/index.md`
- **scope_map**: `references/scope-map.md`
- **structure**: `references/structure.md`
- **change_modes**: `skills/_templates/rules-maintainer-refs-template.md`
- **output_contract**: `skills/_templates/rules-maintainer-refs-template.md`
- **checklist**: `skills/_templates/rules-maintainer-refs-template.md`
- **validate_script**: `scripts/validate_rules.sh`
- **lint_script**: `scripts/semantic_lint_rules.sh`
- **cross_domain_trigger**: 需求涉及与服务端 API 交互（HTTP 请求、接口契约、鉴权）
- **cross_domain_file**: `rules/frontend-backend-collaboration.md`
- **priority**: profile > common

## 资源

1. 结构参考：`references/structure.md`
2. 主题落点：`references/scope-map.md`
3. 变更模式：`skills/_templates/rules-maintainer-refs-template.md`
4. 输出协议：`skills/_templates/rules-maintainer-refs-template.md`
5. 评审核对：`skills/_templates/rules-maintainer-refs-template.md`
6. 结构校验脚本：`scripts/validate_rules.sh`
7. 语义校验脚本：`scripts/semantic_lint_rules.sh`
