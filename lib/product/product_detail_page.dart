import '../common/common.dart';
import 'product_detail_controller.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    final int id = int.tryParse(arguments['id']?.toString() ?? '') ?? 0;

    Get.lazyPut(() => ProductDetailController(id));
    controller.ensureLoaded(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.productTitle),
        actions: [
          IconButton(
            onPressed: controller.share,
            icon: Icon(Icons.share_outlined, color: context.colors.textPrimary),
          ),
          _buildCartAction(context),
        ],
      ),
      body: Obx(() {
        final Product? product = controller.product.value;
        if (product == null) {
          return const PageStateView(type: PageStateType.loading);
        }

        return _buildContent(context, product);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.product.value == null) return const SizedBox();

        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildCartAction(BuildContext context) {
    final AppColors colors = context.colors;

    return Obx(() {
      final int count = CartService.to.totalCount;

      return IconButton(
        onPressed: controller.openCart,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.shopping_cart_outlined, color: colors.textPrimary),
            if (count > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.danger,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: AppTextStyle.small(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context, Product product) {
    final AppColors colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LJNetworkImage(
            url: product.cover,
            width: double.infinity,
            height: 320,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${product.price.toStringAsFixed(2)}',
                      style: AppTextStyle.display(colors.price),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '¥${product.originPrice.toStringAsFixed(2)}',
                      style: AppTextStyle.caption(colors.textHint).copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.salesCount(product.sales),
                      style: AppTextStyle.caption(colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  product.title,
                  style: AppTextStyle.title(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (controller.skus.isNotEmpty) ...[
                  _buildSkuEntry(context),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.productTitle,
                  style: AppTextStyle.headline(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.desc,
                  style: AppTextStyle.body(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkuEntry(BuildContext context) {
    final AppColors colors = context.colors;

    return GestureDetector(
      onTap: () => _showSkuSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Obx(() {
          final String name =
              controller.selectedSku.value?.name ?? context.l10n.selectSkuHint;

          return Row(
            children: [
              Text(context.l10n.spec, style: AppTextStyle.body(colors.textSecondary)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyle.body(colors.textPrimary),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textHint,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final AppColors colors = context.colors;

    return BottomContainer(
      height: 64,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                title: context.l10n.addToCart,
                type: AppButtonType.secondary,
                height: 44,
                onPressed: controller.addToCart,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                title: context.l10n.buyNow,
                height: 44,
                onPressed: controller.buyNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkuSheet(BuildContext context) {
    final AppColors colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.page),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetContext.l10n.selectSku,
                  style: AppTextStyle.headline(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(() {
                  return Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: controller.skus.map((sku) {
                      final bool selected =
                          controller.selectedSku.value?.id == sku.id;
                      final bool soldOut = sku.stock <= 0;

                      return GestureDetector(
                        onTap: soldOut
                            ? null
                            : () => controller.selectSku(sku),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? colors.brandLight : colors.bg,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: selected ? colors.brand : colors.divider,
                            ),
                          ),
                          child: Text(
                            soldOut
                                ? sheetContext.l10n.soldOutSuffix(sku.name)
                                : sku.name,
                            style: AppTextStyle.caption(
                              soldOut
                                  ? colors.textHint
                                  : (selected
                                        ? colors.brand
                                        : colors.textPrimary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  title: sheetContext.l10n.confirm,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
