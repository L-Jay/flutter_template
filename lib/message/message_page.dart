import '../common/common.dart';
import 'message_controller.dart';

class MessagePage extends GetView<MessageController> {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MessageController());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: MessageController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<MessageItem>(
          pageSize: 10,
          networkCallback: controller.fetchMessages,
        ),
        tag: MessageController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.messageTitle),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text(context.l10n.markAllRead),
          ),
        ],
      ),
      body: GetBuilder<LJRefreshListViewController>(
        tag: MessageController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<MessageItem>(
                viewTag: MessageController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.all(AppSpacing.page),
                networkCallback: controller.fetchMessages,
                itemBuilder: (item, _) => _buildItem(context, item),
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

  Widget _buildItem(BuildContext context, MessageItem item) {
    final AppColors colors = context.colors;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => controller.openMessage(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: item.read ? Colors.transparent : colors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.body(
                          item.read ? colors.textSecondary : colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      item.time,
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
