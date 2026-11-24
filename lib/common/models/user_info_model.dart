
import 'dart:convert';

import 'package:flutter_template/generated/json/base/json_field.dart';
import 'package:flutter_template/generated/json/user_info_model.g.dart';

@JsonSerializable()
class UserInfoModel {
	int? code;
	String? message;
	UserInfoData? data;

	UserInfoModel();

	factory UserInfoModel.fromJson(Map<String, dynamic> json) => $UserInfoModelFromJson(json);

	Map<String, dynamic> toJson() => $UserInfoModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class UserInfoData {
	int? uid;
	String? nickname;
	String? mobile;
	String? avatar;

	UserInfoData();

	factory UserInfoData.fromJson(Map<String, dynamic> json) => $UserInfoDataFromJson(json);

	Map<String, dynamic> toJson() => $UserInfoDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
