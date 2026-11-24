# flutter_template

基于 Flutter + GetX 的 App 快速开发模板。提供登录、首页、列表/详情、购物车、订单、收藏、消息、搜索、个人中心、设置等通用能力，示例业务按电商与内容信息流组织，可直接裁剪为任意类型的 App。已接入深色模式、中英双语、Mock 数据与统一组件库 `lj_flutter_package`。

## 从模板创建新项目与配置

### 创建工程

```bash
./tool/create_app.sh my_app com.company "我的应用" --yes
```

脚本会保留 `lib`、`assets`、`l10n` 与测试代码，用 `flutter create` 按目标 `org` + 工程名重建 `android/ios` 原生壳，再回填权限、JPush 占位、iOS 权限文案、Podfile 宏，并同步修改 `pubspec` 包名、`package:flutter_template` 引用与第三方常量。

创建时也可以直接带上配置（与 `set` 等价，均可省略）：

```bash
tool/app.sh create my_app com.company "我的应用" \
  --push-key <jpush-key> \
  --wechat-appid wx1234567890 \
  --universal-link https://example.com/app/ \
  --alipay-appid 2021000000000000 \
  --real-third-party on --yes
```

### 后续单独配置

`set` 会同时修改 Dart 常量与原生工程，可重复执行：

```bash
tool/app.sh set display-name "我的应用"          # Android label + iOS 显示名
tool/app.sh set push <jpush-key>                # constants.dart + build.gradle.kts（也可写 set push jpush <key>）
tool/app.sh set wechat <appid> [universal-link] # constants.dart + iOS URL Scheme
tool/app.sh set alipay <appid>                  # constants.dart
tool/app.sh set real-third-party on|off         # 是否启用真实微信/支付宝
```

### 配置检查

```bash
tool/app.sh check
```

校验两端是否一致：极光 AppKey、微信 AppID 与 URL Scheme、真实模式依赖项、iOS 权限文案、Android 权限、是否残留 `dependency_overrides`。

- 执行 `create` 前请提交或备份，脚本会删除并重建平台目录
- 完成后目录会重命名为 `app_name`（如需保留原目录名，加 `--keep-dir`）；脚本无法切换父 shell，按输出提示 `cd` 进入新目录即可
- 完整参数见 `./tool/app.sh --help`
- iOS Push Notifications 能力、APNs、开放平台包名登记仍需在原生/后台完成

## 功能清单

| 模块 | 能力 |
| --- | --- |
| 启动 | 原生闪屏 + Splash 页、App 配置与用户信息预拉取、维护模式判断 |
| 登录 | 手机号 + 验证码登录（Mock 验证码）、微信一键登录、协议勾选、登录态/token 刷新 |
| 首页 | 轮播 `LJSwiper`、8 宫格金刚区、内容流分页（`LJRefreshListView`） |
| 分类 | 左侧一级分类（中英名称）+ 右侧商品列表 |
| 搜索 | 关键词搜索、搜索历史、金刚区带词直达 |
| 商品 | 商品详情、规格选择、加购、立即购买 |
| 购物车 | 增删改选、全选、结算 |
| 订单 | 订单列表（状态 Tab）、确认下单、模拟支付收银台 |
| 内容 | 内容流、内容详情、评论列表 |
| 消息 | 消息列表、已读标记 |
| 优惠券 | 券列表、状态区分、去使用 |
| 活动 | 活动列表、状态角标 |
| 会员 | 会员卡、成长值/积分、权益宫格、开通（模拟支付） |
| 直播 | 直播间列表、直播中状态、人气 |
| 我的 | 头像/昵称/手机号编辑、微信绑定、订单入口、设置 |
| 设置 | 主题切换（浅色/深色/跟随系统）、语言切换（中/英/跟随系统）、缓存清理、协议/隐私 WebView、版本信息 |
| 收藏 | 收藏列表、管理模式批量删除 |
| 推送 | 极光 JPush：初始化、别名绑定/解绑、通知点击跳转（AppKey 留空自动跳过） |
| 通用 | 路由守卫（登录校验）、统一空/加载/错误态、下拉刷新、分享面板、WebView 容器 |

## 技术栈

- Flutter（Dart SDK `^3.11.5`）+ GetX（状态管理、路由、依赖注入）
- `lj_flutter_package`：`LJNetwork`、`RouterManager`、`LJRefreshListView`、`LJSwiper`、`SendCodeButton`、`AvatarWidget`、iOS 字重补偿等
- `flutter_smart_dialog`（弹窗）、`flutter_easyloading`（Toast/Loading）、`pull_to_refresh`
- `flutter_localizations` + gen-l10n（中英双语）
- `fluwx` / `tobias`（微信、支付宝，已封装为 `lj_flutter_package` 的 `WechatUtil` / `AlipayUtil`）
- `jpush_flutter`（极光推送）

## 快速开始

```bash
flutter pub get
flutter run
```

- 默认在 debug 下启用 Mock，所有接口走本地模拟；release 构建会自动跳过 Mock
- 首页金刚区、商品、内容等数据存放在 `assets/json/mock.json`，修改后需重新运行（资源文件热重载不生效）
- 登录：输入任意 11 位手机号，点击发送验证码，Mock 会随机生成 6 位验证码并通过 Toast 提示，填入即可登录
- 推送默认关闭（`JPUSH_APP_KEY` 为空），填入极光 AppKey 后自动初始化，见下方「第三方能力」

## 第三方能力

### 推送（极光 JPush）

1. 在极光后台创建应用，拿到 AppKey 后填入 `lib/common/constants.dart` 的 `JPUSH_APP_KEY`
2. Android：`android/app/build.gradle.kts` 中已预留 `JPUSH_APPKEY` 占位，替换为同一个 key
3. iOS：在 Xcode 中为 Runner 开启 Push Notifications 能力，并在极光后台配置 APNs 证书或 Token
4. 服务端可按别名推送：登录成功后 `PushService` 会自动 `setAlias(uid)`，退出登录时 `deleteAlias()`
5. 点击通知默认进入消息列表，可按 `message['extras']` 在 `PushService._onOpenNotification` 中自定义跳转

国内 Android 建议在极光后台同时配置华为/小米/OPPO/vivo 等厂商通道，提升离线到达率。

推送层已抽象为 `PushProvider`（`lib/common/services/push_provider.dart`），默认实现是 `JPushProvider`。换厂商时新增实现并修改 `PushService.createProvider()` 即可，业务层的 `bindAlias` / `unbindAlias` 与通知跳转无需改动。

### 微信 / 支付宝

- 微信登录/绑定：默认走 Mock 接口；`ENABLE_REAL_THIRD_PARTY = true` 后调用 `WechatUtil.login()` 获取授权 code，再由后端换取 token / 完成绑定
- 分享：微信、朋友圈在 `ENABLE_REAL_THIRD_PARTY = true` 时调用 `WechatUtil.shareWeb`，未开启或未安装微信时回退 Mock 提示
- 支付：`PaySheet.show(amount, wechat: WechatPayParams(...), alipayOrder: '...')`，参数齐全且开关打开时走真实 SDK，否则模拟支付

## 目录结构

```text
lib/
├── main.dart                 # 入口：绑定初始化、原生闪屏、Bootstrap.setup
├── bootstrap.dart            # 全局配置：SDK、网络、路由、服务、Mock、EasyLoading
├── app.dart                  # GetMaterialApp：主题、语言、全局刷新配置
├── splash/                   # 启动页
├── bottom_navigation/        # 主框架（首页/商品/内容/我的）
├── home/                     # 首页（轮播、金刚区、内容流）
├── category/                 # 分类页
├── content/                  # 内容列表/详情/评论
├── product/                  # 商品详情
├── cart/                     # 购物车
├── order/                    # 订单列表、确认下单
├── favorite/                 # 收藏
├── message/                  # 消息
├── search/                   # 搜索
├── mine/                     # 我的、资料、设置、关于
├── login/                    # 登录
├── coupon/ activity/ vip/ live/  # 营销模块
├── detail/                   # 通用详情占位页
├── common/
│   ├── common.dart           # 统一出口（页面只 import 这一个）
│   ├── l10n_ext.dart         # context.l10n / Get.l10n
│   ├── router.dart           # 路由表 Routers
│   ├── api_url.dart          # 接口路径常量
│   ├── theme/                # AppColors、AppTextStyle、AppSpacing、AppTheme
│   ├── models/               # 共用数据模型
│   ├── services/             # 全局 GetxService
│   ├── widgets/              # AppButton/AppCard/PageStateView/DialogUtil 等
│   ├── mock/mock_config.dart # Mock 注册（静态 JSON + 动态回调）
│   └── webview/              # 通用 WebView 容器
├── l10n/                     # ARB 与 gen-l10n 产物
└── generated/json/           # JsonBeanFactory 生成代码（勿手改）
```

## 架构说明

### 启动链路

`main.dart` → `bootstrap.dart` → `app.dart`

- `main.dart`：仅初始化绑定、原生闪屏、调用 `Bootstrap.setup()`
- `bootstrap.dart`：`LJUtil.initInstance()`、网络签名/请求头/拦截器/全局错误处理、路由注册、服务注册、`MockConfig.setup()`、EasyLoading 样式
- `app.dart`：根节点 `Obx` 监听主题与语言，`GetMaterialApp` 内配置全局下拉刷新文案

### 状态管理

- 全局服务：`lib/common/services/` 下的 `GetxService`，在 `bootstrap.dart` 中 `Get.put` 注册
  - `UserService`：登录态、token、用户信息、token 刷新（并发去重）
  - `ConfigService`：App 配置
  - `CartService`：购物车
  - `ThemeService` / `LanguageService`：主题与语言（持久化）
  - `PushService`：极光 JPush 初始化、别名绑定/解绑、通知点击跳转（AppKey 为空时自动跳过）
- 页面状态：`GetView<XxxController>` + `GetxController`，`build()` 中 `Get.lazyPut`，资源在 `onClose()` 释放
- 约定：页面只负责 UI，Controller 只放状态与业务逻辑；Controller 中不要构建 Widget

### 路由

- 统一走 `RouterManager.pushNamed / pushPage / pop / replaceNamed`
- 路由常量集中在 `lib/common/router.dart` 的 `Routers`，禁止硬编码字符串
- 需登录页面注册在 `Routers.verifyLoginPageList`，由路由层统一拦截
- 参数在 `initState` 的 `addPostFrameCallback` 中用 `context.argumentMap` 获取；无 context 时用 `RouterManager.argument` / `RouterManager.argumentMap`

### 网络

- 统一 `LJNetwork.post/get/put/delete`，接口路径集中在 `ApiUrl`
- 业务层不写 `try-catch`：请求失败时 `await` 之后的成功分支不执行，错误由 `LJNetwork.handleAllFailureCallBack` 统一提示
- `200112`（token 过期）由全局处理调用 `UserService.refreshToken()`

### Mock

- 静态接口：在 `assets/json/mock.json` 中以 `path -> 完整响应体` 声明
- 动态接口（验证码、分页列表、详情等）：在 `lib/common/mock/mock_config.dart` 用 `_registerCallback` 注册
- 延迟通过 `MockConfig.delay` / `MockConfig.delays` 控制，仅 debug 生效

## 多语言

- ARB：`lib/l10n/app_zh.arb`（模板）、`lib/l10n/app_en.arb`
- 配置：`l10n.yaml`，输出 `AppLocalizations`（非空 getter）
- 新增文案：
  1. 两个 ARB 同时加 key（英文无需 `@` 元数据，中文模板需要）
  2. 执行 `flutter gen-l10n`
  3. 页面内 `context.l10n.xxx`，Controller 内 `Get.l10n.xxx`
- 语言选择持久化在 `LanguageService`，`null` 表示跟随系统；切换后通过 `Get.locale` + 根节点 `Obx` 即时生效
- 服务端数据（商品、内容、评论等）不进入 ARB

## 主题

- 只允许在 `lib/common/theme/app_colors.dart` 出现颜色字面量，页面统一 `context.colors.xxx`
- 文本样式统一 `AppTextStyle.xxx(color)`，字重用 `ultralight/thin/light/regular/medium/semibold/bold` 常量（iOS 自动补偿）
- `ThemeService` 维护 `ThemeMode` 并持久化，`app.dart` 通过 `Obx` 即时切换
- 主题默认给输入框开启了 `filled`，弹窗等需要透明输入框的场景请局部设置 `filled: false`

## 新增页面流程

1. 在 `lib/<模块>/` 下新建 `<模块>_page.dart` + `<模块>_controller.dart`（可参考 `lib/copy_page.dart`）
2. 在 `lib/common/router.dart` 的 `Routers` 中增加 `static String xxx = '/xxx';` 并注册到 `pages`
3. 需要登录的页面加入 `verifyLoginPageList`
4. 接口路径加到 `ApiUrl`，按需在 `mock.json` / `mock_config.dart` 补 Mock
5. UI 遵循组件规范：`AppButton`、`AppCard`、`PageStateView`、`LJRefreshListView`，颜色/文案走 `context.colors` 与 `context.l10n`

## 组件优先级（摘要）

| 场景 | 使用 | 禁止 |
| --- | --- | --- |
| 轮播 / 网络图 | `LJSwiper` / `LJNetworkImage` | 自实现 PageView / `Image.network` |
| 验证码 | `SendCodeButton` | 自实现倒计时 |
| 下拉刷新/分页 | `LJRefreshListView` / `LJRefreshGridView` | 手写分页状态 |
| 路由 / 网络 | `RouterManager` / `LJNetwork` | `Navigator` / 裸 `dio` |
| 弹窗 / 提示 | `DialogUtil` / `EasyLoading` | `showDialog` / `ScaffoldMessenger` |
| 按钮 / 卡片 / 状态 | `AppButton` / `AppCard` / `PageStateView` | 手写 Container、占位 |
| 颜色 / 文案 | `context.colors` / `context.l10n` | 颜色裸值 / 硬编码中文 |

完整约束见根目录 `AGENTS.md`。

## 已知限制与待完善

- 首页金刚区「更多」暂时进入通用详情占位页，后续可替换为分类聚合页
- 支付收银台（`PaySheet`）与分享面板（`ShareSheet`）默认走 Mock；配置好开放平台与后端下单参数、开启 `ENABLE_REAL_THIRD_PARTY` 后切换为真实微信/支付宝
- 微信登录/绑定默认 Mock；开启 `ENABLE_REAL_THIRD_PARTY` 并配置好微信开放平台后走真实 SDK。推送需填入极光 AppKey 并配置 iOS 推送能力
- 业务数据（商品、内容、订单、消息等）为中文 Mock，未做多语言，真实项目中由服务端下发
- 暂无单元测试与 Widget 测试
- `fluwx` / `tobias` 暂不支持 Swift Package Manager，iOS 构建会出现提示；`WechatOpenSDK-XCFramework` 暂不支持 arm64 模拟器，真机不受影响
