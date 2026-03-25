# rules/ios.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/ios/index.md`
2. 通用规则：`rules/ios/common/`
3. SwiftUI 规则：`rules/ios/profiles/swiftui/`
4. UIKit 规则：`rules/ios/profiles/uikit/`

## 使用方式
1. 所有 iOS 应用项目必须先遵守 `common`。
2. SwiftUI 项目再叠加 `profiles/swiftui`。
3. UIKit 项目再叠加 `profiles/uikit`。
4. 编写代码时使用 `$ios-coding-guide` 按编码场景自动加载对应规则。
5. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
6. 涉及后端 API 交互时建议参考 `rules/go-server/common/api-design.md` 或 `rules/dotnet-server/common/api-design.md` 中的契约规范。
