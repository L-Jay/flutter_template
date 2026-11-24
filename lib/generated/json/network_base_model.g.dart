import 'package:flutter_template/generated/json/base/json_convert_content.dart';
import 'package:flutter_template/common/models/network_base_model.dart';

NetworkBaseModel $NetworkBaseModelFromJson(Map<String, dynamic> json) {
  final NetworkBaseModel networkBaseModel = NetworkBaseModel();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    networkBaseModel.code = code;
  }
  final String? message = jsonConvert.convert<String>(json['message']);
  if (message != null) {
    networkBaseModel.message = message;
  }
  return networkBaseModel;
}

Map<String, dynamic> $NetworkBaseModelToJson(NetworkBaseModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['message'] = entity.message;
  return data;
}

extension NetworkBaseModelExtension on NetworkBaseModel {
  NetworkBaseModel copyWith({
    int? code,
    String? message,
  }) {
    return NetworkBaseModel()
      ..code = code ?? this.code
      ..message = message ?? this.message;
  }
}