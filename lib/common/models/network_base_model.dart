import 'dart:convert';
import 'package:flutter_template/generated/json/base/json_field.dart';
import 'package:flutter_template/generated/json/network_base_model.g.dart';

@JsonSerializable()
class NetworkBaseModel {
	int? code;
	String? message;

	NetworkBaseModel();

	factory NetworkBaseModel.fromJson(Map<String, dynamic> json) => $NetworkBaseModelFromJson(json);

	Map<String, dynamic> toJson() => $NetworkBaseModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
