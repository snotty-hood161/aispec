# rules/frontend/project-structure/admin-console.md

## 文档目标
1. 定义后台管理项目的目录结构与分层约束。
2. 让后台管理项目只读取本文件即可完成结构落地。

## 项目结构（MUST）
```text
admin-console/
|-- src/
|   |-- app/               # 启动、路由、权限守卫
|   |-- modules/           # 业务域模块（订单、用户、财务等）
|   |-- pages/             # 页面容器层
|   |-- components/        # 跨模块复用组件
|   |-- services/          # API 请求与 DTO 转换
|   |-- stores/            # Pinia 状态模块
|   |-- permission/        # 权限点定义与校验
|   |-- editor/            # Tiptap 扩展与配置
|   |-- utils/
|   |-- styles/
|   `-- types/
|-- tests/
`-- ...
```

## 分层边界（MUST）
1. `modules/*` 只消费 `services`、`components`、`stores` 等公共层，不得跨模块直接耦合页面实现。
2. `pages/*` 作为路由容器，复杂 UI 逻辑下沉到 `modules/*` 或 `components/*`。
3. 权限点必须在 `permission/*` 集中定义，页面禁止散落权限字符串。
4. 富文本相关能力统一在 `editor/*` 封装，页面只消费配置后的能力。

## 检查要求
1. 检查方式：人工评审 + 静态扫描（目录边界/循环依赖）。
2. 阻断级别：阻断合并。
