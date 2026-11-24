import '../bottom_navigation/bottom_navigation_controller.dart';
import '../common/common.dart';

class CouponController extends GetxController {
  static const String listTag = 'couponList';

  Future<List<CouponItem>> fetchCoupons(int page) async {
    final dynamic response = await LJNetwork.get(ApiUrl.couponList);
    return parseList(response, CouponItem.fromJson);
  }

  /// 去使用：返回首页选购
  void useCoupon() {
    RouterManager.pop();
    Get.find<BottomNavigationController>().currentIndex.value = 0;
  }
}
