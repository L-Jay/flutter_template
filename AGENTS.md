# AGENTS.md

面向 AI 编码助手（Claude Code / Cursor / Trae / Copilot / Windsurf 等）的规则文件。

## 强制规则（基于本框架开发业务代码时）

1. **初始化**：`main()` 中必须先 `await LJUtil.initInstance()`，否则 `LJUtil.preferences` 等为 null
2. **网络请求**：统一使用 `LJNetwork.post/get/put/delete`。异常与提示已在框架内部统一处理，业务层**不要再用 `try-catch` 包裹**。`await` 只代表成功路径：请求失败时 `await` 之后的代码不会执行，这是框架设计（不是 bug），用来保证代码只写成功分支；需要拿到错误时用 `failureCallback` 获取 `LJError`，全局提示由 `LJNetwork.handleAllFailureCallBack` 负责，不要重复弹
3. **路由跳转**：使用 `RouterManager.pushNamed/pop/replaceNamed/popUntil`，**禁止**直接使用 `Navigator.push`
4. **页面参数**：在 `initState` 的 `addPostFrameCallback` 中用 `context.argumentMap` / `context.argument` 获取，三种路由方案均支持；无 context 时可用 `RouterManager.argument` / `RouterManager.argumentMap`（动画转场期间可能参数错乱）；GoRouter 下不要拿全局 `RouterManager.context` 去调 `.argument` 扩展，会报错
5. **资源释放**：StatefulWidget 的 `dispose()` 必须释放自己创建的 controller、调用 `LJEventBus.off(eventName)` 取消订阅。GetX 页面级 Controller（`Get.lazyPut` 注册）已与路由绑定，页面 pop 后由 GetX 自动回收，**不要**再手动 `Get.delete` / `dispose`：重复 `Get.delete` 只会打日志，但手动 `dispose()` 两次会在 debug 下抛 `was used after being disposed`；Controller 内部自己创建的资源统一在 `onClose()` 释放
6. **页面结构**：有状态、有业务逻辑的页面统一使用 `GetView<XxxController>` + `XxxController extends GetxController` 结构（模板参考 `lib/copy_page.dart` / `lib/copy_controller.dart`）：页面只负责 UI 构建，状态、网络请求等逻辑放 Controller；`build()` 中 `Get.lazyPut(() => XxxController())` 注册（需要立即初始化的页面如 Splash 用 `Get.put`）；Controller 的资源释放放 `onClose()`。纯展示的简单页面（如 about、setting）保持现有 `StatelessWidget`/`StatefulWidget` 结构即可，**无需**建 Controller
7. **字体字重**：统一使用 `lib/utils/lj_define.dart` 中的 `ultralight/thin/light/regular/medium/semibold/bold` 常量（iOS 自动补偿），**禁止**直接写 `FontWeight.w400` 等裸值，也不要自行使用 x50 中间字重；引用这些常量的 `TextStyle`/`Text` **不能加 `const`**（平台判断是运行时逻辑）
8. **禁止事项**：不要在 `build()` 中发起网络请求；列表分页不要自己用 `setState` 维护 `list` / `page` / `hasMore` 等状态（即不要"手动模拟数据流"），直接用 `LJRefreshListView`，其内置的 `LJRefreshListViewController` 已负责分页、下拉刷新、上拉加载状态；不要重复造轮子，优先使用框架已有组件

## 组件优先级

| 场景       | 必须使用                                  | 禁止使用                 |
| ---------- | ----------------------------------------- | ------------------------ |
| 轮播图     | `LJSwiper`                                | 自行实现 PageView        |
| 网络图片   | `LJNetworkImage`                          | `Image.network`          |
| 验证码按钮 | `SendCodeButton`                          | 自行实现倒计时           |
| 底部安全区 | `BottomContainer`                         | 手动算 SafeArea          |
| 拖拽悬浮   | `LJDragContainer`                         | 自行实现 GestureDetector |
| 下拉刷新   | `LJRefreshListView` / `LJRefreshGridView` | 第三方 refresh           |
| 路由       | `RouterManager`                           | `Navigator` / `Get.to`   |
| 网络请求   | `LJNetwork`                               | 直接 `dio`               |
| 事件通信   | `LJEventBus`                              | 自行实现 Stream          |
| 字体字重   | `medium` / `regular` 等语义化字重常量     | `FontWeight.w400` 裸值   |
| 页面结构   | 有状态的页面用 `GetView` + `GetxController` | 简单展示页强行套 Controller |
| 颜色       | `context.colors.xxx`（ThemeExtension）    | `AppColor` / `Color(0x...)` 裸值 |
| 文案样式   | `AppTextStyle.xxx(color)`                 | 裸 `TextStyle`           |
| 卡片       | `AppCard`                                 | 手写 Container + BoxShadow |
| 按钮       | `AppButton`                               | 手写 TextButton/ElevatedButton |
| 空/加载态  | `PageStateView`                           | 各页面自行拼装占位       |
| 支付弹窗   | `PaySheet.show`（底部收银台）             | 自行拼装收银台/`showModalBottomSheet` |
| 分享弹窗   | `ShareSheet.show`（底部分享面板）         | 自行拼装分享面板/`showModalBottomSheet` |

## 命名规范

- 文件名小写下划线链接,类名驼峰命名
- 路由名以 `/` 开头，统一在 `lib/common/router.dart` 的 `Routers` 中声明为 `static String`（如 `/login`、`/order`），业务代码禁止硬编码路由字符串

## 目录职责

### 启动链路

`lib/main.dart` → `lib/bootstrap.dart` → `lib/app.dart`

- `lib/main.dart`：仅初始化绑定、原生闪屏、调用 `Bootstrap.setup()`，**不写业务逻辑**
- `lib/bootstrap.dart`：全局配置入口（第三方 SDK、`LJUtil.initInstance()`、网络签名/请求头/拦截器/全局错误提示、路由注册、`ConfigService`/`UserService`/`CartService`/`PushService` 注册、EasyLoading 样式）；mock 全部收口在 `lib/common/mock/mock_config.dart`，bootstrap 只调 `MockConfig.setup()`
- `lib/app.dart`：`GetMaterialApp` + 主题 + 全局下拉刷新配置

### lib 目录

| 路径 | 职责 |
| --- | --- |
| `lib/` | 根目录，新增功能模块在这个目录下，以功能命名，比如login、mine、home等 |
| `lib/common` | 公共目录，项目中共用的代码都放在这个目录下，并且在 `common.dart` 中添加export统一出口|
| `lib/common/common.dart` | 统一出口，页面只 `import '../common/common.dart'`，不逐个引包 |
| `lib/common/router.dart` | `Routers` 路由表（`pages` / 路由常量 / `verifyLoginPageList`） |
| `lib/common/api_url.dart` | 全部接口路径常量 `ApiUrl` |
| `lib/common/theme/` | 主题：`app_colors.dart`（`AppColors` ThemeExtension）、`app_text_style.dart`、`app_spacing.dart`、`app_theme.dart`，统一出口 `index.dart` |
| `lib/common/models/` | 共用数据模型（`BaseResponseModel`、`UserInfoInfoModel`、`ConfigData`、`Product`/`Sku`/`FeedItem` 等），统一出口 `index.dart` |
| `lib/common/services/` | 全局 `GetxService`：`UserService`（token/登录态/用户信息）、`ConfigService`（App 配置）、`CartService`（购物车）、`PushService`（推送占位），统一出口 `index.dart` |
| `lib/common/widgets/` | 全局共用 UI 组件，统一出口 `index.dart` |
| `lib/common/webview/` | `WebViewPage` 通用网页容器 |
| `lib/common/constants.dart` | 微信、支付宝、universal link 等第三方常量 |
| `lib/common/utils.dart` | 通用工具函数，后续需要添加共用函数在这个文件中补充 |
| `lib/generated/json/` | FlutterJsonBeanFactory插件生成的json 序列化生成代码，**禁止手改**，改模型后按option+j重新生成 |
| `lib/{home,category,content,message,mine,search,favorite,product,cart,order,detail}/` | 业务模块，页面 + Controller 同名成对放置 |
| `lib/copy_page.dart` / `lib/copy_controller.dart` | 页面模板样例，新建页面复制后重命名 |
| `lib/splash/` | 启动页（需立即初始化，用 `Get.put`） |
| `lib/bottom_navigation/` | 主框架 Tab 容器（`PageView` + 底部导航） |
| `assets/images/` | 图片资源；新增图片需在 `pubspec.yaml` 的 `assets` 中注册 |
| `assets/json/mock.json` | 静态接口 mock 数据，key 为接口 path、value 为完整响应体 |


## 新增页面流程

1. 在 `lib/<模块>/` 下新建 `<模块>_page.dart` + `<模块>_controller.dart`（结构参考 `lib/copy_page.dart` / `lib/copy_controller.dart`）
2. 在 `lib/common/router.dart` 的 `Routers` 中加 `static String xxx = '/xxx';` 并注册到 `pages`
3. 需要登录才能进入的页面追加到 `Routers.verifyLoginPageList`或者需要登录才能进入可以使用 `whitePageList` 白名单
4. 接口路径加到 `ApiUrl`，请求用 `LJNetwork`
5. 颜色一律走 `context.colors.xxx`（`AppColors` ThemeExtension），文本走 `AppTextStyle.xxx(color)`，按钮用 `AppButton`，卡片用 `AppCard`；**禁止**静态 `AppColor`、手写 `Color(0x...)`、裸 `TextStyle`
6. 文件夹内文件较多时，在本目录新增 `index.dart` 统一 export（`theme/`、`widgets/`、`models/`、`services/` 已内置），页面只 `import '../common/common.dart'`

## 其他约束

- 状态管理统一 GetX，**不要**引入 provider / riverpod / bloc 等其他方案
- 全局服务放 `lib/common/services/` 并用 `GetxService` + `Get.put` 在 `bootstrap.dart` 注册；页面级状态一律 `GetxController` + `Get.lazyPut`
- 弹窗用 `DialogUtil.normal/show/text/singleButton`（SmartDialog 体系），loading 和轻提示用 `EasyLoading`，**不要**自己 `showDialog` / `ScaffoldMessenger`（双击退出等少数场景除外）
- 平台判断用 `isIOS` / `isAndroid` / `kIsWeb`，**禁止**在业务代码里直接写 `Platform.isIOS` 等判断
- 新增接口 mock 只需要在 `assets/json/mock.json` 中声明（key = 接口 path，value = 完整响应体），`MockConfig.setup()` 会整体写入 `LJNetwork.mockMap`，之后按正常请求流程走，**不要**在业务代码里注册 mock；必须按入参返回的接口（验证码、分页/分类/订单列表、内容/商品详情等）在 `lib/common/mock/mock_config.dart` 内用 `_registerCallback` 注册回调生成数据；mock 延迟由 `MockConfig.delay` / `MockConfig.delays`（按 path 覆盖）控制
- 需要从底部全屏弹出的页面（如登录页）注册到 `RouterManager.fullscreenPageList`，路由层会自动使用 fullscreenDialog + Cupertino（底部滑入）转场
- 调试环境切换走 `bootstrap.dart` 里配置的 `LJDebugConfig`，不要散落在业务页面
- 主题只允许在 `lib/common/theme/app_colors.dart` 中出现 `Color(0x...)` 字面量；`ThemeData` 只在 `app_theme.dart` 构建，页面禁止自建主题
- 全局服务（`CartService` / `PushService` 等）在 `bootstrap.dart` 的 `_configServices` 中 `Get.put` 注册
- 启动期静默接口（config、userInfo 这类）可以放在 `GetxService.onInit` 里，能最早发起请求；但首帧前**不要**调用 `EasyLoading.show/showError`（会触发 overlay 断言），统一用 `Bootstrap.loadingReady` 判断；接口请求不再全局弹 loading，加载状态由页面（`PageStateView` / 骨架屏 / 刷新控件）表达
- token 过期统一由 `LJNetwork.handleAllFailureCallBack` 判断 `200112` 后调用 `UserService.refreshToken()`：内部做了并发去重，刷新失败自动 `logout()`；业务页不要各写一套刷新逻辑
- 构建产物与平台工程目录（`build/`、`android/`、`ios/`、`web/`、`macos/`、`windows/`、`linux/`、`.dart_tool/`）不要手改；确需改原生配置时需说明原因
- 新增依赖前先确认 `lj_flutter_package` 是否已有对应能力，避免重复引入第三方库
- 提交前保持 `analysis_options.yaml` 现有 lint 规则，不要为了过检查而批量加 `// ignore`

