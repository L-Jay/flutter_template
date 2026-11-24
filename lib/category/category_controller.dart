import '../common/common.dart';

class CategoryController extends GetxController {
  static const String productTag = 'categoryProducts';

  final groups = <CategoryGroup>[].obs;
  final selectedGroupId = 0.obs;

  /// 切换分类期间右侧列表显示加载态（同时让列表重建、滚动回顶部）
  final switching = false.obs;
  final productsLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadGroups();
  }

  Future<void> loadGroups() async {
    final dynamic response = await LJNetwork.get(ApiUrl.categoryList);
    final List<CategoryGroup> list = parseList(
      response,
      CategoryGroup.fromJson,
    );
    if (list.isEmpty) return;

    groups.assignAll(list);
    selectedGroupId.value = list.first.id;
    _refreshProducts();
  }

  Future<List<Product>> fetchProducts(int page) async {
    if (selectedGroupId.value == 0) return [];

    if (page == 1) productsLoaded.value = false;

    final dynamic response = await LJNetwork.get(
      ApiUrl.productList,
      params: {'categoryId': selectedGroupId.value, 'page': page},
    );
    final List<Product> result = parseList(response, Product.fromJson);
    productsLoaded.value = true;
    return result;
  }

  Future<void> selectGroup(CategoryGroup group) async {
    if (selectedGroupId.value == group.id) return;

    selectedGroupId.value = group.id;
    switching.value = true;

    if (Get.isRegistered<LJRefreshListViewController>(tag: productTag)) {
      await Get.find<LJRefreshListViewController>(tag: productTag).fetchData(true);
    }

    switching.value = false;
  }

  void _refreshProducts() {
    if (!Get.isRegistered<LJRefreshListViewController>(tag: productTag)) return;

    Get.find<LJRefreshListViewController>(tag: productTag).fetchData(true);
  }

  void openSearch() {
    RouterManager.pushNamed(Routers.search);
  }

  void openProduct(Product product) {
    RouterManager.pushNamed(
      Routers.productDetail,
      arguments: {'id': product.id},
    );
  }
}
