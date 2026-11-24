import '../common.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final userInfoData = UserInfoData().obs;

  final _tokenKey = 'token';

  final _token = ''.obs;

  set token(String token) {
    LJUtil.preferences.setString(_tokenKey, token);
    _token.value = token;
  }

  String get token => _token.value;
  final isLogin = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(_token, _tokenChanged);

    _token.value = LJUtil.preferences.getString(_tokenKey) ?? '';
    isLogin.value = _token.value.isNotEmpty;
    if (isLogin.value) fetchUserInfo();
  }

  Future<void> _tokenChanged(String token) async {
    isLogin.value = _token.value.isNotEmpty;
    if (isLogin.value) {
      LJNetwork.headers.addAll({'Authorization': 'Bearer $_token'});
      await fetchUserInfo();
    } else {
      LJNetwork.headers.remove('Authorization');
    }
  }

  Future<void> fetchUserInfo() async {
    UserInfoModel model = await LJNetwork.get<UserInfoModel>(
      ApiUrl.userInfo,
    );
    if (model.data != null) {
      userInfoData.value = model.data!;
      final int? uid = model.data!.uid;
      if (uid != null) PushService.to.bindAlias(uid);
    }
  }

  /// 更新头像：mock 上传后返回远端地址（本地图片路径无法直接作为网络图展示）
  Future<void> updateAvatar(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return;

    final String remoteUrl =
        'https://picsum.photos/seed/${localPath.hashCode.abs()}/200/200';
    await LJNetwork.post(ApiUrl.userUpdate, data: {'avatar': remoteUrl});

    userInfoData.value.avatar = remoteUrl;
    userInfoData.refresh();
    EasyLoading.showSuccess(
      Get.l10n.avatarUpdated,
    );
  }

  Future<bool>? _refreshing;

  /// 刷新 token：并发请求共用同一次刷新，避免重复刷新。
  /// 刷新成功后 token 变化会自动重新拉取用户信息；原请求不会自动重发，
  /// 业务页如需立即刷新数据，可监听用户信息变化重新请求。
  Future<bool> refreshToken() {
    return _refreshing ??= _doRefreshToken().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<bool> _doRefreshToken() {
    return completer<bool>((complete) {
      LJNetwork.post(
        ApiUrl.refreshToken,
        addHeaders: {'Authorization': 'Bearer $token'},
        successCallback: (Map value) {
          var data = value['data'];
          String? newToken = data is Map ? data['access_token'] as String? : null;
          if (newToken?.isNotEmpty == true) {
            token = newToken!;
            complete.complete(true);
          } else {
            complete.complete(false);
          }
        },
        failureCallback: (error) {
          complete.complete(false);
        },
      );
    });
  }

  void logout() {
    bool wasLogin = isLogin.value;

    // 先清本地状态，避免退出接口本身过期时再次触发刷新
    _token.value = '';
    isLogin.value = false;
    userInfoData.value = UserInfoData();
    LJUtil.preferences.remove(_tokenKey);
    PushService.to.unbindAlias();

    if (wasLogin) LJNetwork.post(ApiUrl.logout);
  }
}
