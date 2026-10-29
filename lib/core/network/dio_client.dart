import 'package:dio/dio.dart';

import '../config/api_config.dart';

class DioClient {
  DioClient._();

  static Dio create() => Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
