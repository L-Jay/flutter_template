import '../common/common.dart';
import 'coupon_controller.dart';

class CouponPage extends GetView<CouponController> {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CouponController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: CouponController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<CouponItem>(
          pageSize: 10,
          networkCallback: controller.fetchCoupons,
        ),
        tag: CouponController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.couponTitle)),
      body: GetBuilder<LJRefreshListViewController>(
        tag: CouponController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<CouponItem>(
                viewTag: CouponController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchCoupons,
                itemBuilder: (item, _) => _buildCoupon(context, item),
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

  Widget _buildCoupon(BuildContext context, CouponItem item) {
    final AppColors colors = context.colors;
    final bool usable = item.status == 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 104,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              color: usable ? colors.brandLight : colors.divider,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¥${_amountText(item.amount)}',
                    style: AppTextStyle.title(
                      usable ? colors.price : colors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.couponThreshold(_amountText(item.threshold)),
                    style: AppTextStyle.small(colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.body(
                        usable ? colors.textPrimary : colors.textHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.scope,
                      style: AppTextStyle.caption(colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.validUntil(item.validTo),
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: usable
                    ? AppButton(
                        title: context.l10n.useNow,
                        width: 72,
                        height: 32,
                        onPressed: controller.useCoupon,
                      )
                    : Text(
                        item.status == 1 ? context.l10n.used : context.l10n.expired,
                        style: AppTextStyle.caption(colors.textHint),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _amountText(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
