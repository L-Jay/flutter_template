import 'package:lj_flutter_package/ui_component/lj_swiper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/common.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const String _feedTag = 'homeFeed';

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => HomeController());

    if (!Get.isRegistered<LJRefreshListViewController>(tag: _feedTag)) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<FeedItem>(
          pageSize: 6,
          networkCallback: controller.fetchFeed,
        ),
        tag: _feedTag,
      );
    }
    final LJRefreshListViewController listController =
        Get.find<LJRefreshListViewController>(tag: _feedTag);

    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: AppSpacing.page,
        title: Text(context.l10n.homeTitle, style: AppTextStyle.display(colors.textPrimary)),
        actions: [
          IconButton(
            onPressed: controller.openMessage,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: colors.textPrimary,
                ),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.openSearch,
            icon: Icon(Icons.search_rounded, color: colors.textPrimary),
          ),
        ],
      ),
      // GetBuilder 在外、Obx 在内：banners/navs 必须在 Obx 闭包作用域内读取才能订阅
      body: GetBuilder<LJRefreshListViewController>(
        tag: _feedTag,
        builder: (feedController) {
          final List<FeedItem> list = feedController.list.cast<FeedItem>();

          return Obx(() {
            final List<HomeBannerItem> banners = controller.banners;
            final List<HomeNavItem> navs = controller.navs;

            return SmartRefresher(
              controller: listController.refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: () => listController.fetchData(true),
              onLoading: () => listController.fetchData(false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, banners, navs),
                  ),
                  if (list.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: PageStateView(
                        type: controller.feedLoaded.value
                            ? PageStateType.empty
                            : PageStateType.loading,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      sliver: SliverList.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final FeedItem item = list[index];
                          return FeedCard(
                            item: item,
                            onTap: () => controller.onFeedTap(item),
                            onLike: () => controller.toggleLike(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<HomeBannerItem> banners,
    List<HomeNavItem> navs,
  ) {
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (banners.isNotEmpty)
          LJSwiper<HomeBannerItem>(
            viewModels: banners,
            getImgUrl: (item) => item.imageUrl,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            connerRadius: AppSpacing.radiusMd,
            aspectRatio: 2.2,
            onTap: controller.onBannerTap,
          ),
        if (navs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.sm,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: navs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final HomeNavItem item = navs[index];
                final Color color = Color(item.colorValue);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.onNavTap(item),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: Icon(_navIcon(item.icon), color: color, size: 22),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _navLabel(context, item.icon, item.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption(colors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Text(
            context.l10n.homeRecommend,
            style: AppTextStyle.title(colors.textPrimary),
          ),
        ),
      ],
    );
  }

  String _navLabel(BuildContext context, String icon, String fallback) {
    switch (icon) {
      case 'new':
        return context.l10n.navNew;
      case 'hot':
        return context.l10n.navHot;
      case 'category':
        return context.l10n.navCategory;
      case 'coupon':
        return context.l10n.navCoupon;
      case 'activity':
        return context.l10n.navActivity;
      case 'vip':
        return context.l10n.navVip;
      case 'live':
        return context.l10n.navLive;
      case 'more':
        return context.l10n.navMore;
      default:
        return fallback;
    }
  }

  IconData _navIcon(String name) {
    switch (name) {
      case 'new':
        return Icons.fiber_new_outlined;
      case 'hot':
        return Icons.local_fire_department_outlined;
      case 'category':
        return Icons.grid_view_rounded;
      case 'coupon':
        return Icons.confirmation_number_outlined;
      case 'activity':
        return Icons.celebration_outlined;
      case 'vip':
        return Icons.workspace_premium_outlined;
      case 'live':
        return Icons.live_tv_outlined;
      case 'more':
        return Icons.apps_rounded;
      default:
        return Icons.widgets_outlined;
    }
  }
}
