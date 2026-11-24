# 实施任务清单

> 规格见 `spec.md`。按顺序执行，每项完成后更新 `TodoWrite`。
> 用户未声明时，不自动执行 analyze/test/构建。

## T1 主题与通用组件基础设施

- [x] 新建 `lib/common/theme/app_colors.dart`：`AppColors extends ThemeExtension`，含 light/dark、`of(context)` 回退、`copyWith`、`lerp`、`context.colors` 扩展
- [x] 新建 `lib/common/theme/app_text_style.dart`：6 档字号 + `button`，行高按 32/28/24/22/20/16
- [x] 新建 `lib/common/theme/app_spacing.dart`：间距、页边距、4 档圆角
- [x] 新建 `lib/common/theme/app_theme.dart`：`AppTheme.light` / `AppTheme.dark`（AppBar 44、卡片、按钮、输入框）
- [x] 新建 `lib/common/theme/index.dart` 统一 export
- [x] 新建 `lib/common/widgets/app_button.dart`：primary/secondary/text + loading/disabled
- [x] 新建 `lib/common/widgets/app_card.dart`：白底圆角 12 + 阴影 + 可选点击
- [x] 新建 `lib/common/widgets/page_state.dart`：loading/empty/error + 重试
- [x] 新建 `lib/common/widgets/skeleton.dart`：SkeletonBox/Line/Card 呼吸动画
- [x] 新建 `lib/common/widgets/feed_card.dart`：首页/内容 Tab 共用内容卡片
- [x] 新建 `lib/common/widgets/index.dart` 统一 export（含 dialog_base/dialog_util）
- [x] 删除 `lib/common/widgets/quick_widgets.dart`，`dialog_base.dart` 改用 `AppButton`
- [x] 删除 `lib/common/app_colors.dart`
- [x] 迁移 7 个文件中的 `AppColor.`：`app.dart`、`router.dart`、`dialog_base.dart`、`dialog_util.dart`、`login/login_page.dart`、`mine/mine_page.dart`、`mine/setting_page.dart`
- [x] 新建 `lib/common/models/index.dart`、`lib/common/services/index.dart`
- [x] `lib/common/common.dart` 改用 4 个 index export，移除 app_colors/quick_widgets
- [x] `lib/app.dart` 改用 `AppTheme.light`
- [x] 更新 `AGENTS.md`：主题目录、`context.colors`、`AppButton`、禁止硬编码 Color

**验收**：`grep "AppColor\." lib` 为 0；`grep "Color(0x" lib` 仅命中 `theme/app_colors.dart`；`quick_widgets.dart` 已删除且无引用。

## T2 P0 启动页与 4 Tab 骨架

- [x] 重写 `lib/splash/splash_page.dart`：同图铺满 + 底部进度条（900ms）
- [x] 改 `lib/splash/splash_controller.dart`：延迟 `minSplashDuration` 后 `replaceNamed(root)`
- [x] 新建 `lib/common/models/home_models.dart`：`HomeBannerItem` / `HomeNavItem` / `FeedItem`
- [x] 新建 `lib/common/models/message_model.dart`：`MessageItem`
- [x] 新建 `lib/common/models/product_models.dart`：`CategoryGroup` / `Product` / `Sku` / `CartItem` / `OrderItem`
- [x] 新建 `lib/category/category_page.dart` + `category_controller.dart`：「商品」Tab，左侧一级分类 + 右侧商品网格
- [x] 新建 `lib/content/feed_list_page.dart` + `feed_list_controller.dart`：「内容」Tab，`LJRefreshListView<FeedItem>`
- [x] 新建 `lib/message/message_page.dart` + `message_controller.dart`：二级页，已读/全部已读
- [x] 改 `lib/bottom_navigation/bottom_navigation_controller.dart`：首页/商品/内容/我的
- [x] 改 `lib/bottom_navigation/bottom_navigation_page.dart`：4 项图标、主题色、11 号字、顶部分割线
- [x] 重写 `lib/mine/mine_page.dart` + `mine_controller.dart`：用户卡、订单宫格、功能列表（消息/收藏/购物车/关于/设置）、退出登录
- [x] 重写 `lib/mine/setting_page.dart`：8 个设置行（设置固定在我的内）
- [x] 重写 `lib/mine/about_us_page.dart`：图标/名称/版本
- [x] 新建 `lib/detail/detail_page.dart`：通用详情
- [x] `router.dart` 注册 `message` / `detail`

**验收**：4 Tab 顺序为 首页/商品/内容/我的，切换保留状态；设置从我的进入；启动无白屏。

## T3 P0 首页（轮播 + 宫格 + 内容流分页）

- [x] 补 `ApiUrl.homeBanners/homeNavs/homeFeed`
- [x] `assets/json/mock.json` 补 banner/navs
- [x] 实现 `lib/home/home_controller.dart`：banner/nav 拉取、`fetchFeed`、点赞、跳转（分页 mock 统一在 bootstrap）
- [x] 实现 `lib/home/home_page.dart`：`SmartRefresher` + `CustomScrollView` + `LJSwiper` + 宫格 + `SliverList` + `FeedCard`
- [x] 首页 AppBar 铃铛 → `/message`，搜索 → `/search`
- [x] 列表为空/加载态使用 `PageStateView`

**验收**：首页整体可滚动；下拉刷新、上拉加载、第 3 页无更多均正常；点赞本地即时反馈。

## T4 P1 通用能力

- [x] 新建 `lib/common/webview/webview_page.dart` 并注册 `/webview`
- [x] 新建 `lib/common/utils/share_util.dart`（复制链接 + 提示）
- [x] 新建 `lib/common/utils/permission_util.dart`
- [x] 新建 `lib/common/services/push_service.dart` 并在 bootstrap 注册
- [x] 新建 `lib/search/search_page.dart` + `search_controller.dart`（历史记录持久化）
- [x] 新建 `lib/favorite/favorites_page.dart` + `favorites_controller.dart`（删除 + 空状态）
- [x] 补 `ApiUrl.search/favoriteList/feedList` 与对应 mock
- [x] `router.dart` 注册 `search` / `favorites` / `webview`，收藏加入登录校验

**验收**：搜索历史重启后仍在；收藏可删除；WebView 打开协议链接；分享提示成功。

## T5 P2 电商模型与购物车服务

- [x] 补 `lib/common/models/product_models.dart`：`Product` / `Sku` / `CartItem` / `OrderItem`
- [x] 新建 `lib/common/services/cart_service.dart`：增删改、选择、合计、清空选中
- [x] `bootstrap.dart` `_configServices` 注册 `CartService` / `PushService`

**验收**：`CartService` 的数量/合计/全选在 `Obx` 下实时正确。

## T6 P2 商品 Tab 商品网格与商品详情

- [x] `CategoryController` 接入 `fetchProducts`，左侧分类切换刷新 `LJRefreshGridView`（`viewTag: 'categoryProducts'`）
- [x] 商品卡片：封面/标题/价格/原价/销量，点击 → `/product/detail`
- [x] 新建 `lib/product/product_detail_page.dart` + `product_detail_controller.dart`（封面/SKU/底部双按钮/角标）
- [x] 补 `ApiUrl.productList/productDetail` 与 mock（按 categoryId/id 变化的 mock 统一在 bootstrap）
- [x] `router.dart` 注册 `productDetail`

**验收**：切换一级分类商品列表刷新；商品卡信息完整；SKU 可选；加入购物车角标 +1；立即购买进入确认订单。

## T7 P2 购物车、确认订单、订单列表

- [x] 新建 `lib/cart/cart_page.dart` + `cart_controller.dart`
- [x] 新建 `lib/order/order_confirm_page.dart` + `order_confirm_controller.dart`
- [x] 新建 `lib/order/order_page.dart` + `lib/order/order_list_controller.dart`（5 状态 Tab）
- [x] 补 `ApiUrl.orderCreate/orderList` 与 mock
- [x] `router.dart` 注册 `cart` / `orderConfirm`，并加入登录校验；我的页入口接通

**验收**：购物车增删改/全选/合计正确；提交订单后清空选中项并跳订单列表；状态筛选正确。

## T8 P2 内容详情与评论

- [x] 新建 `lib/common/models/content_models.dart`：`CommentItem`
- [x] 新建 `lib/content/feed_detail_page.dart` + `feed_detail_controller.dart`
- [x] 新建 `lib/content/comment_list_page.dart` + `comment_list_controller.dart`
- [x] 补 `ApiUrl.feedDetail/feedLike/feedFavorite/commentList/commentCreate` 与 mock
- [x] `router.dart` 注册 `feedDetail` / `commentList`；首页与内容 Tab 卡片点击接入
- [x] 内容详情接入 `ShareUtil` 与评论发送

**验收**：点赞/收藏即时变化；评论发送后置顶；评论列表分页与空状态正确。

## T9 收尾

- [x] 全量检查 `AppColor.` / 硬编码颜色 / `Navigator.push` / `FontWeight.w` 裸值
- [x] 检查所有命名路由在 `Routers.pages` 中存在，Tab 页不重复注册
- [x] `assets/json/mock.json` 为合法 JSON
- [x] `AGENTS.md` 与实际目录一致
