import '../common/common.dart';
import 'favorites_controller.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => FavoritesController());
    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: FavoritesController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<FeedItem>(
          pageSize: 6,
          networkCallback: controller.fetchFavorites,
        ),
        tag: FavoritesController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myFavorites),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.toggleManaging,
              child: Text(controller.isManaging.value ? context.l10n.done : context.l10n.manage),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildList(context)),
          Obx(() {
            if (!controller.isManaging.value) return const SizedBox();

            return BottomContainer(
              height: 64,
              color: context.colors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.sm,
                ),
                child: AppButton(
                  title: context.l10n.deleteSelected(controller.selectedIds.length),
                  onPressed: controller.removeSelected,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return GetBuilder<LJRefreshListViewController>(
      tag: FavoritesController.listTag,
      builder: (listController) {
        final bool empty = listController.list.isEmpty;

        return Stack(
          children: [
            LJRefreshListView<FeedItem>(
              viewTag: FavoritesController.listTag,
              pageSize: 6,
              padding: const EdgeInsets.all(AppSpacing.page),
              networkCallback: controller.fetchFavorites,
              itemBuilder: (item, _) => Obx(() {
                final bool checked = controller.selectedIds.contains(item.id);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isManaging.value)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xl,
                          right: AppSpacing.sm,
                        ),
                        child: GestureDetector(
                          onTap: () => controller.toggleSelect(item),
                          child: Icon(
                            checked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: checked
                                ? context.colors.brand
                                : context.colors.textHint,
                          ),
                        ),
                      ),
                    Expanded(
                      child: FeedCard(
                        item: item,
                        onTap: () => controller.onItemTap(item),
                      ),
                    ),
                  ],
                );
              }),
            ),
            if (empty)
              Positioned.fill(
                child: IgnorePointer(
                  child: PageStateView(
                    type: PageStateType.empty,
                    message: context.l10n.favoritesEmpty,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
