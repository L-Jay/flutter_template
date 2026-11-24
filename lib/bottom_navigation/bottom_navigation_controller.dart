import '../category/category_page.dart';
import '../common/common.dart';
import '../content/feed_list_page.dart';
import '../home/home_page.dart';
import '../mine/mine_page.dart';

class BottomNavigationController extends GetxController {
  final PageController pageController = PageController();
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    ever(currentIndex, (index) {
      pageController.jumpToPage(currentIndex.value);
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  final List<Widget> pages = const [
    KeepAliveWidget(child: HomePage()),
    KeepAliveWidget(child: CategoryPage()),
    KeepAliveWidget(child: FeedListPage()),
    KeepAliveWidget(child: MinePage()),
  ];
}
