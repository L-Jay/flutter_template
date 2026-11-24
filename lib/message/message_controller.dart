import '../common/common.dart';

class MessageController extends GetxController {
  static const String listTag = 'messageList';

  Future<List<MessageItem>> fetchMessages(int page) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.messageList,
      params: {'page': page},
    );
    return parseList(response, MessageItem.fromJson);
  }

  void openMessage(MessageItem item) {
    _markRead(item);

    final BuildContext? currentContext = Get.context;
    final AppColors colors = currentContext == null
        ? AppColors.light
        : currentContext.colors;

    DialogUtil.show(
      title: item.title,
      contentWidget: Text(
        item.content,
        style: AppTextStyle.body(colors.textSecondary),
      ),
      cancelTitle: null,
      confirmTitle: Get.l10n.gotIt,
    );
  }

  void markAllRead() {
    final LJRefreshListViewController listController = Get.find(
      tag: listTag,
    );

    for (int i = 0; i < listController.list.length; i++) {
      final MessageItem item = listController.list[i] as MessageItem;
      if (!item.read) listController.list[i] = item.copyWith(read: true);
    }
    listController.update();
  }

  void _markRead(MessageItem item) {
    final LJRefreshListViewController listController = Get.find(
      tag: listTag,
    );
    final int index = listController.list.indexWhere(
      (e) => (e as MessageItem).id == item.id,
    );
    if (index < 0) return;

    listController.list[index] = item.copyWith(read: true);
    listController.update();
  }
}
