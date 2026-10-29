import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Check your network and retry.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 404) {
          return const ApiException('Record not found.', statusCode: 404);
        }
        if (code != null && code >= 500) {
          return ApiException(
            'Server error ($code). Try again later.',
            statusCode: code,
          );
        }
        return ApiException('Request failed ($code).', statusCode: code);
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
