import '../common/common.dart';

class FeedDetailController extends GetxController {
  final Rxn<FeedItem> feed = Rxn<FeedItem>();
  final List<CommentItem> comments = <CommentItem>[].obs;
  final TextEditingController inputController = TextEditingController();

  int feedId = 0;
  bool _initialized = false;

  void init(String? id) {
    if (_initialized) return;
    _initialized = true;

    feedId = int.tryParse(id ?? '') ?? 1;
    loadDetail();
  }

  Future<void> loadDetail() async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.feedDetail,
      params: {'id': feedId},
    );
    final Map<String, dynamic>? data = parseDataMap(response);
    if (data != null) feed.value = FeedItem.fromJson(data);

    await loadPreviewComments();
  }

  /// 详情页只展示前 3 条评论，完整列表走评论列表页
  Future<void> loadPreviewComments() async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.commentList,
      params: {'feedId': feedId, 'page': 1},
    );
    final List<CommentItem> list = parseList(
      response,
      CommentItem.fromJson,
    );
    comments.assignAll(list.take(3));
  }

  void toggleLike() {
    final FeedItem? current = feed.value;
    if (current == null) return;

    feed.value = current.copyWith(
      liked: !current.liked,
      likes: current.likes + (current.liked ? -1 : 1),
    );

    LJNetwork.post(ApiUrl.feedLike, data: {'id': current.id});
  }

  void toggleFavorite() {
    final FeedItem? current = feed.value;
    if (current == null) return;

    final bool favorited = !current.favorited;
    feed.value = current.copyWith(favorited: favorited);

    LJNetwork.post(ApiUrl.feedFavorite, data: {'id': current.id});
    EasyLoading.showSuccess(
      favorited ? Get.l10n.feedFavorited : Get.l10n.feedUnfavorited,
    );
  }

  void share() {
    final FeedItem? current = feed.value;
    if (current == null) return;

    ShareSheet.show(
      title: current.content,
      url: 'https://example.com/feed/${current.id}',
    );
  }

  Future<void> sendComment() async {
    final String text = inputController.text.trim();
    if (text.isEmpty) {
      EasyLoading.showInfo(
        Get.l10n.commentInputEmpty,
      );
      return;
    }

    await LJNetwork.post(
      ApiUrl.commentCreate,
      data: {'feedId': feedId, 'content': text},
    );

    comments.insert(
      0,
      CommentItem(
        id: DateTime.now().millisecondsSinceEpoch,
        author: Get.l10n.commentMe,
        avatar: '',
        content: text,
        time: Get.l10n.justNow,
      ),
    );
    inputController.clear();
  }

  void openComments() {
    RouterManager.pushNamed(
      Routers.commentList,
      arguments: {'feedId': feedId},
    );
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }
}
