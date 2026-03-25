# rules/electron-desktop.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/electron-desktop/index.md`
2. 通用规则：`rules/electron-desktop/common/`
3. Electron v30+ 规则：`rules/electron-desktop/profiles/electron-v30/`

## 使用方式
1. 所有 Electron 桌面应用项目必须先遵守 `common`。
2. Electron v30+ 项目再叠加 `profiles/electron-v30`。
3. 编写代码时使用 `$electron-desktop-coding-guide` 按编码场景自动加载对应规则。
4. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
5. 涉及后端 API 交互时建议参考 `rules/go-server/common/api-design.md` 或 `rules/dotnet-server/common/api-design.md` 中的契约规范。
