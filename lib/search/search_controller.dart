import '../common/common.dart';

class SearchPageController extends GetxController {
  static const String listTag = 'searchList';
  static const String _historyKey = 'searchHistory';

  final TextEditingController textController = TextEditingController();
  final history = <String>[].obs;
  final searched = false.obs;

  String keyword = '';
  bool _keywordInited = false;

  @override
  void onInit() {
    super.onInit();

    history.assignAll(
      LJUtil.preferences.getStringList(_historyKey) ?? <String>[],
    );
  }

  /// 首帧后读取路由带来的关键词并自动搜索（如首页金刚区「新品」「热卖」）
  void initKeyword(String keyword) {
    if (_keywordInited) return;
    _keywordInited = true;

    final String text = keyword.trim();
    if (text.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) => submit(text));
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<List<Product>> fetchSearch(int page) async {
    if (keyword.isEmpty) return [];

    final dynamic response = await LJNetwork.get(
      ApiUrl.search,
      params: {'keyword': keyword, 'page': page},
    );
    return parseList(response, Product.fromJson);
  }

  void submit([String? value]) {
    final String text = (value ?? textController.text).trim();
    if (text.isEmpty) {
      EasyLoading.showToast(
        Get.l10n.searchEmpty,
      );
      return;
    }

    keyword = text;
    textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    searched.value = true;
    _saveHistory(text);

    final LJRefreshListViewController listController = Get.find(
      tag: listTag,
    );
    listController.fetchData(true);
  }

  void clearHistory() {
    history.clear();
    LJUtil.preferences.remove(_historyKey);
  }

  void openDetail(Product product) {
    RouterManager.pushNamed(
      Routers.productDetail,
      arguments: {'id': product.id},
    );
  }

  void _saveHistory(String text) {
    history.remove(text);
    history.insert(0, text);
    if (history.length > 10) history.removeRange(10, history.length);

    LJUtil.preferences.setStringList(_historyKey, history.toList());
  }
}
