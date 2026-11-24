import '../bottom_navigation/bottom_navigation_controller.dart';
import '../common/common.dart';

class HomeController extends GetxController {
  final banners = <HomeBannerItem>[].obs;
  final navs = <HomeNavItem>[].obs;

  /// 内容流首页数据是否已返回：首次加载用于区分 loading / 空数据
  final feedLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadHomeBase();
  }

  /// 轮播 + 宫格并发拉取
  Future<void> loadHomeBase() async {
    final List<dynamic> results = await Future.wait([
      LJNetwork.get(ApiUrl.homeBanners),
      LJNetwork.get(ApiUrl.homeNavs),
    ]);

    banners.assignAll(parseList(results[0], HomeBannerItem.fromJson));
    navs.assignAll(parseList(results[1], HomeNavItem.fromJson));
  }

  Future<List<FeedItem>> fetchFeed(int page) async {
    if (page == 1) feedLoaded.value = false;

    final dynamic response = await LJNetwork.get(
      ApiUrl.homeFeed,
      params: {'page': page},
    );
    final List<FeedItem> result = parseList(response, FeedItem.fromJson);
    feedLoaded.value = true;
    return result;
  }

  void openMessage() {
    RouterManager.pushNamed(Routers.message);
  }

  void openSearch() {
    RouterManager.pushNamed(Routers.search);
  }

  void onBannerTap(HomeBannerItem item) {
    RouterManager.pushNamed(
      Routers.detail,
      arguments: {'id': item.id, 'title': item.title, 'cover': item.imageUrl},
    );
  }

  void onNavTap(HomeNavItem item) {
    switch (item.route) {
      case 'search':
        RouterManager.pushNamed(
          Routers.search,
          arguments: {'keyword': item.keyword},
        );
        return;
      case 'category':
        Get.find<BottomNavigationController>().currentIndex.value = 1;
        return;
      case 'coupon':
        RouterManager.pushNamed(Routers.coupon);
        return;
      case 'activity':
        RouterManager.pushNamed(Routers.activity);
        return;
      case 'vip':
        RouterManager.pushNamed(Routers.vip);
        return;
      case 'live':
        RouterManager.pushNamed(Routers.live);
        return;
      default:
        RouterManager.pushNamed(
          Routers.detail,
          arguments: {'title': item.title},
        );
    }
  }

  void onFeedTap(FeedItem item) {
    RouterManager.pushNamed(
      Routers.feedDetail,
      arguments: {'id': item.id},
    );
  }

  /// 点赞本地即时反馈，失败由全局统一提示
  void toggleLike(FeedItem item) {
    final LJRefreshListViewController listController = Get.find(
      tag: 'homeFeed',
    );
    final int index = listController.list.indexWhere(
      (e) => (e as FeedItem).id == item.id,
    );
    if (index < 0) return;

    final FeedItem current = listController.list[index] as FeedItem;
    listController.list[index] = current.copyWith(
      liked: !current.liked,
      likes: current.likes + (current.liked ? -1 : 1),
    );
    listController.update();

    LJNetwork.post(ApiUrl.feedLike, data: {'id': item.id});
  }
}
