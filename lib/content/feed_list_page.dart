import '../common/common.dart';
import 'feed_list_controller.dart';

class FeedListPage extends GetView<FeedListController> {
  const FeedListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => FeedListController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: FeedListController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<FeedItem>(
          pageSize: 6,
          networkCallback: controller.fetchFeedList,
        ),
        tag: FeedListController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabContent)),
      body: GetBuilder<LJRefreshListViewController>(
        tag: FeedListController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<FeedItem>(
                viewTag: FeedListController.listTag,
                pageSize: 6,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchFeedList,
                itemBuilder: (item, _) => FeedCard(
                  item: item,
                  onTap: () => controller.openDetail(item),
                  onLike: () => controller.toggleLike(item),
                ),
              ),
              if (empty)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: PageStateView(type: PageStateType.empty),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
