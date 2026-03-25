# rules/android.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/android/index.md`
2. 通用规则：`rules/android/common/`
3. Compose 规则：`rules/android/profiles/compose/`
4. XML Views 规则：`rules/android/profiles/xml-views/`

## 使用方式
1. 所有 Android 应用项目必须先遵守 `common`。
2. Jetpack Compose 项目再叠加 `profiles/compose`。
3. 传统 XML Views 项目再叠加 `profiles/xml-views`。
4. 编写代码时使用 `$android-coding-guide` 按编码场景自动加载对应规则。
5. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
6. 涉及后端 API 交互时建议参考 `rules/go-server/common/api-design.md` 或 `rules/dotnet-server/common/api-design.md` 中的契约规范。
