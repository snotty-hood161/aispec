# 任务特征 → 技术域映射表

用此表将用户任务描述中的关键词/特征映射到涉及的技术域和对应的 coding-guide。

## 使用方式
1. 提取任务描述中的关键词。
2. 按下表匹配涉及的域。
3. 一个任务可命中多个域。
4. 命中多域时按"执行顺序"列确定先后。

---

## 域识别表

| 关键词/特征 | 命中域 | 对应 coding-guide | 执行顺序 |
|------------|--------|-------------------|---------|
| 建表、加字段、迁移脚本、schema、索引 | 数据库 | `$database-coding-guide` | 1 |
| API、接口、路由、Handler、Controller、gRPC、中间件 | Go 服务端 | `$go-server-coding-guide` | 2 |
| API、接口、Controller、WebAPI、gRPC、中间件 | .NET 服务端 | `$dotnet-server-coding-guide` | 2 |
| FastAPI、Django、Flask、Python API、Celery、Uvicorn | Python 服务端 | `$python-server-coding-guide` | 2 |
| Spring Boot、Spring Cloud、Java API、MyBatis、JPA | Java 服务端 | `$java-server-coding-guide` | 2 |
| NestJS、Express、Fastify、Node.js API、BullMQ | Node.js 服务端 | `$node-server-coding-guide` | 2 |
| 定时任务、Worker、Job、消息消费、队列 | Go/.NET/Python/Java/Node 服务端 | 同上 | 2 |
| 缓存、Redis、Cache | Go/.NET/Python/Java/Node 服务端 | 同上 | 2 |
| 文件上传、OSS、MinIO、对象存储 | Go/.NET/Python/Java/Node 服务端 | 同上 | 2 |
| 前后端联调、接口契约、错误码映射、灰度发布 | 前后端协作 | `$frontend-backend-coding-guide` | 3 |
| 页面、组件、表单、列表、路由（前端）、Vue、React | 前端 | `$frontend-coding-guide` | 4 |
| 后台管理、admin、权限、菜单 | 前端 (admin-console) | `$frontend-coding-guide` | 4 |
| H5、公众号、微信授权、JSSDK、分享 | 前端 (wechat-h5) | `$frontend-coding-guide` | 4 |
| 小程序、miniprogram、分包、微信审核 | 前端 (miniprogram) | `$frontend-coding-guide` | 4 |
| WPF、MAUI、WinForms、桌面应用（C#） | .NET 桌面 | `$dotnet-desktop-coding-guide` | 4 |
| Tauri、Rust 桌面、IPC、跨平台桌面 | Tauri 桌面 | `$tauri-desktop-coding-guide` | 4 |
| Electron、electron-builder、主进程、渲染进程、preload | Electron 桌面 | `$electron-desktop-coding-guide` | 4 |
| React Native、RN、Expo、原生模块、React Navigation | React Native | `$react-native-coding-guide` | 4 |
| Android、Kotlin、Compose、Gradle | Android | `$android-coding-guide` | 4 |
| iOS、Swift、SwiftUI、UIKit、Xcode | iOS | `$ios-coding-guide` | 4 |
| Flutter、Dart、Widget、跨平台移动 | Flutter | `$flutter-coding-guide` | 4 |

## 多域组合常见模式

| 任务模式 | 典型域组合 | 执行顺序 |
|---------|-----------|---------|
| 新增业务功能（全栈） | 数据库 → Go/NET 服务端 → 前后端协作 → 前端 | 1→2→3→4 |
| 纯后端功能（定时任务/队列） | Go/NET 服务端 | 2 |
| 纯前端功能（页面/组件） | 前端 | 4 |
| 前端 + API 联调 | 前后端协作 → 前端 | 3→4 |
| 移动端功能 | 数据库 → 服务端 → 前后端协作 → Android/iOS/Flutter | 1→2→3→4 |
| 桌面应用功能 | 服务端（可选）→ .NET 桌面 / Tauri 桌面 / Electron 桌面 | 2→4 |

## 产品、设计与质量保障域识别

| 关键词/特征 | 命中域 | 对应 Skill / Agent | 执行顺序 |
|------------|--------|-------------------|---------|
| 产品需求、竞品分析、PRD、用户画像、用户故事、路线图 | 产品管理 | `$product-prd-writer` / Product Agent | -1 |
| 技术规格、spec、技术选型、架构设计、方案对比、模块划分 | 项目规格 | `$spec-generator` / Spec Agent | 0 |
| UI 设计、UX 设计、界面原型、设计系统、交互设计、视觉设计 | UI/UX 设计 | `$ui-ux-designer` / Design Agent | 0.5 |
| 设计走查、设计还原、像素对比、UI 验收、视觉回归 | 设计走查 | `$design-reviewer` / Design Agent | 4 |
| 安全审计、威胁建模、漏洞扫描、OWASP、安全合规、密钥检测 | 安全审计 | `$security-auditor` / Security Agent | 4.5 |
| 测试策略、测试用例、测试计划、验收测试、QA、E2E 测试 | 质量保障 | `$qa-test-strategist` / QA Agent | 5 |
| CI/CD、部署、发布、容器化、监控、告警、环境管理 | 部署运维 | `$devops-engineer` / DevOps Agent | 6 |

## 完整生命周期任务模式

| 任务模式 | 域组合 | 执行顺序 |
|---------|--------|---------|
| 从0到1做新产品 | 产品→规格∥设计→数据库→服务端→协作→客户端→安全→测试→运维 | -1→0∥0.5→1→2→3→4→4.5→5→6 |
| 新项目技术方案 | 规格→数据库→服务端→客户端 | 0→1→2→4 |
| 全栈新功能开发 | 数据库→服务端→协作→客户端 | 1→2→3→4 |
| 上线前全面检查 | 安全→测试→运维 | 4.5→5→6 |

## 域冲突消解
1. 同一任务中若无法确定是 Go 还是 .NET 服务端，询问用户。
2. 同一任务中若无法确定客户端类型，询问用户。
3. 数据库域始终最先执行。
4. 前后端协作域在服务端和客户端之间执行。
5. 安全审计在所有开发域之后、QA 之前执行。
6. DevOps 始终是最后执行的域。
