import 'package:flutter_template/generated/json/base/json_convert_content.dart';
import 'package:flutter_template/common/models/config_model.dart';

ConfigModel $ConfigModelFromJson(Map<String, dynamic> json) {
  final ConfigModel configModel = ConfigModel();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    configModel.code = code;
  }
  final String? message = jsonConvert.convert<String>(json['message']);
  if (message != null) {
    configModel.message = message;
  }
  final ConfigData? data = jsonConvert.convert<ConfigData>(json['data']);
  if (data != null) {
    configModel.data = data;
  }
  return configModel;
}

Map<String, dynamic> $ConfigModelToJson(ConfigModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['message'] = entity.message;
  data['data'] = entity.data?.toJson();
  return data;
}

extension ConfigModelExtension on ConfigModel {
  ConfigModel copyWith({
    int? code,
    String? message,
    ConfigData? data,
  }) {
    return ConfigModel()
      ..code = code ?? this.code
      ..message = message ?? this.message
      ..data = data ?? this.data;
  }
}

ConfigData $ConfigDataFromJson(Map<String, dynamic> json) {
  final ConfigData configData = ConfigData();
  final String? protocolUrl = jsonConvert.convert<String>(json['protocolUrl']);
  if (protocolUrl != null) {
    configData.protocolUrl = protocolUrl;
  }
  final String? privacyUrl = jsonConvert.convert<String>(json['privacyUrl']);
  if (privacyUrl != null) {
    configData.privacyUrl = privacyUrl;
  }
  return configData;
}

Map<String, dynamic> $ConfigDataToJson(ConfigData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['protocolUrl'] = entity.protocolUrl;
  data['privacyUrl'] = entity.privacyUrl;
  return data;
}

extension ConfigDataExtension on ConfigData {
  ConfigData copyWith({
    String? protocolUrl,
    String? privacyUrl,
  }) {
    return ConfigData()
      ..protocolUrl = protocolUrl ?? this.protocolUrl
      ..privacyUrl = privacyUrl ?? this.privacyUrl;
  }
}