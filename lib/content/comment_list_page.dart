import '../common/common.dart';
import 'comment_list_controller.dart';

class CommentListPage extends GetView<CommentListController> {
  const CommentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CommentListController());

    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    controller.init(arguments['feedId']?.toString());

    if (!Get.isRegistered<LJRefreshListViewController>(
      tag: CommentListController.listTag,
    )) {
      Get.put<LJRefreshListViewController>(
        LJRefreshListViewController<CommentItem>(
          pageSize: 10,
          networkCallback: controller.fetchComments,
        ),
        tag: CommentListController.listTag,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.comments)),
      body: GetBuilder<LJRefreshListViewController>(
        tag: CommentListController.listTag,
        builder: (listController) {
          final bool empty = listController.list.isEmpty;

          return Stack(
            children: [
              LJRefreshListView<CommentItem>(
                viewTag: CommentListController.listTag,
                pageSize: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.page,
                ),
                networkCallback: controller.fetchComments,
                itemBuilder: (item, listController) => _buildComment(
                  context,
                  item,
                  index: listController.list.indexOf(item),
                  total: listController.list.length,
                ),
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

  /// 评论整体是一张大卡片：首条只有上圆角、末条只有下圆角，中间无圆角
  Widget _buildComment(
    BuildContext context,
    CommentItem item, {
    required int index,
    required int total,
  }) {
    final AppColors colors = context.colors;
    final bool isFirst = index == 0;
    final bool isLast = index == total - 1;
    final Radius radius = Radius.circular(AppSpacing.radiusMd);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? radius : Radius.zero,
          bottom: isLast ? radius : Radius.zero,
        ),
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LJNetworkImage(
            url: item.avatar,
            width: 36,
            height: 36,
            radius: 18,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.author,
                  style: AppTextStyle.caption(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.content,
                  style: AppTextStyle.body(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(item.time, style: AppTextStyle.small(colors.textHint)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 15,
                color: colors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.likes}',
                style: AppTextStyle.small(colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
