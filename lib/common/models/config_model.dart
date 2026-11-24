
import 'dart:convert';

import 'package:flutter_template/generated/json/base/json_field.dart';
import 'package:flutter_template/generated/json/config_model.g.dart';

@JsonSerializable()
class ConfigModel {
	int? code;
	String? message;
	ConfigData? data;

	ConfigModel();

	factory ConfigModel.fromJson(Map<String, dynamic> json) => $ConfigModelFromJson(json);

	Map<String, dynamic> toJson() => $ConfigModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ConfigData {

	ConfigData();

	String? protocolUrl;
	String? privacyUrl;

	factory ConfigData.fromJson(Map<String, dynamic> json) => $ConfigDataFromJson(json);

	Map<String, dynamic> toJson() => $ConfigDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
