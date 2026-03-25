# 代码审查通用工作流

本文件定义所有 `*-code-reviewer` 类型 skill 的共享工作流。各域 SKILL.md 通过 `workflow` 字段引用本模板，并声明域参数。

## 执行原则
1. 以域 SKILL.md 中声明的 `rules_index` 为规则入口。
2. 以最小加载为默认策略：只读取变更文件命中的规则，不通读全部规则。
3. 以 MUST 规则为阻断基准，SHOULD 规则为改进建议。
4. 审查结论必须可追溯到具体规则条款。

## 最小加载顺序（必须）
1. 读取变更文件列表（diff / staged files / PR files）。
2. 读取域 SKILL.md 声明的 `rules_index` 获取规则索引。
3. 根据变更文件类型与路径，使用域 SKILL.md 声明的 `check_rules` 映射命中规则。
4. 仅打开命中的规则文件与关联模板。
5. 输出时附"本次实际读取文件清单"与"命中规则清单"。

## 标准工作流（必须执行）
1. **收集变更**：获取变更文件列表与 diff 内容。
2. **识别上下文**：按域 SKILL.md 声明的 `context_type` 标注上下文（如部署模式、应用类型）。
3. **规则映射**：用域 SKILL.md 声明的 `check_rules` 建立"变更文件 → 检查规则"映射。
4. **逐条检查**：按 P0 → P1 优先级逐条核对，记录通过/违规/不适用。
5. **输出报告**：按域 SKILL.md 声明的 `report_format` 输出结构化审查报告。
6. **执行追溯**：按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯。

## 审查范围
1. 默认审查 `common/*.md` 中所有 MUST 规则。
2. 按域 SKILL.md 声明的 `profile_paths` 追加对应 profile 专项规则。
3. 按域 SKILL.md 声明的 `extra_rules` 中的触发条件追加跨域规则。
