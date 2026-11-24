import '../common/common.dart';
import 'order_list_controller.dart';

class OrderPage extends GetView<OrderListController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => OrderListController());
    controller.initStatus(context.argumentMap?['status']?.toString());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: OrderListController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<OrderItem>(
          pageSize: 10,
          networkCallback: controller.fetchOrders,
        ),
        tag: OrderListController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myOrders)),
      body: Column(
        children: [
          _buildTabs(context),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final AppColors colors = context.colors;

    return Obx(() {
      return Container(
        height: 52,
        color: colors.surface,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        child: Row(
          children: OrderListController.statusTabs.map((tab) {
            final bool selected = controller.status.value == tab['key'];

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.selectStatus(tab['key']!),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? colors.brandLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      OrderListController.statusLabel(context, tab['key']!),
                      style: selected
                          ? AppTextStyle.body(colors.brand).copyWith(
                              fontWeight: medium,
                            )
                          : AppTextStyle.body(colors.textSecondary),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      // 切换 Tab 时先展示加载态，避免用户只看到旧列表以为是没切换
      if (controller.switching.value) {
        return PageStateView(
          type: PageStateType.loading,
          message: context.l10n.orderLoading,
        );
      }

      return GetBuilder<LJRefreshListViewController>(
        tag: OrderListController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<OrderItem>(
                viewTag: OrderListController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchOrders,
                itemBuilder: (item, _) => _buildItem(context, item),
              ),
              if (empty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: PageStateView(
                      type: PageStateType.empty,
                      message: context.l10n.orderEmpty,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }

  Widget _buildItem(BuildContext context, OrderItem item) {
    final AppColors colors = context.colors;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.orderNo(item.orderNo),
                  style: AppTextStyle.small(colors.textHint),
                ),
              ),
              Text(
                item.statusText,
                style: AppTextStyle.caption(colors.brand),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              LJNetworkImage(
                url: item.cover,
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
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.body(colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'x${item.quantity}',
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '¥${item.amount.toStringAsFixed(2)}',
                style: AppTextStyle.headline(colors.price),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
