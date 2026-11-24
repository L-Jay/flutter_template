import '../common/common.dart';

class CartController extends GetxController {
  CartService get cart => CartService.to;

  void toggleAll() {
    cart.toggleAll(!cart.allSelected);
  }

  void toggleItem(CartItem item) {
    cart.toggleSelected(item);
  }

  void increase(CartItem item) {
    cart.changeQuantity(item, 1);
  }

  void decrease(CartItem item) {
    cart.changeQuantity(item, -1);
  }

  void remove(CartItem item) {
    cart.remove(item);
    EasyLoading.showToast(
      Get.l10n.removed,
    );
  }

  void openProduct(CartItem item) {
    RouterManager.pushNamed(
      Routers.productDetail,
      arguments: {'id': item.product.id},
    );
  }

  void checkout() {
    final List<CartItem> items = cart.selectedItems;
    if (items.isEmpty) {
      EasyLoading.showToast(
        Get.l10n.selectCheckoutItems,
      );
      return;
    }

    RouterManager.pushNamed(
      Routers.orderConfirm,
      arguments: {'items': items, 'fromCart': true},
    );
  }
}
