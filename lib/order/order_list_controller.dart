import '../common/common.dart';

class OrderListController extends GetxController {
  static const String listTag = 'orderList';

  /// 订单状态 Tab：key 与接口参数一致
  static const List<Map<String, String>> statusTabs = [
    {'key': 'all'},
    {'key': 'pay'},
    {'key': 'send'},
    {'key': 'receive'},
    {'key': 'done'},
  ];

  static String statusLabel(BuildContext context, String key) {
    switch (key) {
      case 'pay':
        return context.l10n.orderStatusPending;
      case 'send':
        return context.l10n.orderStatusToShip;
      case 'receive':
        return context.l10n.orderStatusToReceive;
      case 'done':
        return context.l10n.orderStatusDone;
      default:
        return context.l10n.all;
    }
  }

  final status = 'all'.obs;

  /// 切换 Tab 期间列表区显示加载态，让切换动作有明确反馈
  final switching = false.obs;

  bool _statusInitialized = false;

  /// 首次进入按路由参数定位 Tab，只生效一次
  void initStatus(String? value) {
    if (_statusInitialized) return;
    _statusInitialized = true;

    if (value == null || value.isEmpty) return;
    if (!statusTabs.any((e) => e['key'] == value)) return;
    status.value = value;
  }

  Future<List<OrderItem>> fetchOrders(int page) async {
    final dynamic response = await LJNetwork.get(
      ApiUrl.orderList,
      params: {'status': status.value, 'page': page},
    );
    return parseList(response, OrderItem.fromJson);
  }

  Future<void> selectStatus(String key) async {
    if (status.value == key) return;

    status.value = key;
    switching.value = true;

    if (Get.isRegistered<LJRefreshListViewController>(tag: listTag)) {
      await Get.find<LJRefreshListViewController>(tag: listTag).fetchData(true);
    }

    switching.value = false;
  }

  void openProduct(OrderItem item) {
    RouterManager.pushNamed(
      Routers.productDetail,
      arguments: {'id': item.id},
    );
  }
}
