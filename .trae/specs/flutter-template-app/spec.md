# Flutter 快速开发模板 — 实施规格

## 1. 目标

把当前 `flutter_template` 从「仅登录/我的两个 Tab 的空壳」升级为可直接复用的业务模板：

- 统一主题系统（ThemeExtension，上下文取色），为后续主题切换铺路
- 完整 P0 骨架：启动页、登录、4 Tab（首页 / 商品 / 内容 / 我的）、首页、通用详情、我的、设置（设置收在我的内，不占 Tab）
- P1 通用能力：搜索、收藏、分享、推送占位、WebView、权限封装
- P2 电商：商品 Tab 商品网格、商品详情 + SKU、购物车、确认订单、订单列表
- P2 内容：内容流卡片、内容详情（点赞/收藏）、评论列表

IAP 按此前决定延后，本轮不实现。

## 2. 已确认的设计约束

### 2.1 设计语言

- 浅色主题「澄蓝」：brand `#2F6BFF`、brandLight `#EAF1FF`、brandDark `#1F4FD8`
- 背景 `#F5F7FA`，卡片 `#FFFFFF`，分割线 `#EEF1F6`
- 文本三级：`#111827` / `#6B7280` / `#9CA3AF`
- 功能色：success `#12B76A`、warning `#F79009`、danger `#F04438`、price `#FF4D4F`
- 字号 24/20/17/15/13/11，行高 32/28/24/22/20/16
- 间距 4/8/12/16/24/32，页边距 16
- 圆角 8/12/16/999
- AppBar 高 44、标题居中、17 medium
- Tab 高 56
- 主按钮高 48、圆角 12
- 输入框高 48、无边框、浅底
- 卡片白底、圆角 12、内边距 16、阴影 `0 2 8 rgba(17,24,39,.04)`
- 暗色仅预留 token，本轮不接切换开关

### 2.2 主题架构（重点决策）

- **删除** `lib/common/app_colors.dart` 中的静态常量用法
- 新建 `lib/common/theme/app_colors.dart`：`AppColors extends ThemeExtension<AppColors>`
- 业务代码统一 `context.colors.xxx`（等价 `AppColors.of(context).xxx`），禁止硬编码 `Color(0x...)`
- `AppColors.of(context)` 找不到扩展时回退 `AppColors.light`，保证 SmartDialog overlay 等特殊 context 不崩
- 字体字重继续使用 `lj_define.dart` 的 `ultralight/thin/light/regular/medium/semibold/bold` 常量；所有引用处不加 `const`

### 2.3 框架规则（沿用 AGENTS.md）

- 网络：`LJNetwork`，业务层不写 try-catch（`failureCallback` 取错）
- 路由：`RouterManager`，路由名集中在 `Routers`
- 页面：`GetView<XxxController>` + `GetxController`，`build()` 里 `Get.lazyPut`
- 列表：分页状态交给 `LJRefreshListViewController`，不手写 `list/page/hasMore`
- 轮播：`LJSwiper`；网络图：`LJNetworkImage`；底部安全区：`BottomContainer`
- 弹窗：`DialogUtil` / `SmartDialog`；提示：`EasyLoading`
- 平台判断：`isIOS` / `isAndroid` / `kIsWeb`

### 2.4 一个重要实现偏差（需知悉）

`LJRefreshListView` 内部固定使用 `ListView.separated`，**不支持头部（轮播+宫格）与列表一起滚动**。
首页要求「轮播 + 宫格 + 卡片分页列表」同屏滚动，因此首页采用：

```
SmartRefresher + CustomScrollView
  ├─ SliverToBoxAdapter（轮播 + 宫格 + 分区标题）
  └─ SliverList（由 LJRefreshListViewController.list 驱动）
```

分页、下拉刷新、上拉加载状态仍由 `LJRefreshListViewController` 管理，不手写分页字段。
其余所有普通列表一律使用 `LJRefreshListView`。

## 3. 文件与函数级改动

### 3.1 主题基础设施（新建）

#### `lib/common/theme/app_colors.dart`

```dart
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brand, brandLight, brandDark;
  final Color bg, surface;
  final Color textPrimary, textSecondary, textHint;
  final Color divider;
  final Color success, warning, danger, price;
  final Color barrier;

  const AppColors({...});

  static const AppColors light = AppColors(...);
  static const AppColors dark = AppColors(...);

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({...});
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t);
}

extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
```

Light 值严格按 2.1；Dark：bg `#0E1116`、surface `#171B22`、textPrimary `#F5F7FA`、textSecondary `#A0A8B8`、textHint `#6B7280`、divider `#232A35`，其余同 Light。

#### `lib/common/theme/app_text_style.dart`

```dart
class AppTextStyle {
  static const double displaySize = 24;   // 行高 32
  static const double titleSize = 20;     // 28
  static const double headlineSize = 17;  // 24
  static const double bodySize = 15;      // 22
  static const double captionSize = 13;   // 20
  static const double smallSize = 11;     // 16

  static TextStyle display(Color color);   // semibold
  static TextStyle title(Color color);     // semibold
  static TextStyle headline(Color color);  // medium
  static TextStyle body(Color color);      // regular
  static TextStyle caption(Color color);   // regular
  static TextStyle small(Color color);     // regular
  static TextStyle button(Color color);    // 17 medium
}
```

所有方法内部 `TextStyle(fontSize: x, height: lineHeight / x, fontWeight: medium, color: color)`，禁止 `const`。

#### `lib/common/theme/app_spacing.dart`

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double page = 16;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;
}
```

#### `lib/common/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
  static ThemeData _build(AppColors colors, Brightness brightness);
}
```

`_build` 内容：

- `useMaterial3: true`，`extensions: [colors]`
- `colorScheme`：`ColorScheme.fromSeed(seedColor: colors.brand, brightness: brightness)` 后 `copyWith(primary: brand, surface: surface, error: danger)`
- `scaffoldBackgroundColor: colors.bg`
- `appBarTheme`：`toolbarHeight: 44`、`centerTitle: true`、`backgroundColor: colors.surface`、`foregroundColor: colors.textPrimary`、`elevation: 0`、`surfaceTintColor: Colors.transparent`、`titleTextStyle: AppTextStyle.headline(colors.textPrimary)`
- `dividerTheme`：color `colors.divider`，space 0，thickness 1
- `cardTheme`：color `colors.surface`，elevation 0，shape `RoundedRectangleBorder(borderRadius: 12)`，margin zero
- `filledButtonTheme` / `elevatedButtonTheme`：`minimumSize: Size.fromHeight(48)`、圆角 12、`textStyle: AppTextStyle.button(Colors.white)`
- `outlinedButtonTheme`：同高、圆角 12、边框 `colors.divider`、文本 `colors.textPrimary`
- `textButtonTheme`：文本 `colors.brand`
- `inputDecorationTheme`：`filled: true`、`fillColor: colors.divider`、`hintStyle: AppTextStyle.body(colors.textHint)`、`contentPadding: EdgeInsets.symmetric(horizontal: 16)`、所有 border 为 `InputBorder.none`、`isDense: true`，并设置 `constraints: BoxConstraints(minHeight: 48)`
- `splashColor: Colors.transparent`、`highlightColor: Colors.transparent`
- `pageTransitionsTheme`：保持默认

### 3.2 通用组件（新建）

#### `lib/common/widgets/app_button.dart`

```dart
enum AppButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.width = double.infinity,
    this.height = 48,
    this.loading = false,
    this.icon,
  });
}
```

- primary：brand 底、白字、圆角 12
- secondary：surface 底、divider 边框、textPrimary 字
- text：透明底、brand 字
- `loading == true` 时展示 18×18 `CircularProgressIndicator` 并禁止点击
- `onPressed == null` 时整体 40% 透明度

#### `lib/common/widgets/app_card.dart`

```dart
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });
}
```

- 白底、圆角 12、阴影 `BoxShadow(color: Color(0x0A111827), blurRadius: 8, offset: Offset(0, 2))`
- 有 `onTap` 时用 `InkWell` + `ClipRRect`，点击水波纹裁切在圆角内

#### `lib/common/widgets/page_state.dart`

```dart
enum PageStateType { loading, empty, error }

class PageStateView extends StatelessWidget {
  const PageStateView({super.key, this.type = PageStateType.loading, this.message = '', this.onRetry});
}
```

- loading：`CircularProgressIndicator` + 「加载中…」
- empty：`Icons.inbox_outlined` + 默认「暂无数据」
- error：`Icons.error_outline` + 默认「加载失败，请重试」+ `AppButton` 重试
- 颜色全部取 `context.colors`

#### `lib/common/widgets/skeleton.dart`

```dart
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width = double.infinity, required this.height, this.radius = 8});
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1.0, this.height = 12});
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 2, this.showImage = true});
}
```

- 通过 `AnimationController` 在 0.35~0.75 透明度间循环
- 基础色 `context.colors.divider`

#### `lib/common/widgets/feed_card.dart`

```dart
class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLike,
    this.showCover = true,
  });
}
```

- 首页与「内容」Tab 共用的内容卡片（作者行 + 正文 3 行 + 可选封面 + 点赞/评论）
- 颜色、字号全部走主题；不持有业务状态

#### `lib/common/webview/webview_page.dart`

```dart
class WebViewPage extends StatelessWidget {
  // 从 context.argumentMap 读取 url/title
}
```

- 使用包内 `LJWebViewPage`，`progressColor` / `backgroundColor` 取主题
- 无参数时展示 `PageStateView(type: empty, message: '缺少链接')`

#### `lib/common/utils/share_util.dart`

```dart
class ShareUtil {
  static Future<void> shareText({required String title, required String url});
}
```

- 本轮不引第三方：复制链接到剪贴板 + `EasyLoading.showSuccess('链接已复制')`
- 留 `TODO` 注释：接入微信/系统分享 SDK 时替换该方法

#### `lib/common/utils/permission_util.dart`

```dart
class PermissionUtil {
  static Future<bool> camera();
  static Future<bool> photos();
  static Future<bool> microphone();
  static Future<bool> storage();
}
```

- 内部调用 `LJPermissionUtils`
- 拒绝时 `DialogUtil.normal` 提示「去系统设置开启权限」
- 不做 `openAppSettings`（避免直接依赖未声明的 permission_handler）

### 3.3 公共文件改造

#### 目录出口 `index.dart`（减少 common.dart 逐文件 export）

新建：

- `lib/common/theme/index.dart`：export `app_colors.dart`、`app_text_style.dart`、`app_spacing.dart`、`app_theme.dart`
- `lib/common/widgets/index.dart`：export `app_button.dart`、`app_card.dart`、`page_state.dart`、`skeleton.dart`、`feed_card.dart`、`dialog_base.dart`、`dialog_util.dart`
- `lib/common/models/index.dart`：export `config_model.dart`、`network_base_model.dart`、`user_info_model.dart`、`home_models.dart`、`product_models.dart`、`message_model.dart`、`content_models.dart`
- `lib/common/services/index.dart`：export `user_service.dart`、`config_service.dart`、`cart_service.dart`、`push_service.dart`

#### `lib/common/common.dart`

- 删除 `export 'app_colors.dart';`
- 删除 `export 'widgets/dialog_util.dart';`、`export 'widgets/quick_widgets.dart';`
- 改为：
  - `export 'theme/index.dart';`
  - `export 'widgets/index.dart';`
  - `export 'models/index.dart';`
  - `export 'services/index.dart';`
  - `export 'utils/share_util.dart';`
  - `export 'utils/permission_util.dart';`
- 保留 `api_url.dart`、`constants.dart`、`router.dart`、`utils.dart` 的 export

#### 删除文件

- `lib/common/app_colors.dart`
- `lib/common/widgets/quick_widgets.dart`（按钮能力由 `AppButton` 完全覆盖，无其他函数）

#### `lib/common/widgets/dialog_base.dart` / `dialog_util.dart`

- 所有 `AppColor.xxx` 改为 `context.colors.xxx`（`DialogUtil` 的 builder 内已有 context）
- `primaryButton/secondaryButton` 调用点改为 `AppButton`，不再依赖 quick_widgets

#### `lib/common/router.dart`

- `UnknownRoutePage` 文案颜色改 `context.colors.textPrimary`
- 新增路由常量与 `pages` 注册（见 3.11）

#### `lib/app.dart`

- 删除手写 `ThemeData`，改为 `theme: AppTheme.light`
- 保留 `RefreshConfiguration`、`routingCallback`、`initialRoute`、`unknownRoute`、`onGenerateRoute`、builder

#### `lib/bootstrap.dart`

- `_configServices()` 追加 `Get.put(CartService())`、`Get.put(PushService())`
- `PushService.onInit` 仅做占位初始化与 TODO 注释，不发网络、不弹提示

#### `AGENTS.md`

- 目录表 `lib/common/app_colors.dart` 改为 `lib/common/theme/` 说明
- “颜色走 AppColor”改为“颜色走 `AppColors.of(context)` / `context.colors`”
- 组件优先级表新增一行：按钮 → `AppButton`
- 新增约束：禁止硬编码 `Color(0x...)`；分页接口 mock 按入参动态返回时写在 Controller

### 3.4 P0：启动页

#### `lib/splash/splash_page.dart`

- `Scaffold(backgroundColor: context.colors.bg)`
- `Stack`：
  - 铺满 `Image.asset('assets/images/splash.png', fit: BoxFit.cover)`（与原生闪屏同图，避免跳变）
  - 底部 `SafeArea` 内放品牌名 + 3px 进度条
- 进度条用 `TweenAnimationBuilder<double>(0→1, duration: 900ms)`，颜色 brand

#### `lib/splash/splash_controller.dart`

- `onReady` 保持 `RouterManager.replaceNamed(Routers.root)`
- 新增 `static const minSplashDuration = Duration(milliseconds: 900)`
- `onReady` 改为 `await Future.delayed(minSplashDuration)` 后再跳转
- 不新增网络请求（config/userInfo 已在 Service.onInit 发起）

### 3.5 P0：4 Tab 主框架

#### `lib/bottom_navigation/bottom_navigation_controller.dart`

```dart
final List<Widget> pages = const [
  KeepAliveWidget(child: HomePage()),
  KeepAliveWidget(child: CategoryPage()),
  KeepAliveWidget(child: FeedListPage()),
  KeepAliveWidget(child: MinePage()),
];
```

#### `lib/bottom_navigation/bottom_navigation_page.dart`

- 底部导航改主题色：选中 `context.colors.brand`，未选中 `context.colors.textHint`
- 4 项：
  - 首页 `Icons.home_outlined` / `Icons.home_rounded`
  - 商品 `Icons.grid_view_outlined` / `Icons.grid_view_rounded`（对应 `CategoryPage`）
  - 内容 `Icons.article_outlined` / `Icons.article_rounded`（对应 `FeedListPage`）
  - 我的 `Icons.person_outline_rounded` / `Icons.person_rounded`
- `selectedFontSize/unselectedFontSize = 11`
- 外层 `Container` 顶部 1px `context.colors.divider` 分割线，背景 `context.colors.surface`
- 保留 `DoublePopWidget` 退出逻辑

### 3.6 P0：首页（含内容流）

#### `lib/common/models/home_models.dart`

```dart
class HomeBannerItem { final int id; final String title, imageUrl, link; factory fromJson(Map<String,dynamic>); }
class HomeNavItem { final String title, icon; final int colorValue; final String route; factory fromJson(...); }
class FeedItem {
  final int id; final String author, avatar, content, cover, time;
  final int likes, comments; final bool liked, favorited;
  factory fromJson(...);
  FeedItem copyWith({bool? liked, bool? favorited, int? likes});
}
```

#### `lib/home/home_controller.dart`

```dart
class HomeController extends GetxController {
  final banners = <HomeBannerItem>[].obs;
  final navs = <HomeNavItem>[].obs;

  @override void onInit();                // 注册动态 mock + loadHomeBase()
  Future<void> loadHomeBase();            // banner + nav 并发拉取
  Future<List<FeedItem>> fetchFeed(int page);
  void onBannerTap(HomeBannerItem item);  // → 通用详情
  void onNavTap(HomeNavItem item);        // → 商品 Tab（index 1）/ 通用详情
  void onFeedTap(FeedItem item);          // → 内容详情
  void toggleLike(FeedItem item);         // 本地翻转 + POST
}
```

- `onNavTap`：`route == 'product'` 时切到商品 Tab（`Get.find<BottomNavigationController>().currentIndex.value = 1`），其余跳 `/detail`
- `fetchFeed(page)`：`LJNetwork.get<List<dynamic>>(ApiUrl.homeFeed, data: {'page': page})`，pageSize 6，手动 `fromJson`
- 动态 mock：`LJNetwork.mockMap[ApiUrl.homeFeed]`，共 14 条，page 1/2 有数据、page ≥3 返回空数组；仅在 `kDebugMode` 注册
- banner/nav 走 `assets/json/mock.json` 静态数据，不打动态 mock

#### `lib/home/home_page.dart`

- AppBar：左侧 `quickText('发现', 24, colors.textPrimary, semibold)`，右侧两个入口：
  - 铃铛 `Icons.notifications_none_rounded`（未读小红点）→ `/message`
  - 搜索 `Icons.search_rounded` → `/search`
- body：
  - `Get.put<LJRefreshListViewController<FeedItem>>(LJRefreshListViewController(pageSize: 6, networkCallback: controller.fetchFeed), tag: 'homeFeed')`
  - `SmartRefresher(controller: feedController.refreshController, onRefresh/onLoading → fetchData)`
  - `CustomScrollView`：
    1. `SliverToBoxAdapter`：`LJSwiper<HomeBannerItem>`（aspectRatio 2.2、padding 16、圆角 12）+ 4×2 宫格（`HomeNavItem`，图标圆角方块使用 item 颜色）+ 分区标题「推荐」
    2. `GetBuilder<LJRefreshListViewController<FeedItem>>(tag: 'homeFeed')` 内 `SliverList`，每项用共用 `FeedCard`：
       - `FeedCard(item: item, onTap: () => controller.onFeedTap(item), onLike: () => controller.toggleLike(item))`
       - 点赞/评论数随 `FeedItem.copyWith` 即时刷新
    3. 列表为空且不在加载中：`SliverToBoxAdapter(PageStateView.empty)`
- 不在 `build` 内直接发请求（网络由 Controller/ListController 负责）

### 3.7 P0：商品 Tab / 内容 Tab / 消息 / 我的 / 详情 / 设置

#### `lib/category/category_page.dart` + `category_controller.dart`（「商品」Tab）

- 顶部搜索入口（点击 → `/search`）
- 左侧一级分类竖列表（宽 96，选中态 brandLight 底 + 左侧 3px brand 竖条）
- 右侧为当前一级分类下的商品 2 列网格（`LJRefreshGridView<Product>`，`viewTag: 'categoryProducts'`、`pageSize: 10`）
- 切换一级分类：更新 `selectedGroupId` 后 `Get.find<LJRefreshListViewController>(tag: 'categoryProducts').fetchData(true)`
- 商品卡点击 → `/product/detail`
- 右侧为空时叠加 `PageStateView.empty`（同 tag 的 `GetBuilder` 判断 `list.isEmpty`）
- 数据：`ApiUrl.categoryList` 提供分类，`ApiUrl.productList` 按 `categoryId` 筛选
- 作为 Tab 页不注册独立路由，也不存在独立的商品列表页

> 说明：相比「二级分类图标宫格 → 再跳商品列表」，右侧直接展示商品少一次点击，且少一个页面/路由/controller，Tab 名与内容也更一致。

#### `lib/content/feed_list_page.dart` + `feed_list_controller.dart`（「内容」Tab）

- AppBar「内容」
- `LJRefreshListView<FeedItem>(viewTag: 'feedList', pageSize: 6)`，接口 `ApiUrl.feedList`（静态 mock 5 条，单页到底）
- 每项使用共用 `FeedCard`：点击 → `/feed/detail`，点赞 → `toggleLike`
- 空状态 `PageStateView.empty`
- 作为 Tab 页不注册独立路由

#### `lib/message/message_page.dart` + `message_controller.dart`（二级页，从首页铃铛进入）

- `lib/common/models/message_model.dart`：
  ```dart
  class MessageItem {
    final int id; final String title, content, time; final bool read;
    factory MessageItem.fromJson(Map<String, dynamic>);
    MessageItem copyWith({bool? read});
  }
  ```
- AppBar「消息」+ 右侧「全部已读」文字按钮
- `LJRefreshListView<MessageItem>`（`pageSize: 10`）展示标题/摘要/时间/未读红点
- 点击弹 `DialogUtil.show` 展示正文，并把该条置为已读
- 空状态用 `PageStateView.empty`

#### `lib/mine/mine_page.dart` + `mine_controller.dart`（重写）

- 顶部用户卡：`AppCard`，未登录显示「点击登录」→ `/login`；已登录显示头像/昵称/手机号
- 「我的订单」入口卡：全部/待付款/待发货/已完成 4 宫格 → `/order?status=x`
- 功能列表：`AppCard` 内多行（消息中心、我的收藏、购物车、关于我们、设置），带图标与右箭头
- 设置固定在我的内，不作为底部 Tab
- 登录后底部「退出登录」文字按钮，`DialogUtil.normal` 二次确认
- 保留 `Obx` 监听 `UserService`

#### `lib/detail/detail_page.dart`

- 从 `context.argumentMap` 读取 `id` / `title` / `cover` / `content`
- 无 Controller（纯展示页）
- 结构：封面 `LJNetworkImage` + `AppCard` 标题/正文 + `BottomContainer` 内 `AppButton('立即咨询')`（点击 `EasyLoading.showInfo('示例操作')`）

#### `lib/mine/setting_page.dart`（重写为 StatefulWidget）

行项目：

1. 账号与安全 → 未登录跳登录，已登录 toast「示例」
2. 隐私协议 → `ConfigService.to.configDataInfo.value.privacyUrl` 打开 `/webview`
3. 用户协议 → `protocolUrl`
4. 清除缓存 → 二次确认后 `PaintingBinding.instance.imageCache.clear()` + `clearLiveImages()` + toast
5. 主题 → `EasyLoading.showInfo('主题切换开发中')`
6. 关于我们 → `RouterManager.pushPage(const AboutUsPage())`（或 `/about`）
7. 当前版本 → 展示 `LJUtil.packageInfo.version`，点击 toast「已是最新版本」
8. 退出登录（仅登录态）

统一用 `AppCard` + 行组件（图标 + 标题 + 右侧值/箭头），分割线用 `context.colors.divider`。

#### `lib/mine/about_us_page.dart`（重写）

- App 图标（`assets/images/splash.png` 圆形裁切）+ 名称 + 版本号 + 版权文案
- 使用主题色，无 Controller

### 3.8 P1：通用能力

#### `lib/search/search_page.dart` + `search_controller.dart`

- 顶部搜索框：`TextField` + 取消按钮；自动聚焦
- 历史记录：`LJUtil.preferences` 存最近 10 条，点击回填，右侧清空
- 结果：`LJRefreshListView<FeedItem>`（`viewTag: 'search'`），空结果 `PageStateView.empty`
- 接口 `ApiUrl.search` 静态 mock（返回 3 条）

#### `lib/favorites/favorites_page.dart` + `favorites_controller.dart`

- AppBar「我的收藏」+ 右上「管理」
- `LJRefreshListView<FeedItem>`；管理态显示删除按钮，删除后从本地列表移除
- 空状态 `PageStateView.empty` + 「去逛逛」按钮 → 切到首页 Tab

#### 推送占位 `lib/common/services/push_service.dart`

```dart
class PushService extends GetxService {
  static PushService get to => Get.find();
  String? token;
  @override void onInit();  // TODO: 接入厂商推送 SDK，注册 deviceToken
}
```

#### WebView / 分享 / 权限

- 按 3.2 的 `WebViewPage`、`ShareUtil`、`PermissionUtil` 实现
- 内容详情底部「分享」调用 `ShareUtil.shareText`

### 3.9 P2：电商

#### `lib/common/models/product_models.dart`

```dart
class CategoryGroup { int id; String name; }
class Product { int id, categoryId; String title, cover, desc; double price, originPrice; int sales; }
class Sku { int id; String name; double price; int stock; }
class CartItem { Product product; Sku? sku; int quantity; bool selected; }
class OrderItem { int id; String orderNo, statusText, cover, title; double amount; int quantity; }
```

均提供 `factory fromJson(Map<String,dynamic>)`。

#### `lib/common/services/cart_service.dart`

```dart
class CartService extends GetxService {
  static CartService get to => Get.find();
  final items = <CartItem>[].obs;
  int get totalCount;
  double get selectedTotal;
  bool get allSelected;
  void add(Product product, {Sku? sku, int quantity = 1});
  void remove(CartItem item);
  void changeQuantity(CartItem item, int delta);
  void toggleSelected(CartItem item);
  void toggleAll(bool value);
  void clearSelected();
}
```

- 纯内存 + `Obx` 响应式；首次进入不预置数据（购物车为空展示 `PageStateView.empty`）

#### 商品 Tab 接入商品网格（`category_controller.dart`）

- `CategoryController` 持有 `groups`、`selectedGroupId`，并暴露 `fetchProducts(int page)` 给 `LJRefreshGridView`
- 左侧分类切换后先 `selectedGroupId.value = id`，再 `Get.find<LJRefreshListViewController>(tag: 'categoryProducts').fetchData(true)`
- 商品卡：封面 1:1、标题 2 行、价格（price 色）+ 原价删除线 + 销量
- 卡片点击 → `/product/detail`
- 不再创建 `product_list_page.dart`，也不注册 `/product/list`

#### `lib/product/product_detail_page.dart` + `product_detail_controller.dart`

- 参数：`id`
- 结构：轮播封面 + 价格/标题卡 + SKU 选择卡 + 详情文本
- 底部 `BottomContainer`：购物车图标（带角标 `CartService.to.totalCount`）+「加入购物车」+「立即购买」
- SKU 选择用 `showModalBottomSheet`（包内 `LJWrapRadio` 或自绘 `Wrap` + `ChoiceChip`）
- 加入购物车：`CartService.to.add(...)` + `EasyLoading.showSuccess('已加入购物车')`
- 立即购买：跳 `/order/confirm`，参数为当前商品+SKU+数量

#### `lib/cart/cart_page.dart` + `cart_controller.dart`

- 列表：`Obx` + `ListView.separated`（非分页，本地状态，不走分页 Controller）
- 行：选择框、封面、标题/SKU、价格、数量加减、删除
- 底部 `BottomContainer`：全选、合计（price 色）、`AppButton('去结算')`
- 空状态 `PageStateView.empty` + 「去逛逛」
- 结算 → `/order/confirm`，仅带选中项

#### `lib/order/order_confirm_page.dart` + `order_confirm_controller.dart`

- 参数：`items`（`List<CartItem>`，可为空表示直接购买）、`fromCart`
- 地址卡（mock 地址）、商品清单、金额明细、备注输入
- 底部：合计 + 「提交订单」
- 提交：`LJNetwork.post(ApiUrl.orderCreate)` 成功后 `CartService.clearSelected()`（购物车来源时）+ `RouterManager.replaceNamed(Routers.order, arguments: {'status': 'all'})`

#### `lib/mine/order_page.dart`（重写）+ `lib/order/order_list_controller.dart`

- AppBar「我的订单」
- 顶部 4 个状态 Tab：全部/待付款/待发货/已完成
- `LJRefreshListView<OrderItem>`（`viewTag: 'orderList'`）展示订单号/状态/商品/金额
- 参数 `status` 决定默认 Tab
- 空状态 `PageStateView.empty`

### 3.10 P2：内容

#### `lib/common/models/content_models.dart`

```dart
class CommentItem {
  final int id; final String author, avatar, content, time; final int likes;
  factory CommentItem.fromJson(Map<String, dynamic>);
}
```

#### `lib/content/feed_detail_page.dart` + `feed_detail_controller.dart`

- 参数：`id`
- 结构：作者行、正文、大图、点赞/收藏/分享操作栏、评论预览（前 3 条）
- 点赞/收藏：本地翻转 + `LJNetwork.post`（失败由全局处理，本地不回滚，保持简单）
- 底部 `BottomContainer` 输入框 + 发送按钮，发送后把评论插入列表顶部
- 「查看全部评论」→ `/comments`，参数 `feedId`

#### `lib/content/comment_list_page.dart` + `comment_list_controller.dart`

- `LJRefreshListView<CommentItem>`（`viewTag: 'comments'`）
- 项：头像、昵称、内容、时间、点赞数
- 空状态 `PageStateView.empty`

### 3.11 路由与接口

#### 新增路由常量（`lib/common/router.dart`）

```dart
static String message = '/message';
static String detail = '/detail';
static String webview = '/webview';
static String search = '/search';
static String favorites = '/favorites';
static String productDetail = '/product/detail';
static String cart = '/cart';
static String orderConfirm = '/order/confirm';
static String comments = '/comments';
static String feedDetail = '/feed/detail';
```

`pages` 全部注册（Tab 页 `CategoryPage` / `FeedListPage` 由 `BottomNavigationController.pages` 直接持有，不注册命名路由）。
`verifyLoginPageList` 追加：`favorites`、`cart`、`orderConfirm`、`order`。

#### 新增 `ApiUrl`

```dart
static String homeBanners = '/api/home/banners';
static String homeNavs = '/api/home/navs';
static String homeFeed = '/api/home/feed';
static String feedList = '/api/feed/list';
static String categoryList = '/api/category/list';
static String messageList = '/api/message/list';
static String search = '/api/search';
static String favoriteList = '/api/favorite/list';
static String productList = '/api/product/list';
static String productDetail = '/api/product/detail';
static String orderCreate = '/api/order/create';
static String orderList = '/api/order/list';
static String feedDetail = '/api/feed/detail';
static String feedLike = '/api/feed/like';
static String feedFavorite = '/api/feed/favorite';
static String commentList = '/api/comment/list';
static String commentCreate = '/api/comment/create';
```

#### `assets/json/mock.json`

补齐静态 mock（图片统一用 `https://picsum.photos/seed/<key>/800/800`）：

- `/api/home/banners`：3 条
- `/api/home/navs`：8 条（名称/icon 名称/颜色值/route）
- `/api/feed/list`：5 条（内容 Tab 单页数据）
- `/api/category/list`：6 个一级分类（id/name）
- `/api/message/list`：4 条
- `/api/search`：3 条
- `/api/favorite/list`：4 条
- `/api/product/detail`：1 个商品 + 3 个 SKU
- `/api/order/list`：3 条
- `/api/order/create`：`{"orderNo": "..."}`
- `/api/feed/detail`：1 条
- `/api/comment/list`：5 条
- `/api/feed/like`、`/api/feed/favorite`、`/api/comment/create`：成功空数据

动态 mock（按入参变化，写在对应 Controller）：

- `ApiUrl.homeFeed`（`HomeController.onInit`）：page 1/2 各 6 条，page ≥3 返回空
- `ApiUrl.productList`（`CategoryController.onInit`）：按 `categoryId` 返回该分类 6 个商品，单页到底

### 3.12 测试

- `test/widget_test.dart` 的路由一致性断言保留，新增路由自动被覆盖
- 不新增 golden/组件测试（本次范围外）

## 4. 验收标准

### 4.1 主题

- 全工程 `grep "AppColor\."` 为 0
- 全工程 `grep "Color(0x"` 只出现在 `app_colors.dart`
- 主题切换为 `dark` 时颜色 token 生效（本轮不做 UI 开关）

### 4.2 P0

- 启动：原生闪屏 → 同图 Flutter 启动页（带进度条）→ 900ms 后进首页，无白屏
- 未登录点击收藏/购物车/确认订单 → 自动跳登录，登录成功后继续原目标
- 首页：轮播自动播放、宫格可点、列表下拉刷新/上拉加载正常、第 3 页显示无更多
- 4 Tab 切换保留各页状态（`KeepAliveWidget`）
- 我的：登录/退出后信息实时变化；设置页各入口可用
- 详情页参数正确展示，底部安全区无遮挡

### 4.3 P1

- 搜索历史持久化；空结果展示空状态
- 收藏可删除，删除后空状态正确
- WebView 能打开 config 中的协议地址
- 分享复制链接并提示

### 4.4 P2 电商

- 商品 Tab 切换分类后网格刷新，进入详情 SKU 可选择
- 加入购物车后角标数量正确；购物车增删改/全选/合计正确
- 提交订单后购物车选中项清空，跳转订单列表
- 订单列表按状态筛选，空状态正确

### 4.5 P2 内容

- 内容详情点赞/收藏状态与数字即时变化
- 评论发送后插入列表顶部；评论列表分页正常

### 4.6 约束

- 不新增第三方依赖（分享用剪贴板、推送仅占位）
- 不手改 `lib/generated/json/`
- 用户未声明时，不自动执行 `flutter analyze` / `flutter test` / 构建

## 5. 执行方式

按 `tasks.md` 的 T1~T8 顺序实施，每完成一个任务更新 `TodoWrite` 状态。
T1 完成后先落地主题与通用组件，其余任务按 P0 → P1 → P2 推进。
