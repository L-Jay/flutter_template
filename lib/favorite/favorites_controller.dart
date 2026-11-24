import '../common/common.dart';

class FavoritesController extends GetxController {
  static const String listTag = 'favorites';

  final isManaging = false.obs;
  final selectedIds = <int>{}.obs;

  Future<List<FeedItem>> fetchFavorites(int page) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.favoriteList,
      params: {'page': page},
    );
    return parseList(response, FeedItem.fromJson);
  }

  void toggleManaging() {
    isManaging.toggle();
    selectedIds.clear();
  }

  void toggleSelect(FeedItem item) {
    if (!selectedIds.add(item.id)) {
      selectedIds.remove(item.id);
    }
    selectedIds.refresh();
  }

  void onItemTap(FeedItem item) {
    if (isManaging.value) {
      toggleSelect(item);
    } else {
      RouterManager.pushNamed(
        Routers.feedDetail,
        arguments: {'id': item.id},
      );
    }
  }

  void removeSelected() {
    if (selectedIds.isEmpty) {
      EasyLoading.showToast(
        Get.l10n.selectToDelete,
      );
      return;
    }

    final LJRefreshListViewController listController = Get.find(
      tag: listTag,
    );
    listController.list.removeWhere(
      (e) => selectedIds.contains((e as FeedItem).id),
    );
    listController.update();

    selectedIds.clear();
    isManaging.value = false;
    EasyLoading.showSuccess(
      Get.l10n.deleted,
    );
  }
}
