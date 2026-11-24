import '../common/common.dart';

class CommentListController extends GetxController {
  static const String listTag = 'comments';

  int feedId = 0;
  bool _initialized = false;

  void init(String? id) {
    if (_initialized) return;
    _initialized = true;

    feedId = int.tryParse(id ?? '') ?? 1;
  }

  Future<List<CommentItem>> fetchComments(int page) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.commentList,
      params: {'feedId': feedId, 'page': page},
    );
    return parseList(response, CommentItem.fromJson);
  }
}
