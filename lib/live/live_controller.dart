import '../common/common.dart';

class LiveController extends GetxController {
  static const String listTag = 'liveList';

  Future<List<LiveRoomItem>> fetchLiveRooms(int page) async {
    final dynamic response = await LJNetwork.get(ApiUrl.liveList);
    return parseList(response, LiveRoomItem.fromJson);
  }

  void openRoom(LiveRoomItem item) {
    RouterManager.pushNamed(
      Routers.detail,
      arguments: {'title': item.title, 'cover': item.cover},
    );
  }
}
