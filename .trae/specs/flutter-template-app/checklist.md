# 验收清单

## 主题与基础设施

- [x] `AppColors extends ThemeExtension`，业务侧通过 `context.colors.xxx` 取色，`of()` 有 light 回退
- [x] `AppTextStyle` 6 档字号 + button，字重来自 `lj_define` 且未加 `const`
- [x] `AppSpacing` 提供间距与 4 档圆角
- [x] `AppTheme.light/dark` 统一 AppBar/卡片/按钮/输入框
- [x] `theme/`、`widgets/`、`models/`、`services/` 均有 `index.dart` 统一 export
- [x] `quick_widgets.dart`、`app_colors.dart` 已删除且全工程无引用
- [x] `grep "AppColor\." lib` 为 0
- [x] `grep "Color(0x" lib` 仅命中 `lib/common/theme/app_colors.dart`
- [x] `grep "FontWeight.w" lib` 为 0
- [x] `AppButton` / `AppCard` / `PageStateView` / `SkeletonBox` / `FeedCard` 可复用
- [x] `DialogBase` 使用 `AppButton`，不再依赖 `quick_widgets`

## 启动与导航

- [x] Splash 展示图片与进度条，不阻塞启动链路
- [x] 底部 4 Tab 顺序：首页 / 商品 / 内容 / 我的
- [x] Tab 切换通过 `KeepAliveWidget` 保留页面状态
- [x] 设置收在「我的」内，无独立 Tab
- [x] 消息为二级页，首页铃铛与我的入口均可进入
- [x] `Routers.pages` 覆盖全部命名路由，业务代码无硬编码路由字符串
- [x] `grep "Navigator.push" lib` 为 0（仅底部弹层用 `Navigator.of(sheetContext).pop()`）

## 首页

- [x] 轮播使用 `LJSwiper`，宫格 4 列 2 行
- [x] 整体可滚动（轮播/宫格/推荐流一起滚动）
- [x] 分页由 `LJRefreshListViewController` 管理，第 3 页起无更多
- [x] 点赞本地即时更新，网络失败由全局统一提示
- [x] 空态使用 `PageStateView`

## 通用能力

- [x] 搜索支持历史记录持久化，结果分页与空态正常
- [x] 收藏列表可删除并展示空态
- [x] `ShareUtil` 复制链接并提示成功
- [x] `PermissionUtil` 拒绝时使用 `DialogUtil` 引导
- [x] `PushService` 占位并在 bootstrap 注册
- [x] WebView 页面可打开协议链接

## 商品与交易

- [x] 商品 Tab 为左侧分类 + 右侧 2 列网格，切换分类刷新列表
- [x] 商品卡展示封面/标题/价格/原价/销量
- [x] 商品详情支持 SKU 选择、加入购物车、立即购买
- [x] `CartService` 增删改/选择/合计/全选实时正确，并在 bootstrap 注册
- [x] 确认订单展示商品与合计，提交后清空选中项并进入订单列表
- [x] 订单列表支持 5 个状态 Tab 筛选

## 内容

- [x] 内容详情点赞/收藏即时变化
- [x] 评论发送后置顶，评论列表分页与空态正常
- [x] 内容详情接入分享

## Mock 与文档

- [x] `assets/json/mock.json` 为合法 JSON，覆盖静态接口
- [x] 全部接口 mock 均在 `assets/json/mock.json` 中声明，bootstrap `_configMock` 一次性整体写入 `mockMap`，业务代码零 mock 逻辑
- [x] `AGENTS.md` 与实际目录、主题系统、注册服务一致
