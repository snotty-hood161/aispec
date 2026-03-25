---
name: security-auditor
description: 安全审计工具。当需要对项目进行安全审计（威胁建模、OWASP Top 10 检查、依赖漏洞扫描、密钥泄露检测、安全合规检查）时触发，自动加载安全基线规范，输出结构化的安全审计报告。
---

# 安全审计工具

对项目进行系统性的安全审计，覆盖威胁建模、OWASP Top 10、依赖安全、密钥管理、数据安全等维度。

## 何时使用
1. 项目上线前的安全审计。
2. 用户要求进行安全检查、漏洞扫描。
3. Code Review 中发现安全相关变更（认证、授权、加密、输入校验）。
4. 由 `$task-router` 或 Coordinator 调度时。

## 执行原则
1. 以 `rules/security/security-baseline.md` 为安全基线。
2. 以 `references/security-check-map.md` 为检查项路由表。
3. MUST 级安全条款为 P0 阻断项，SHOULD 级为 P1 改进项。
4. 安全审计不修改代码，仅输出发现和建议。
5. 涉及特定域的安全细节，读取对应域的 `common/security.md`（如 `rules/go-server/common/security.md`）。

## 标准工作流（必须执行）

### 1. 确定审计范围
- 从任务描述中提取审计目标（全项目 / 特定模块 / PR 变更）。
- 识别涉及的技术栈，确定需要检查的域。
- 若范围不明确，向用户确认。

### 2. 查表确定检查集
- 读取 `references/security-check-map.md`。
- 按审计范围和技术栈，确定本次需要执行的检查项。
- 始终执行：密钥泄露检测 + 依赖安全扫描。

### 3. 执行安全检查
- 按 OWASP Top 10 逐项检查（适用项）。
- 执行密钥和敏感信息检测。
- 检查依赖版本的已知漏洞。
- 检查认证授权实现。
- 检查数据安全措施。
- 每条发现标注：严重度（P0/P1/P2）、位置、修复建议。

### 4. 威胁建模（可选）
- 新项目或重大架构变更时执行 STRIDE 威胁建模。
- 识别攻击面和威胁向量。
- 为每个威胁提出缓解措施。

### 5. 输出安全审计报告
- 按 `rules/security/security-baseline.md` 中定义的报告格式输出。
- 包含：审计概览、OWASP 检查结果、依赖扫描结果、密钥检测结果、威胁建模结果（如执行）、整体结论。
- P0 必修项必须逐条列出修复方案。
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯（skill 名称、任务类型、加载规则清单、跨域联动）。

## 跨域联动
- 发现数据库安全问题 → 标注需联动 `$database-coding-guide`。
- 发现 API 安全问题 → 标注需联动 `$frontend-backend-coding-guide`。
- 发现客户端存储安全问题 → 标注需联动对应客户端域的 coding-guide。

## 资源
1. 安全基线：`rules/security/security-baseline.md`
2. 检查项路由表：`references/security-check-map.md`
3. 跨域仲裁：`rules/index.md`
