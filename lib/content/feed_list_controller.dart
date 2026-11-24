import '../common/common.dart';

class FeedListController extends GetxController {
  static const String listTag = 'feedList';

  Future<List<FeedItem>> fetchFeedList(int page) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.feedList,
      params: {'page': page},
    );
    return parseList(response, FeedItem.fromJson);
  }

  void openDetail(FeedItem item) {
    RouterManager.pushNamed(
      Routers.feedDetail,
      arguments: {'id': item.id},
    );
  }

  void toggleLike(FeedItem item) {
    final LJRefreshListViewController listController = Get.find(
      tag: listTag,
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
