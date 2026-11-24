import 'package:get/get.dart';

import '../models/product_models.dart';

/// 购物车：纯内存状态，配合 `Obx` 使用。
class CartService extends GetxService {
  static CartService get to => Get.find();

  final items = <CartItem>[].obs;

  /// 商品总件数（用于角标）
  int get totalCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 已选中条目合计金额
  double get selectedTotal {
    return items
        .where((item) => item.selected)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get allSelected {
    return items.isNotEmpty && items.every((item) => item.selected);
  }

  List<CartItem> get selectedItems {
    return items.where((item) => item.selected).toList();
  }

  void add(Product product, {Sku? sku, int quantity = 1}) {
    final int index = items.indexWhere(
      (item) => item.product.id == product.id && item.sku?.id == sku?.id,
    );

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItem(product: product, sku: sku, quantity: quantity));
    }
    items.refresh();
  }

  void remove(CartItem item) {
    items.removeWhere(
      (e) => e.product.id == item.product.id && e.sku?.id == item.sku?.id,
    );
  }

  void changeQuantity(CartItem item, int delta) {
    final int index = items.indexOf(item);
    if (index < 0) return;

    final int quantity = items[index].quantity + delta;
    if (quantity <= 0) return;

    items[index] = items[index].copyWith(quantity: quantity);
    items.refresh();
  }

  void toggleSelected(CartItem item) {
    final int index = items.indexOf(item);
    if (index < 0) return;

    items[index] = items[index].copyWith(selected: !items[index].selected);
    items.refresh();
  }

  void toggleAll(bool value) {
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(selected: value);
    }
    items.refresh();
  }

  void clearSelected() {
    items.removeWhere((item) => item.selected);
  }
}
