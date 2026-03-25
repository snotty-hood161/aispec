---
name: dotnet-desktop-rules-maintainer
description: 维护并执行 .NET 桌面应用约束规范。用于用户要求新增、修改、重构、审计或对齐 `dotnet-desktop` 规则体系时触发，适用于 WPF、MAUI、WinForms 桌面应用的 MVVM/MVP 架构、UI 线程、本地存储、自动更新等规则维护场景。
workflow: _templates/rules-maintainer-workflow.md
---

# .NET 桌面规则执行器

## 域参数

- **domain**: dotnet-desktop
- **rules_index**: `rules/dotnet-desktop/index.md`
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
