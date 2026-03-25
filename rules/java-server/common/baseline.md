# rules/java-server/common/baseline.md

## 技术基线

### MUST
1. JDK 版本以项目根 `pom.xml` 或 `build.gradle` 中声明的 `java.version` / `sourceCompatibility` 为准，升级 JDK 版本必须单独提交并验证兼容性。
2. 新项目默认使用 JDK 17 LTS 及以上版本，禁止使用已终止公开更新的 JDK 版本（如 JDK 8、JDK 11 除非存量项目有迁移计划）。
3. 构建工具统一使用 Maven 或 Gradle（二选一），同一项目禁止混用。
4. Maven 项目必须通过 `<dependencyManagement>` 或 BOM（Bill of Materials）统一管理依赖版本；Gradle 项目必须使用 `platform()` 或 Version Catalog 统一管理。
5. Spring Boot 版本以 `spring-boot-starter-parent` 或 BOM 锁定，禁止各模块自行指定不同 Spring Boot 版本。

## 依赖安全审查（MUST）

1. CI 流水线必须集成依赖漏洞扫描工具（推荐 OWASP Dependency-Check 或 Snyk），发现高危漏洞（CVSS ≥ 7.0）阻断合并。
2. 新增或升级第三方依赖前，必须确认其许可证兼容项目发布方式（商用项目禁止引入 GPL/AGPL 依赖）。
3. 禁止引入已归档（archived）、超过 12 个月无维护更新的依赖，确需使用须在 PR 中说明风险并附回收计划。
4. `pom.xml` 中的 `<dependency>` 版本禁止使用 `LATEST`、`RELEASE` 或范围版本（如 `[1.0,2.0)`），必须锁定具体版本号。
5. 依赖更新必须单独提交（与业务代码分离），便于审查和回滚。
6. `mvnw` / `gradlew` Wrapper 文件必须纳入版本控制，保证构建环境一致性。

### SHOULD
1. 定期（每月）执行全量依赖漏洞扫描，输出漏洞报告并限时修复。
2. 核心依赖（Spring Boot、数据库驱动、日志框架等）锁定主版本，升级需经评审。
3. 使用 `mvn dependency:tree` 或 `gradle dependencies` 定期检查依赖冲突和传递依赖膨胀。

检查方式：OWASP Dependency-Check / Snyk + CI 阻断
阻断级别：阻断合并（高危漏洞）/ 告警记录（中低危）

## 代码质量工具（MUST）

1. CI 流水线必须集成代码质量检查，至少包含以下一项：Checkstyle（代码风格）、SpotBugs（缺陷检测）、PMD（静态分析）。
2. Checkstyle 配置文件（`checkstyle.xml`）必须纳入版本控制，团队统一使用同一规则集。
3. SpotBugs 发现 High 级别缺陷阻断合并；Medium 级别记录并限时修复。
4. 禁止通过 `@SuppressWarnings` 绕过 SpotBugs/PMD 告警，确需豁免须在 PR 中说明原因。

### SHOULD
1. 集成 SonarQube 做持续代码质量管理，跟踪技术债趋势。
2. 配置 IDE（IntelliJ IDEA）的代码检查规则与 CI 一致，开发阶段即发现问题。

检查方式：Checkstyle + SpotBugs + CI 阻断
阻断级别：阻断合并

## 基础工程要求
1. 启动类（`@SpringBootApplication`）仅做应用启动和组件扫描，不承载业务逻辑。
2. 业务代码必须按分层组织（Controller → Service → Repository），禁止横向耦合和循环依赖。
3. 可复用且无业务语义的通用能力放入独立模块或包（如 `common`、`infrastructure`）。
4. 带作用域语义的能力（如 `admin`、`user`、`open`）按"作用域 + 职责"组织包结构。
5. 错误处理必须采用"统一异常处理（`@ControllerAdvice`）+ 统一响应结构"模式，禁止边界层散落式实现。
6. 组件初始化必须遵循 `common/component-initialization.md`，采用 Spring 依赖注入与统一生命周期管理。
