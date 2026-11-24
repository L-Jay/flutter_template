import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../activity/activity_page.dart';
import '../bottom_navigation/bottom_navigation_page.dart';
import '../cart/cart_page.dart';
import '../content/comment_list_page.dart';
import '../content/feed_detail_page.dart';
import '../coupon/coupon_page.dart';
import '../detail/detail_page.dart';
import '../favorite/favorites_page.dart';
import '../live/live_page.dart';
import '../login/login_page.dart';
import '../message/message_page.dart';
import '../mine/about_us_page.dart';
import '../mine/profile_page.dart';
import '../mine/setting_page.dart';
import '../order/order_confirm_page.dart';
import '../order/order_page.dart';
import '../product/product_detail_page.dart';
import '../search/search_page.dart';
import '../splash/splash_page.dart';
import '../vip/vip_page.dart';
import 'l10n_ext.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_style.dart';
import 'webview/webview_page.dart';

class Routers {
  static final unknownPage = GetPage(
    name: '/notFound',
    page: () => const UnknownRoutePage(),
  );

  static Map<String, PageBuilder> pages = {
    /// common
    splash: () => const SplashPage(),
    root: () => const BottomNavigationPage(),
    login: () => const LoginPage(),
    detail: () => const DetailPage(),
    webview: () => const WebViewPage(),

    /// mine
    order: () => const OrderPage(),
    profile: () => const ProfilePage(),
    setting: () => const SettingPage(),
    about: () => const AboutUsPage(),

    /// 消息
    message: () => const MessagePage(),

    /// 优惠券 / 活动 / 会员 / 直播
    coupon: () => const CouponPage(),
    activity: () => const ActivityPage(),
    vip: () => const VipPage(),
    live: () => const LivePage(),

    /// 搜索 / 收藏
    search: () => const SearchPage(),
    favorites: () => const FavoritesPage(),

    /// 商品 / 购物车 / 订单
    productDetail: () => const ProductDetailPage(),
    cart: () => const CartPage(),
    orderConfirm: () => const OrderConfirmPage(),

    /// 内容
    feedDetail: () => const FeedDetailPage(),
    commentList: () => const CommentListPage(),
  };

  static List<String> verifyLoginPageList = [
    order,
    profile,
    favorites,
    cart,
    orderConfirm,
  ];

  static String root = '/';
  static String login = '/login';
  static String splash = '/splash';
  static String detail = '/detail';
  static String webview = '/webview';

  // mine
  static String order = '/order';
  static String profile = '/profile';
  static String setting = '/setting';
  static String about = '/about';

  // message
  static String message = '/message';

  // coupon / activity / vip / live
  static String coupon = '/coupon';
  static String activity = '/activity';
  static String vip = '/vip';
  static String live = '/live';

  // search / favorites
  static String search = '/search';
  static String favorites = '/favorites';

  // product / cart / order
  static String productDetail = '/product/detail';
  static String cart = '/cart';
  static String orderConfirm = '/order/confirm';

  // content
  static String feedDetail = '/feed/detail';
  static String commentList = '/comments';
}

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          context.l10n.unknownRoute,
          style: AppTextStyle.body(context.colors.textPrimary),
        ),
      ),
    );
  }
}
