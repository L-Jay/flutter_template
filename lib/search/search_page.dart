import '../common/common.dart';
import 'search_controller.dart';

class SearchPage extends GetView<SearchPageController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SearchPageController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: SearchPageController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<Product>(
          pageSize: 6,
          networkCallback: controller.fetchSearch,
        ),
        tag: SearchPageController.listTag,
      );
    }

    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    controller.initKeyword(arguments['keyword']?.toString() ?? '');

    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: colors.textHint),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: controller.submit,
                  style: AppTextStyle.body(colors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minHeight: 0),
                    hintText: context.l10n.searchHint,
                    hintStyle: AppTextStyle.body(colors.textHint),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.submit,
            child: Text(context.l10n.searchAction),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.searched.value) return _buildHistory(context);
        return _buildResult(context);
      }),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final AppColors colors = context.colors;

    return Obx(() {
      if (controller.history.isEmpty) {
        return PageStateView(
          type: PageStateType.empty,
          message: context.l10n.searchNoHistory,
        );
      }

      return ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Row(
            children: [
              Text(
                context.l10n.searchHistory,
                style: AppTextStyle.headline(colors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.clearHistory,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: colors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.history.map((keyword) {
              return GestureDetector(
                onTap: () => controller.submit(keyword),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    keyword,
                    style: AppTextStyle.caption(colors.textSecondary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildResult(BuildContext context) {
    return GetBuilder<LJRefreshListViewController>(
      tag: SearchPageController.listTag,
      builder: (listController) {
        final bool empty = listController.list.isEmpty;

        return Stack(
          children: [
            LJRefreshGridView<Product>(
              viewTag: SearchPageController.listTag,
              pageSize: 6,
              itemRatio: 0.62,
              padding: const EdgeInsets.all(AppSpacing.md),
              networkCallback: controller.fetchSearch,
              itemBuilder: (product, _) => ProductCard(
                product: product,
                onTap: () => controller.openDetail(product),
              ),
            ),
            if (empty)
              Positioned.fill(
                child: IgnorePointer(
                  child: PageStateView(
                    type: PageStateType.empty,
                    message: context.l10n.searchNoResult,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
