# rules/frontend/project-structure/wechat-h5.md

## 文档目标
1. 定义公众号 H5 目标端（uni-app）的目录结构与平台分层。
2. 让公众号 H5 项目按需读取本文件完成结构落地。

## 项目结构（MUST）
```text
<uni-app-project>/
|-- src/
|   |-- app/               # 启动与全局注入
|   |-- pages/
|   |-- scenes/            # 活动/专题页面
|   |-- components/
|   |-- services/          # uni.request 封装与 API 聚合
|   |-- stores/
|   |-- composables/
|   |-- platform/
|   |   `-- h5/
|   |       `-- wechat/    # JSSDK、授权、分享、支付适配
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
1. 微信能力（授权、分享、支付）必须放在 `platform/h5/wechat/*`，页面禁止直连 JSSDK。
2. 活动页与专题页统一放 `scenes/*`，禁止散落到常规 `pages/*`。
3. 与端相关的分支逻辑必须放在 `platform/*` 或 `services/*` 适配层。
4. 若同一应用还需小程序目标，可在同一项目补充小程序结构目录，但不得破坏 H5 目录边界。

## 检查要求
1. 检查方式：人工评审 + 目录扫描。
2. 阻断级别：阻断合并。
