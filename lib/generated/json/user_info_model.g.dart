import 'package:flutter_template/generated/json/base/json_convert_content.dart';
import 'package:flutter_template/common/models/user_info_model.dart';

UserInfoModel $UserInfoModelFromJson(Map<String, dynamic> json) {
  final UserInfoModel userInfoModel = UserInfoModel();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    userInfoModel.code = code;
  }
  final String? message = jsonConvert.convert<String>(json['message']);
  if (message != null) {
    userInfoModel.message = message;
  }
  final UserInfoData? data = jsonConvert.convert<UserInfoData>(json['data']);
  if (data != null) {
    userInfoModel.data = data;
  }
  return userInfoModel;
}

Map<String, dynamic> $UserInfoModelToJson(UserInfoModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['message'] = entity.message;
  data['data'] = entity.data?.toJson();
  return data;
}

extension UserInfoModelExtension on UserInfoModel {
  UserInfoModel copyWith({
    int? code,
    String? message,
    UserInfoData? data,
  }) {
    return UserInfoModel()
      ..code = code ?? this.code
      ..message = message ?? this.message
      ..data = data ?? this.data;
  }
}

UserInfoData $UserInfoDataFromJson(Map<String, dynamic> json) {
  final UserInfoData userInfoData = UserInfoData();
  final int? uid = jsonConvert.convert<int>(json['uid']);
  if (uid != null) {
    userInfoData.uid = uid;
  }
  final String? nickname = jsonConvert.convert<String>(json['nickname']);
  if (nickname != null) {
    userInfoData.nickname = nickname;
  }
  final String? mobile = jsonConvert.convert<String>(json['mobile']);
  if (mobile != null) {
    userInfoData.mobile = mobile;
  }
  final String? avatar = jsonConvert.convert<String>(json['avatar']);
  if (avatar != null) {
    userInfoData.avatar = avatar;
  }
  return userInfoData;
}

Map<String, dynamic> $UserInfoDataToJson(UserInfoData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['uid'] = entity.uid;
  data['nickname'] = entity.nickname;
  data['mobile'] = entity.mobile;
  data['avatar'] = entity.avatar;
  return data;
}

extension UserInfoDataExtension on UserInfoData {
  UserInfoData copyWith({
    int? uid,
    String? nickname,
    String? mobile,
    String? avatar,
  }) {
    return UserInfoData()
      ..uid = uid ?? this.uid
      ..nickname = nickname ?? this.nickname
      ..mobile = mobile ?? this.mobile
      ..avatar = avatar ?? this.avatar;
  }
}