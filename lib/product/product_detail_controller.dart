import '../common/common.dart';

class ProductDetailController extends GetxController {
  ProductDetailController(this.productId);

  final int productId;

  final product = Rxn<Product>();
  final skus = <Sku>[].obs;
  final selectedSku = Rxn<Sku>();

  int _loadedId = 0;

  /// 同一 Controller 被复用时，按 id 重新加载
  void ensureLoaded(int id) {
    if (_loadedId == id) return;

    _loadedId = id;
    product.value = null;
    skus.clear();
    selectedSku.value = null;
    load(id);
  }

  @override
  void onInit() {
    super.onInit();

    ensureLoaded(productId);
  }

  Future<void> load(int id) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.productDetail,
      params: {'id': id},
    );
    final Map<String, dynamic>? data = parseDataMap(response);
    if (data == null) return;

    product.value = Product.fromJson(data);

    final dynamic skuList = data['skus'];
    if (skuList is List) {
      skus.assignAll(
        skuList
            .whereType<Map>()
            .map((e) => Sku.fromJson(Map<String, dynamic>.from(e))),
      );
    }
    if (skus.isNotEmpty) selectedSku.value = skus.first;
  }

  void selectSku(Sku sku) {
    selectedSku.value = sku;
  }

  void addToCart() {
    final Product? current = product.value;
    if (current == null) return;

    CartService.to.add(current, sku: selectedSku.value);
    EasyLoading.showSuccess(
      Get.l10n.addedToCart,
    );
  }

  void buyNow() {
    final Product? current = product.value;
    if (current == null) return;

    RouterManager.pushNamed(
      Routers.orderConfirm,
      arguments: {
        'items': [CartItem(product: current, sku: selectedSku.value)],
        'fromCart': false,
      },
    );
  }

  void openCart() {
    RouterManager.pushNamed(Routers.cart);
  }

  void share() {
    final Product? current = product.value;
    if (current == null) return;

    ShareSheet.show(
      title: current.title,
      url: 'https://example.com/product/$productId',
    );
  }
}
