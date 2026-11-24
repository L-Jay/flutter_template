import '../common/common.dart';
import 'order_confirm_controller.dart';

class OrderConfirmPage extends GetView<OrderConfirmController> {
  const OrderConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    final List<CartItem> items =
        (arguments['items'] as List?)?.cast<CartItem>() ?? <CartItem>[];
    final bool fromCart = arguments['fromCart'] == true;

    Get.lazyPut(
      () => OrderConfirmController(items: items, fromCart: fromCart),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orderConfirmTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _buildAddress(context),
          const SizedBox(height: AppSpacing.md),
          _buildGoods(context),
          const SizedBox(height: AppSpacing.md),
          _buildRemark(context),
          const SizedBox(height: AppSpacing.md),
          _buildSummary(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAddress(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: colors.brand),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.orderDemoReceiver,
                  style: AppTextStyle.body(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.orderDemoAddress,
                  style: AppTextStyle.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colors.textHint,
          ),
        ],
      ),
    );
  }

  Widget _buildGoods(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < controller.items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LJNetworkImage(
                  url: controller.items[i].product.cover,
                  width: 64,
                  height: 64,
                  radius: AppSpacing.radiusSm,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.items[i].product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.body(colors.textPrimary),
                      ),
                      if (controller.items[i].skuName.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          controller.items[i].skuName,
                          style: AppTextStyle.small(colors.textHint),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${controller.items[i].unitPrice.toStringAsFixed(2)}',
                      style: AppTextStyle.body(colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'x${controller.items[i].quantity}',
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
              ],
            ),
            if (i != controller.items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRemark(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          Text(context.l10n.remark, style: AppTextStyle.body(colors.textPrimary)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: TextField(
              controller: controller.remarkController,
              textAlign: TextAlign.right,
              style: AppTextStyle.body(colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 0),
                hintText: context.l10n.remarkHint,
                hintStyle: AppTextStyle.body(colors.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final AppColors colors = context.colors;

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Text(label, style: AppTextStyle.caption(colors.textSecondary)),
            const Spacer(),
            Text(value, style: AppTextStyle.caption(colors.textPrimary)),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          row(context.l10n.goodsCountLabel, context.l10n.goodsCountValue(controller.totalCount)),
          row(context.l10n.goodsAmount, '¥${controller.total.toStringAsFixed(2)}'),
          row(context.l10n.freight, '¥0.00'),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Text(context.l10n.payable, style: AppTextStyle.body(colors.textPrimary)),
              const Spacer(),
              Text(
                '¥${controller.total.toStringAsFixed(2)}',
                style: AppTextStyle.title(colors.price),
              ),
            ],
          ),
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
            Text(context.l10n.total, style: AppTextStyle.caption(colors.textSecondary)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '¥${controller.total.toStringAsFixed(2)}',
              style: AppTextStyle.headline(colors.price),
            ),
            const Spacer(),
            AppButton(
              title: context.l10n.submitOrder,
              width: 128,
              height: 44,
              onPressed: controller.submit,
            ),
          ],
        ),
      ),
    );
  }
}
