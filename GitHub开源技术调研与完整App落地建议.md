# AI 导购 App：GitHub 开源技术调研与完整落地建议

> 版本：V1.0
> 调研日期：2026.05
> 关联文档：《AI 智能导购 App 产品需求文档》V1.0、《AI 导购 App 技术落地系分文档》V1.1
> 核验方式：GitHub 公开仓库、仓库元数据、README 与许可证原文
> 重要说明：Star、最近推送时间和许可证快照仅用于初筛，不代表效果、安全性或生产可用性。本文尚未在本地 GPU 上运行这些模型，所有“候选”均需经过第 6 章 PoC 和法务复核后才能进入生产依赖。

---

## 1. 结论先行

### 1.1 是否有一套可直接借鉴的完整开源 App

**没有找到可以同时满足以下条件的成熟开源项目：**

- 完整覆盖数字衣橱、风格画像、场景推荐、数字分身、任意服装 3D 试穿、跨平台比价和 CPS。
- 具备生产级双端体验、隐私删除、订阅权益、异步 GPU 调度和运营后台。
- 代码、模型权重、人体资产和训练数据均明确允许商业使用。

GitHub 上接近的完整 App 多为个人项目或 Demo，适合参考页面、数据结构和安全设计，不适合作为生产底座。最可行的路线是：

```text
业务系统自主研发
+ 成熟基础设施复用
+ 可商用模型/供应商完成 2D 试穿
+ 研究型 VTON 仅做内部对照实验
+ 重点商品使用人工制作或品牌提供的 3D 资产
+ 商业人体模型授权或商业分身服务
```

### 1.2 对原技术路线的调整

1. **MVP 主线不变**：衣橱录入、风格画像和穿搭推荐优先，不等待 3D 技术成熟。
2. **试穿采用双轨制**：普通商品走 2D 图像试穿；有合格 GLB 资产的重点商品走真正可旋转的 3D 查看。
3. **不再把“IDM-VTON 直接部署商用”作为默认方案**：其代码与权重是 CC BY-NC-SA 4.0，只能用于非商业研究，除非另获商业授权。
4. **数字分身先走“可校准参数化分身”**：人体重建作为增强能力；SMPL-X 商业授权未解决前，不把相关资产接入商业服务。
5. **完整 App 仍按阶段交付**：“完整”指所有模块最终形成闭环，不代表第一版同时上线所有高风险能力。

### 1.3 最终建议的组合

| 能力 | 首选路线 | 备选/研究路线 |
|---|---|---|
| App | Flutter + 原生插件 | OOTDify 仅参考 Expo 功能划分，不切换主栈 |
| 衣橱 OCR | PaddleOCR 私有化 + 多模态模型结构化 | 合规云 OCR |
| 背景去除/分割 | rembg 基线，SAM 2 辅助复杂图片 | 自训服装检测/分割模型 |
| 衣物属性 | 多模态模型 + 受控标签 + 置信度 | 自训分类模型降低长期成本 |
| 穿搭推荐 | 自研规则、候选生成、排序和解释 | LightFM/其他 LTR 在数据充足后接入 |
| 2D 试穿 | 商业 API 或许可明确的 Qwen-Image-Edit 候选路线 | IDM-VTON/OOTDiffusion/CatVTON 仅研究对照 |
| 数字分身 | 商业授权人体模型/供应商 + 用户校准 | ROMP 等做内部重建算法验证 |
| 3D 查看 | Three.js；简单 GLB 场景可先用 model-viewer | 原生 Filament/SceneKit，性能不达标时替换 |
| 3D 服装 | 品牌资产、人工建模、重点 SKU 制作 | InstantMesh 等只研究生成粗模，不承诺布料仿真 |
| 向量检索 | PostgreSQL + pgvector | 商品规模达到独立检索门槛后再引入专用搜索引擎 |
| 模型网关 | LiteLLM 社区部分或自研轻量适配层 | 商业模型网关 |
| 工作流实验 | ComfyUI 做内部模型编排和效果对比 | 生产使用固定、版本化 Python 推理服务 |

---

## 2. 完整 App 类项目评估

| 项目 | 调研快照 | 可借鉴内容 | 不能作为生产底座的原因 | 结论 |
|---|---|---|---|---|
| [onetwothird/OOTDify](https://github.com/onetwothird/OOTDify) | Expo/React Native + Supabase + Flask；MIT；调研时约 1 Star | 衣橱、搭配、试穿五步流程、私有 Bucket、RLS、数据导出/删除、购物 Provider 注册接口 | README 明确真实 VTON 仍需配置，购物 Provider 尚未落地；新项目缺乏生产验证；Ultralytics 等依赖还需单独审查 | **重点参考架构和交互，不直接 Fork** |
| [muqrock/closet_mate](https://github.com/muqrock/closet_mate) | Flutter + Firebase + SQLite；约 2 Star；GitHub 元数据未识别许可证 | Flutter 衣橱列表、衣物编辑、本地 SQLite、搭配构建的基础思路 | 主要是手动录入和本地管理，无 AI、推荐、试穿和服务端闭环；无明确许可证时不能复制代码 | **仅参考功能，不复制代码** |
| [LeoLB-Wang/digital-wardrobe](https://github.com/LeoLB-Wang/digital-wardrobe) | React + Supabase + AI/Java 服务；约 1 Star | CPW（单次穿着成本）、衣物状态、衣橱统计、RLS 和工程脚本思路 | 新项目，非移动 App 主栈；README 与 API 的许可证识别结果不一致，需核验实际 LICENSE；客户端环境变量示例中含私钥/密钥名称，不能照搬配置方式 | **参考 CPW 和状态设计，不作为基座** |

### 可吸收到本产品的具体设计

- 从 OOTDify 吸收“私有存储 + 短时签名 URL + 服务端验证用户身份 + 真实失败状态”，以及购物平台适配器的接口思想。
- 从 Closet Mate 吸收 Flutter 本地衣橱草稿和搭配构建交互，但本地与服务端同步、冲突解决、AI 任务和隐私删除需重新设计。
- 从 digital-wardrobe 吸收 CPW 和衣物状态报表：CPW = 购买价格 / 有效实穿次数；价格未知时不展示伪精确数值。
- 不复制任何项目的密钥配置、匿名放通策略或“模型未配置但返回假结果”的实现。

---

## 3. 核心算法与基础组件评估

### 3.1 衣橱识别、OCR 与分割

| 项目 | 许可证快照 | 适用点 | 局限与集成方式 | 建议 |
|---|---|---|---|---|
| [PaddlePaddle/PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) | Apache-2.0 | 中文订单截图文字检测、识别、结构化预处理 | OCR 不负责理解商品；输出需经字段抽取、商品归一和敏感信息过滤 | **MVP 优先 PoC，可私有化部署** |
| [danielgatis/rembg](https://github.com/danielgatis/rembg) | MIT | 平铺衣物图背景去除、生成透明缩略图 | 对复杂褶皱、人体穿着、多件重叠不稳定；模型文件仍需核验 | **作为低成本基线** |
| [facebookresearch/sam2](https://github.com/facebookresearch/sam2) | Apache-2.0 | 用户点选/框选后的辅助分割、复杂衣物掩码 | 通用分割不等于服装属性识别；全自动分割仍需检测器提供提示 | **辅助工具，不单独承担识别** |
| [open-mmlab/mmdetection](https://github.com/open-mmlab/mmdetection) | Apache-2.0 | 后续自训衣物检测、实例分割 | 框架不是现成服装模型；仓库最近代码推送较早，需评估维护状态和数据许可 | **自训阶段候选，不是 MVP 必选项** |

**推荐流水线**

```text
图片质量检查 → rembg 快速路径 / 检测 + SAM 2 复杂路径
→ 多模态属性抽取 → 受控枚举和置信度校验 → 用户修正
```

订单截图则采用：

```text
PaddleOCR/云 OCR → 文本块布局还原 → 多模态或规则字段抽取
→ 商品标题、平台、购买时间、历史购买价 → 用户确认后批量入库
```

不要默认使用 Ultralytics YOLO 进入商业闭环；其代码和模型的具体许可证需单独评估，不能因示例项目常用就忽略。

### 3.2 虚拟试穿 VTON

| 项目 | 调研快照与许可证 | 技术价值 | 商业落地判断 |
|---|---|---|---|
| [yisol/IDM-VTON](https://github.com/yisol/IDM-VTON) | ECCV 2024；约 5.3k Star；README 明确代码和 checkpoint 均为 **CC BY-NC-SA 4.0** | SDXL + IP-Adapter，专用服装上身效果和预处理链路有研究价值 | **不得直接用于商业产品**；可用于内部对照实验，商用需另获授权并清理依赖许可 |
| [levihsu/OOTDiffusion](https://github.com/levihsu/OOTDiffusion) | 约 6.6k Star；LICENSE 为 **CC BY-NC-SA 4.0**；代码推送较早 | 上下装试穿、模型结构和权重可作研究基线 | **不得直接用于商业产品**；不作为生产主线 |
| [Zheng-Chong/CatVTON](https://github.com/Zheng-Chong/CatVTON) | ICLR 2025；约 1.8k Star；README 声明代码、权重、Demo 均为 **CC BY-NC-SA 4.0**；标称 1024×768 推理显存低于 8GB | 轻量、易做内部效果与成本对照 | **显存优势不改变非商业限制**；不能因部署简单而用于收费试穿 |
| [QwenLM/Qwen-Image](https://github.com/QwenLM/Qwen-Image) | 仓库与 README 声明 **Apache-2.0**；支持通用图像编辑、多图输入和身份一致性改进 | 可测试“人像 + 服装图”的通用编辑路线，许可路线比研究型 VTON 更友好 | **生产候选而非现成 VTON**；需逐版本核验权重许可证，并实测服装细节、身份保持、显存与时延 |

### VTON 落地建议

- 建立统一 `TryOnProvider` 接口，同时测试“合规商业 API”和“许可明确的自托管图像编辑模型”，避免绑定某一家。
- IDM-VTON、OOTDiffusion、CatVTON 可以形成内部质量上限参考，但不进入生产镜像、不处理真实用户照片、不与商业代码混发。
- Qwen-Image-Edit 是通用图像编辑模型，不天然保证 logo、花纹、版型、手部遮挡和人物身份不变；必须以专用评测集验证。
- 任何 2D 路线都只输出视觉效果图，不能据此生成“真实尺码合适”的结论。
- 模型 API 合同需明确商用权、数据地域、保留时间、是否训练、生成内容使用权和删除能力。

### 3.3 数字分身与 3D 重建

| 项目 | 许可证/能力 | 可借鉴点 | 关键缺口 | 结论 |
|---|---|---|---|---|
| [vchoutas/smplx](https://github.com/vchoutas/smplx) | 仓库 LICENSE 明确为非商业科研等用途；提供商业授权联系渠道 | 参数化人体、姿态和体型校准的事实标准之一 | 网格、blend weights、blend shapes、纹理和软件均在许可范围内；不能直接商用 | **先购买/取得商业授权，否则不接入生产** |
| [Arthur151/ROMP](https://github.com/Arthur151/ROMP) | 代码 Apache-2.0；单目人体网格恢复，可导出 GLB/FBX/BVH | 单张照片人体姿态和网格估计、分身初始化 | 依赖的 SMPL 资产、训练数据和第三方组件另行授权；单目估计不等于精确三围 | **算法 PoC，许可与测量误差双重门槛** |
| [TencentARC/InstantMesh](https://github.com/TencentARC/InstantMesh) | 仓库代码 Apache-2.0；单图生成稀疏视角与 Mesh | 研究商品图生成粗 3D 模型、快速预览 | 输出不是带版型、尺码、骨骼、碰撞和面料参数的服装资产；背面为生成结果 | **只做预研，不承担任意服装生产 3D 试穿** |
| [weihaox/awesome-digital-human](https://github.com/weihaox/awesome-digital-human) | 数字人论文与项目索引 | 持续跟踪人体、穿衣人体和 Avatar 新方案 | 索引本身不解决效果和授权 | **技术雷达，不直接集成** |

**重要判断**：ROMP + SMPL-X + InstantMesh 简单串联，不会自动得到高保真商业试衣间。还缺少服装拓扑修复、UV、骨骼绑定、人体服装碰撞、布料仿真、尺码映射、背面纹理和多视角一致性等关键工程。

因此完整 App 的 V1 应采用：

- 所有用户：可校准的基础分身 + 2D 试穿。
- 有合格数据的用户：商业授权的人体重建增强。
- 重点 SKU：人工或品牌提供的 3D 服装资产 + 3D 查看器。
- 普通 SKU：不展示虚假的“360° 已支持”，只展示已生成的视角。

### 3.4 3D 客户端与资产处理

| 项目 | 许可证快照 | 用途 | 建议 |
|---|---|---|---|
| [mrdoob/three.js](https://github.com/mrdoob/three.js) | MIT | GLB 加载、灯光、相机、手势、服装分层和动画 | **3D 主渲染候选**，通过受控 WebView 桥接入 Flutter |
| [google/model-viewer](https://github.com/google/model-viewer) | Apache-2.0 | 快速实现 GLB 展示、旋转、缩放和 AR 能力验证 | **简单查看器优先 PoC**；复杂分层和姿态需求再使用 Three.js 定制 |
| [KhronosGroup/glTF-Transform](https://github.com/KhronosGroup/glTF-Transform) | glTF 资产处理工具链 | Meshopt/Draco 压缩、纹理和模型检查、批量优化 | **进入 3D 资产 CI**，具体版本许可证随依赖锁定归档 |

3D 资产上传必须经过自动检查：三角面数、纹理尺寸、骨骼、材质、文件体积、恶意内容和恶意脚本。GLB 是模型数据，不允许夹带可执行 Web 内容；WebView 仅加载本地受控页面和白名单桥方法。

### 3.5 推荐、向量与模型服务

| 项目 | 许可证快照 | 可复用价值 | 在本产品中的位置 |
|---|---|---|---|
| [pgvector/pgvector](https://github.com/pgvector/pgvector) | PostgreSQL License | 在 PostgreSQL 内做向量检索，减少早期组件 | **MVP 采用**；查询仍需业务层强制用户隔离 |
| [lyst/lightfm](https://github.com/lyst/lightfm) | Apache-2.0 | 融合用户、物品特征的混合协同过滤 | **数据充足后实验**；不适合无行为数据的首日冷启动 |
| [recommenders-team/recommenders](https://github.com/recommenders-team/recommenders) | MIT | 推荐算法、训练和评估示例 | **算法参考库**，不是推荐在线服务 |
| [BerriAI/litellm](https://github.com/BerriAI/litellm) | 根 LICENSE：enterprise 目录外为 MIT，企业目录单独许可 | 多模型统一调用、成本、限流和故障处理 | **可选模型网关**，只使用许可明确的社区部分并审计日志脱敏 |
| [vllm-project/vllm](https://github.com/vllm-project/vllm) | Apache-2.0 | 自托管 LLM 高吞吐推理 | **规模化后可选**；MVP 不自建通用大模型集群 |
| [Comfy-Org/ComfyUI](https://github.com/Comfy-Org/ComfyUI) | GitHub 元数据为 GPL-3.0 | 快速搭建和比较扩散模型工作流 | **内部算法实验台**；生产集成与分发方式须法务评审，节点和模型许可分别核验 |

推荐系统不应第一天就引入 LightFM。先在埋点中积累有效曝光、替换、采纳、实穿和负反馈，达到可评估的数据量后再对比：

```text
规则排序基线 vs LightFM vs Learning-to-Rank
```

所有模型共享同一套硬约束、多样性重排和解释事实校验，避免算法升级破坏“只推真实可穿衣物”。

---

## 4. 完整 App 的目标技术栈

| 层级 | 建议选型 | 自研内容 | 复用/采购内容 |
|---|---|---|---|
| 移动 App | Flutter、Riverpod、Drift/SQLite、Dio、原生相机/分享/IAP 插件 | 页面、离线草稿、任务状态、同步、权益展示、隐私中心 | Flutter 与官方插件 |
| 管理后台 | React + TypeScript + 成熟中后台组件库 | 衣物/任务/模型/商品/订单/授权审计后台 | 组件库与图表库 |
| 业务 API | Kotlin + Spring Boot 模块化单体 | 账号、授权、衣橱、画像、推荐、试穿、商品、权益 | Spring 生态 |
| AI 服务 | Python + FastAPI + PyTorch/Diffusers | 统一 Schema、预处理、模型适配、质量校验、成本台账 | PaddleOCR、SAM 2、候选模型 |
| 异步任务 | RabbitMQ + Worker + Outbox | 幂等、重试、取消、额度结算、死信处理 | 托管消息队列 |
| 主数据 | PostgreSQL + pgvector | 数据模型、租户隔离、迁移和删除编排 | 托管 PostgreSQL |
| 缓存 | Redis | 天气、任务、推荐、限流和短期状态缓存 | 托管 Redis |
| 文件 | S3/OSS 私有 Bucket + CDN 受控分发 | 加密、签名 URL、生命周期和删除 | 云对象存储、KMS |
| 3D | Three.js/model-viewer + GLB + glTF Transform | Flutter 桥、服装分层、手势、性能分级 | 渲染和资产优化组件 |
| 模型接入 | LiteLLM/自研适配层 + 合规模型供应商 | 路由、Schema、审计、成本、灰度、隐私策略 | 商业模型 API |
| 观测 | OpenTelemetry + 指标/日志/链路平台 | AI 质量成本看板、业务漏斗、告警 | 云监控或开源可观测组件 |
| 电商平台 | 官方联盟 API + 独立 Adapter | 商品归一、同款、报价、历史价格、CPS 对账 | 淘宝联盟、京东联盟、多多进宝等 |

### 明确不引入的内容

- 不用 Supabase/Firebase 示例替换现有业务后端，只参考 RLS、私有存储和离线体验。
- 不在 MVP 自建 vLLM 集群、Milvus 集群或完整 Kubernetes 平台。
- 不把 ComfyUI 的 Web 页面暴露给用户，也不让客户端直接提交任意工作流 JSON。
- 不用通用爬虫框架替代淘宝/京东等官方商品和 CPS 接口。
- 不在商业版本中打包 NC（非商业）模型、权重或人体资产。

---

## 5. 推荐工程结构与模块交付边界

```text
aishop/
├── apps/
│   ├── mobile/                 # Flutter iOS/Android
│   └── admin/                  # 运营管理后台
├── services/
│   ├── api/                    # Kotlin/Spring Boot 模块化单体
│   └── ai/                     # FastAPI、模型适配、同步轻量推理
├── workers/
│   ├── recognition/            # OCR、分割、属性抽取
│   ├── tryon/                  # GPU 试穿 Worker
│   └── avatar/                 # 分身与 3D 资产 Worker
├── packages/
│   ├── contracts/              # API、事件和 JSON Schema
│   ├── viewer/                 # Three.js/model-viewer 受控页面
│   └── taxonomy/               # 品类、颜色、风格、场景受控词表
├── ml/
│   ├── evaluation/             # 冻结测试集、盲评和指标
│   └── experiments/            # 与生产隔离的研究型 VTON 实验
├── infra/                      # 环境、部署、监控和备份
└── docs/                       # PRD、系分、ADR、许可证与数据流
```

### 各模块最终交付物

| 模块 | 必须交付的可运行能力 |
|---|---|
| 账号与隐私 | 登录、分项目授权、撤回、数据导出、账号注销、删除进度 |
| 衣橱 | 拍照/截图/链接解析、离线草稿、识别、编辑、去重、状态、搜索 |
| 风格画像 | 入驻问卷、预览/完整画像、证据、周更新、报告分享 |
| 穿搭 | 天气/场景、3 套搭配、单品替换、理由、实穿日历、反馈 |
| 试穿 | 2D 任务、结果对比、内容标识、额度、失败返还、分享 |
| 分身与 3D | 分身创建/校准/删除、合格 GLB 商品 3D 查看、性能分级 |
| AI 买手 | 分享解析、搭配潜力、同款/相似款、报价快照、购买/劝退 |
| 商业化 | Pro 订阅、恢复购买、退款状态、CPS 点击和订单对账 |
| 运营后台 | 模型灰度、任务重试、数据质量、价格时效、投诉与审计 |
| 平台工程 | CI/CD、监控告警、备份恢复、成本看板、许可证清单 |

---

## 6. 开发前必须完成的六个 PoC

### PoC-01：衣物识别与截图导入

- 样本：覆盖上装、下装、裙装、鞋包，包含平铺、悬挂、折叠、复杂背景、遮挡和不同光源；订单截图覆盖目标平台不同版本。
- 对照：多模态直出、PaddleOCR + LLM、合规云 OCR + LLM。
- 指标：品类 Top-1、颜色准确率、字段空值率、字段修正率、截图商品行召回、P50/P95、单张成本。
- 出口：确定主模型、备用模型和人工修正阈值；不能只挑效果最好看的样例。

### PoC-02：2D 试穿商业候选

- 对照：至少一个商业 API、一个许可明确的自托管候选；研究环境可加入 IDM-VTON/CatVTON 作为非商业质量参照。
- 样本：不同体型、肤色、姿态，上装/下装/连衣裙，纯色/花纹/logo，平铺图/模特图。
- 指标：人物身份保持、服装细节保持、整体自然度、失败率、P95 时延、显存、单张成本。
- 出口：若服装细节或身份保持未达阈值，则只上线“AI 造型效果预览”实验，不作为购买决策的强保证。

### PoC-03：数字分身授权与效果

- 两条路线：可校准参数化基础分身；ROMP/其他重建算法 + 合法人体资产。
- 指标：生成成功率、“像我”盲评、不同人群分组误差、校准耗时、模型大小、删除完整性。
- 出口：商业授权未解决时只使用自研或已授权资产；不把 ROMP 的 Apache-2.0 误当成全链路商业许可。

### PoC-04：3D 资产与移动端帧率

- 使用 10～20 个真实制作的 GLB 分身/服装资产，不用 2D 图片冒充 3D。
- 对照 model-viewer 与 Three.js，测试 iOS/Android 中端机。
- 指标：首载时间、P95 帧率、内存、发热、连续旋转稳定性、模型下载体积。
- 出口：确定纹理/面数预算和降级机型；3D 效果不达标不影响 2D 主链路。

### PoC-05：推荐规则基线

- 建立受控搭配模板、天气规则、场景规则、色彩兼容和重复惩罚。
- 用人工搭配集比较“纯 LLM 搭配”和“约束 + 候选 + 排序”。
- 指标：硬约束违规率、人工偏好、3 套多样性、理由事实一致率、P95 时延。
- 出口：规则基线稳定后才接入协同过滤或 LTR。

### PoC-06：电商官方接口

- 分别验证商品详情、价格、库存、图片、转链、订单回调、频控和字段权限。
- 出口：形成平台能力矩阵。没有历史价格的商品显示“暂无历史”，没有实时库存权限的平台不承诺实时库存。

---

## 7. 完整 App 分阶段开发计划

### 第 1～2 周：基础与技术验证

- 建立 Monorepo、CI、受控词表、API Schema、测试数据和模型许可证台账。
- 启动 PoC-01、PoC-02、PoC-03、PoC-06，3D 和推荐并行预研。
- 确定云厂商、数据地域、模型供应商、隐私数据流和首发平台能力。

### 第 3～6 周：衣橱和账号闭环

- Flutter 登录、入驻、相机、离线草稿、衣橱列表和编辑。
- 上传、私有存储、OCR/识别任务、去重、状态和批量截图导入。
- 授权中心、数据删除、基础后台、事件埋点和成本台账。

### 第 7～10 周：画像和穿搭闭环

- 问卷、5 件风格预览、20 件完整画像、衣橱结构报告。
- 天气、场景、3 套推荐、单品替换、理由、穿搭日历和反馈。
- 2D 试穿 Provider 接入小流量实验，不阻塞推荐主线。

### 第 11～12 周：MVP 发布

- 全链路测试、模型冻结评估、性能压测、隐私删除演练和故障降级。
- 种子用户灰度、指标看板、崩溃修复、回滚预案。
- 评审次周留存、衣橱激活、推荐采纳和录入修正率，决定下一阶段投入。

### 第 4～6 个月：V1 试穿和订阅

- 上线通过 PoC 的 2D 试穿、基础分身、Pro 订阅和额度体系。
- 对重点 SKU 提供合格 GLB 的 3D 查看；不等待“任意衣服自动 3D”才发布。
- 商业人体模型授权与重建增强按效果、授权和成本独立决策。

### 第 7～12 个月：V2 跨平台买手

- 至少两个官方平台跑通商品、转链和订单回调。
- 商品归一、同款/相似款、报价时效、价格历史、搭配缺口和购买/劝退。
- 上线推荐中立性审计、CPS 对账和平台故障降级。

---

## 8. 许可证与供应链准入门禁

### 8.1 每个 AI 项目必须分四层审查

1. **代码许可证**：能否修改、商用、分发和提供服务。
2. **模型权重许可证**：代码 Apache/MIT 不代表权重可商用。
3. **训练数据和人体资产**：DeepFashion、VITON-HD、DressCode、SMPL 等需逐项审查，不默认拥有商业训练权。
4. **生成结果与第三方依赖**：基础模型、LoRA、ComfyUI 节点、字体、纹理和输出条款分别记录。

### 8.2 当前明确的生产限制

- IDM-VTON、OOTDiffusion、CatVTON：**CC BY-NC-SA 4.0，未另获许可不得用于商业生产**。
- SMPL-X 仓库模型与软件：**默认非商业，商业使用需联系权利方取得授权**。
- 无 LICENSE 的 App 项目：默认可阅读学习，**不复制代码、图片或资产**。
- ComfyUI 及插件：GPL/各插件许可需审查；研究环境与生产环境隔离。
- Qwen-Image：仓库声明 Apache-2.0，但锁定具体模型版本时仍需归档对应权重模型卡、依赖和许可证快照。

### 8.3 工程控制

- 建立 `THIRD_PARTY_NOTICES`、SBOM、模型登记和许可证审批状态。
- 依赖状态分为 `APPROVED / RESEARCH_ONLY / BLOCKED / PENDING`；CI 阻止 `BLOCKED` 进入生产镜像。
- 研究模型使用独立仓库、独立测试数据和独立 GPU 环境，不上传真实用户照片。
- 每次升级都重新检查上游许可证、模型卡、依赖变更和供应商数据处理条款。

---

## 9. 最终落地建议

1. **完整 App 的主体必须自研**，核心资产是受控衣橱数据、穿搭决策、用户画像、商品关系和反馈闭环，而不是拼装 Demo。
2. **优先复用成熟通用组件**：PaddleOCR、rembg、SAM 2、pgvector、Three.js/model-viewer、LiteLLM 等能减少基础设施工作量。
3. **2D 试穿采用商业 API 与自托管候选双 Provider**，先解决商业许可，再比较效果和成本。
4. **3D 不追求“单图自动生成所有衣服”作为首发前提**，用重点 SKU 合格资产先交付真正的旋转体验。
5. **数字分身先校准、后重建**，人体资产商业授权与算法效果同等重要。
6. **开源 App 只借鉴，不 Fork 当底座**；特别是 OOTDify 的私有存储、Provider 和诚实失败状态值得吸收。
7. **立即进入六个 PoC 和 MVP 开发**，而不是继续无限扩大仓库调研。新模型通过 Awesome Try-On/数字人索引进入技术雷达，按同一评测集定期复测即可。

---

## 10. 主要来源

- [IDM-VTON 官方仓库与许可证说明](https://github.com/yisol/IDM-VTON)
- [OOTDiffusion 官方仓库](https://github.com/levihsu/OOTDiffusion)
- [CatVTON 官方仓库与许可证说明](https://github.com/Zheng-Chong/CatVTON)
- [Qwen-Image 官方仓库](https://github.com/QwenLM/Qwen-Image)
- [SMPL-X 官方仓库与非商业许可证](https://github.com/vchoutas/smplx/blob/main/LICENSE)
- [ROMP 官方仓库](https://github.com/Arthur151/ROMP)
- [InstantMesh 官方仓库](https://github.com/TencentARC/InstantMesh)
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR)、[SAM 2](https://github.com/facebookresearch/sam2)、[rembg](https://github.com/danielgatis/rembg)
- [Three.js](https://github.com/mrdoob/three.js)、[model-viewer](https://github.com/google/model-viewer)、[glTF Transform](https://github.com/KhronosGroup/glTF-Transform)
- [pgvector](https://github.com/pgvector/pgvector)、[LightFM](https://github.com/lyst/lightfm)、[Recommenders](https://github.com/recommenders-team/recommenders)
- [LiteLLM](https://github.com/BerriAI/litellm)、[vLLM](https://github.com/vllm-project/vllm)、[ComfyUI](https://github.com/Comfy-Org/ComfyUI)
- [OOTDify](https://github.com/onetwothird/OOTDify)、[Closet Mate](https://github.com/muqrock/closet_mate)、[digital-wardrobe](https://github.com/LeoLB-Wang/digital-wardrobe)
