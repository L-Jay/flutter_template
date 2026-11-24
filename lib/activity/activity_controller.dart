import '../common/common.dart';

class ActivityController extends GetxController {
  static const String listTag = 'activityList';

  Future<List<ActivityItem>> fetchActivities(int page) async {
    final dynamic response = await LJNetwork.get(ApiUrl.activityList);
    return parseList(response, ActivityItem.fromJson);
  }

  void openActivity(ActivityItem item) {
    RouterManager.pushNamed(
      Routers.detail,
      arguments: {'title': item.title, 'cover': item.cover},
    );
  }
}
