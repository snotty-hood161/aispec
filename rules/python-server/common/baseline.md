# rules/python-server/common/baseline.md

## 技术基线
1. Python 版本以 `pyproject.toml` 或 `.python-version` 为准，升级 Python 版本必须单独提交并验证兼容性。
2. 生产项目 MUST 使用 Python 3.10+，推荐 3.12+；禁止使用已 EOL 的 Python 版本。
3. 必须使用虚拟环境（`venv` / `virtualenv` / `conda`），禁止在系统 Python 中直接安装依赖。
4. 包管理工具统一选用一种：`poetry`、`uv` 或 `pip + requirements.txt`，同一项目禁止混用。
5. 必须存在 lockfile（`poetry.lock` / `uv.lock` / `requirements.txt` 含版本锁定），且纳入版本控制。

## 依赖安全审查（MUST）

1. CI 流水线必须集成依赖漏洞扫描工具（`pip-audit` / `safety` / `osv-scanner`），发现高危漏洞（CVSS ≥ 7.0）阻断合并。
2. 新增或升级第三方依赖前，必须确认其许可证兼容项目发布方式（商用项目禁止引入 GPL/AGPL 依赖）。
3. 禁止引入已归档（archived）、超过 12 个月无维护更新的依赖，确需使用须在 PR 中说明风险并附回收计划。
4. lockfile 必须纳入版本控制，禁止在 `.gitignore` 中忽略。
5. 依赖更新必须单独提交（与业务代码分离），便于审查和回滚。

### SHOULD
1. 定期（每月）执行 `pip-audit` 全量扫描，输出漏洞报告并限时修复。
2. 使用 `licensecheck` 或等效工具自动检测依赖许可证合规性，纳入 CI 检查。
3. 核心依赖（Web 框架、ORM、异步任务框架等）锁定主版本，升级需经评审。

检查方式：`pip-audit` + 许可证扫描 + CI 阻断
阻断级别：阻断合并（高危漏洞）/ 告警记录（中低危）

## 基础工程要求
1. 启动入口仅做依赖组装和生命周期管理，不承载业务逻辑。
2. 业务代码必须按分层组织，禁止横向耦合和循环依赖。
3. 可复用且无业务语义的通用能力放入 `lib/` 或 `core/`（如 `core/middleware`）。
4. 带作用域语义的能力（如 `admin`、`user`、`open`）放入各自模块，按"作用域 + 职责"做到"一文件一责任"。
5. 错误处理必须采用"统一异常处理器 + 统一响应结构"模式，禁止边界层散落式实现。
6. 组件初始化必须遵循 `common/component-initialization.md`，采用显式依赖注入与统一生命周期管理。

## 代码质量工具（MUST）

1. 必须集成 Linter：推荐 `ruff`（兼容 flake8/isort/pyflakes），配置纳入版本控制（`pyproject.toml` 或 `ruff.toml`）。
2. 必须集成类型检查器：推荐 `mypy`（strict 模式）或 `pyright`，CI 中必须通过类型检查。
3. 必须集成代码格式化工具：推荐 `ruff format` 或 `black`，CI 中检查格式一致性。
4. 提交前必须确保 `ruff check` 和 `mypy` 无新增错误。

### ruff 推荐配置示例
```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "A", "SIM", "TCH", "RUF"]

[tool.ruff.lint.isort]
known-first-party = ["app"]
```

检查方式：`ruff` + `mypy` + CI 阻断
阻断级别：阻断合并
