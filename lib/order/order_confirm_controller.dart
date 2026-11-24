import '../common/common.dart';

class OrderConfirmController extends GetxController {
  OrderConfirmController({required this.items, required this.fromCart});

  final List<CartItem> items;
  final bool fromCart;

  final TextEditingController remarkController = TextEditingController();

  double get total {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (items.isEmpty) return;

    EasyLoading.show();
    await LJNetwork.post(
      ApiUrl.orderCreate,
      data: {
        'items': items
            .map(
              (item) => {
                'productId': item.product.id,
                'skuId': item.sku?.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
        'remark': remarkController.text.trim(),
      },
    );
    EasyLoading.dismiss();

    // 下单后弹出收银台，选择微信/支付宝模拟支付
    final bool paid = await PaySheet.show(amount: total);

    if (paid) {
      if (fromCart) CartService.to.clearSelected();
      EasyLoading.showSuccess(
        Get.l10n.paySuccess,
      );

      RouterManager.replaceNamed(
        Routers.order,
        arguments: {'status': 'all'},
      );
      return;
    }

    // 未支付：订单保留在待付款列表
    EasyLoading.showToast(
      Get.l10n.orderCreatedTip,
    );
    RouterManager.replaceNamed(
      Routers.order,
      arguments: {'status': 'pay'},
    );
  }
}
