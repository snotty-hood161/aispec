# rules/frontend/project-structure/miniprogram.md

## 文档目标
1. 定义小程序目标端（uni-app）的目录结构与分包边界。
2. 让小程序项目按需读取本文件完成结构落地。

## 项目结构（MUST）
```text
<uni-app-project>/
|-- src/
|   |-- app/
|   |-- pages/             # 主包页面
|   |-- subpackages/       # 分包页面
|   |   `-- <pkg-name>/
|   |       `-- pages/
|   |-- components/
|   |-- services/          # uni.request 封装与 API 聚合
|   |-- stores/
|   |-- composables/
|   |-- platform/
|   |   `-- mp-weixin/     # 微信小程序能力封装
|   |-- utils/
|   |-- styles/
|   `-- types/
|-- pages.json
|-- manifest.json
|-- uni.scss
|-- tests/
`-- ...
```

## 结构约束（MUST）
1. 页面必须声明主包或分包归属，禁止新增页面不声明包边界。
2. 小程序平台 API 统一封装在 `platform/mp-weixin/*`，页面禁止直接写平台分支。
3. 低频页面优先进入 `subpackages/*`，避免主包膨胀。
4. 资源目录需可追踪体积来源，支持主包 `2MB` 约束治理。

## 检查要求
1. 检查方式：人工评审 + 构建体积检查。
2. 阻断级别：阻断合并。
