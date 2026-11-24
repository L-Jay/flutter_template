import '../common/common.dart';
import 'activity_controller.dart';

class ActivityPage extends GetView<ActivityController> {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ActivityController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: ActivityController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<ActivityItem>(
          pageSize: 10,
          networkCallback: controller.fetchActivities,
        ),
        tag: ActivityController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.activityTitle)),
      body: GetBuilder<LJRefreshListViewController>(
        tag: ActivityController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<ActivityItem>(
                viewTag: ActivityController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchActivities,
                itemBuilder: (item, _) => _buildActivity(context, item),
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

  Widget _buildActivity(BuildContext context, ActivityItem item) {
    final AppColors colors = context.colors;
    final Color statusColor = _statusColor(colors, item.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      onTap: () => controller.openActivity(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              LJNetworkImage(
                url: item.cover,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    _statusLabel(context, item.status),
                    style: AppTextStyle.small(Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: colors.textHint,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(item.time, style: AppTextStyle.small(colors.textHint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, int status) {
    switch (status) {
      case 0:
        return context.l10n.activityOngoing;
      case 1:
        return context.l10n.activityUpcoming;
      default:
        return context.l10n.activityEnded;
    }
  }

  Color _statusColor(AppColors colors, int status) {
    switch (status) {
      case 0:
        return colors.success;
      case 1:
        return colors.warning;
      default:
        return colors.textHint;
    }
  }
}
