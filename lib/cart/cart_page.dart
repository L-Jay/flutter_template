import '../common/common.dart';
import 'cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CartController());

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.cartTitle)),
      body: Obx(() {
        final List<CartItem> items = controller.cart.items;
        if (items.isEmpty) {
          return PageStateView(
            type: PageStateType.empty,
            message: context.l10n.cartEmpty,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.page),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _buildItem(context, items[index]),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cart.items.isEmpty) return const SizedBox();

        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildItem(BuildContext context, CartItem item) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.toggleItem(item),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Icon(
                item.selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: item.selected ? colors.brand : colors.textHint,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () => controller.openProduct(item),
            child: LJNetworkImage(
              url: item.product.cover,
              width: 80,
              height: 80,
              radius: AppSpacing.radiusSm,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.body(colors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.remove(item),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
                if (item.skuName.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.skuName,
                    style: AppTextStyle.small(colors.textHint),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '¥${item.unitPrice.toStringAsFixed(2)}',
                        style: AppTextStyle.headline(colors.price),
                      ),
                    ),
                    _buildStepper(context, item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context, CartItem item) {
    final AppColors colors = context.colors;

    Widget button(IconData icon, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 16, color: colors.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, () => controller.decrease(item)),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '${item.quantity}',
                style: AppTextStyle.caption(colors.textPrimary),
              ),
            ),
          ),
          button(Icons.add_rounded, () => controller.increase(item)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final AppColors colors = context.colors;

    return BottomContainer(
      height: 68,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.toggleAll,
              child: Row(
                children: [
                  Icon(
                    controller.cart.allSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: controller.cart.allSelected
                        ? colors.brand
                        : colors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.selectAll,
                    style: AppTextStyle.caption(colors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(context.l10n.total, style: AppTextStyle.small(colors.textHint)),
                Text(
                  '¥${controller.cart.selectedTotal.toStringAsFixed(2)}',
                  style: AppTextStyle.headline(colors.price),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            AppButton(
              title: context.l10n.checkout,
              width: 112,
              height: 44,
              onPressed: controller.checkout,
            ),
          ],
        ),
      ),
    );
  }
}
