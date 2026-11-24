import '../common/common.dart';
import 'category_controller.dart';

class CategoryPage extends GetView<CategoryController> {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CategoryController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: CategoryController.productTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<Product>(
          pageSize: 10,
          networkCallback: controller.fetchProducts,
        ),
        tag: CategoryController.productTag,
      );
    }

    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabProduct)),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 96, child: _buildGroupList(context)),
                Expanded(child: _buildProductGrid(context)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: colors.bg,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: GestureDetector(
        onTap: controller.openSearch,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: colors.textHint),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.searchHint,
                style: AppTextStyle.body(colors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList(BuildContext context) {
    final AppColors colors = context.colors;

    return Obx(() {
      // 在 builder 内先读一次，Obx 才能订阅到分类切换
      final int selectedId = controller.selectedGroupId.value;

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.groups.length,
        itemBuilder: (context, index) {
          final CategoryGroup group = controller.groups[index];
          final bool selected = selectedId == group.id;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.selectGroup(group),
            child: Container(
              height: 52,
              color: selected ? colors.surface : colors.bg,
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    color: selected ? colors.brand : Colors.transparent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      group.localizedName(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: selected
                          ? AppTextStyle.body(colors.brand)
                          : AppTextStyle.body(colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildProductGrid(BuildContext context) {
    return Obx(() {
      // 在 Obx 作用域内先读一次，切换分类的加载态才能被订阅
      final bool productsLoaded = controller.productsLoaded.value;

      // 切换分类时先展示加载态：既给出切换反馈，也让列表重建、滚动回到顶部
      if (controller.switching.value) {
        return PageStateView(
          type: PageStateType.loading,
          message: context.l10n.categoryLoading,
        );
      }

      return GetBuilder<LJRefreshListViewController>(
        tag: CategoryController.productTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;
          final bool loading = empty && !productsLoaded;

          return Stack(
            children: [
              LJRefreshGridView<Product>(
                viewTag: CategoryController.productTag,
                pageSize: 10,
                itemRatio: 0.62,
                padding: const EdgeInsets.all(AppSpacing.md),
                networkCallback: controller.fetchProducts,
                itemBuilder: (product, _) => ProductCard(
                  product: product,
                  onTap: () => controller.openProduct(product),
                ),
              ),
              if (loading)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: PageStateView(type: PageStateType.loading),
                  ),
                )
              else if (empty)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: PageStateView(type: PageStateType.empty),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}
