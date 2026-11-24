import '../common/common.dart';
import 'about_us_page.dart';

class MineController extends GetxController {
  /// 我的订单四个状态入口
  final List<Map<String, String>> orderEntries = const [
    {'icon': 'pay', 'status': 'pay'},
    {'icon': 'send', 'status': 'send'},
    {'icon': 'receive', 'status': 'receive'},
    {'icon': 'done', 'status': 'done'},
  ];

  /// 已登录进入个人信息页，未登录去登录页
  void openProfile() {
    if (!UserService.to.isLogin.value) {
      RouterManager.pushNamed(Routers.login);
      return;
    }

    RouterManager.pushNamed(Routers.profile);
  }

  /// 相机/相册选图后更新头像（AvatarWidget 回调）
  Future<void> updateAvatar(String? localPath) {
    return UserService.to.updateAvatar(localPath);
  }

  void openOrder([String status = 'all']) {
    RouterManager.pushNamed(Routers.order, arguments: {'status': status});
  }

  void openMessage() {
    RouterManager.pushNamed(Routers.message);
  }

  void openFavorites() {
    RouterManager.pushNamed(Routers.favorites);
  }

  void openCart() {
    RouterManager.pushNamed(Routers.cart);
  }

  void openSetting() {
    RouterManager.pushNamed(Routers.setting);
  }

  void openAbout() {
    RouterManager.pushPage(const AboutUsPage());
  }

  void logout() {
    DialogUtil.normal(
      text: Get.l10n.logoutConfirm,
      confirmCallback: UserService.to.logout,
    );
  }
}
