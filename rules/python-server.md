# rules/python-server.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/python-server/index.md`
2. 通用规则：`rules/python-server/common/`
3. 单体应用规则：`rules/python-server/profiles/monolith/`
4. 微服务规则：`rules/python-server/profiles/microservice/`
5. 前后端协作：`rules/frontend-backend-collaboration.md`

## 使用方式
1. 所有 Python 服务端项目必须先遵守 `common`。
2. 单体应用再叠加 `profiles/monolith`。
3. 微服务再叠加 `profiles/microservice`。
4. 编写代码时使用 `$python-server-coding-guide` 按编码场景自动加载对应规则。
5. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
6. 涉及跨端契约与联调任务建议使用 `$frontend-backend-coding-guide`。
