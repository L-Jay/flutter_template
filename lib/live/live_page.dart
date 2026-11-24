import '../common/common.dart';
import 'live_controller.dart';

class LivePage extends GetView<LiveController> {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LiveController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: LiveController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<LiveRoomItem>(
          pageSize: 10,
          networkCallback: controller.fetchLiveRooms,
        ),
        tag: LiveController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.liveTitle)),
      body: GetBuilder<LJRefreshListViewController>(
        tag: LiveController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<LiveRoomItem>(
                viewTag: LiveController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchLiveRooms,
                itemBuilder: (item, _) => _buildRoom(context, item),
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

  Widget _buildRoom(BuildContext context, LiveRoomItem item) {
    final AppColors colors = context.colors;
    final Color badgeColor = item.live ? colors.danger : colors.barrier;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      onTap: () => controller.openRoom(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              LJNetworkImage(
                url: item.cover,
                width: double.infinity,
                height: 170,
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
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.live) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        item.live ? context.l10n.living : item.time,
                        style: AppTextStyle.small(Colors.white),
                      ),
                    ],
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
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    LJNetworkImage(
                      url: item.avatar,
                      width: 24,
                      height: 24,
                      radius: 12,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.anchor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption(colors.textSecondary),
                      ),
                    ),
                    Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: colors.textHint,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _viewersText(context, item.viewers),
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _viewersText(BuildContext context, int viewers) {
    if (context.l10n.localeName == 'zh') {
      if (viewers >= 10000) {
        return context.l10n.viewersWan((viewers / 10000).toStringAsFixed(1));
      }
      return '$viewers';
    }
    if (viewers >= 1000) {
      return context.l10n.viewersK((viewers / 1000).toStringAsFixed(1));
    }
    return '$viewers';
  }
}
