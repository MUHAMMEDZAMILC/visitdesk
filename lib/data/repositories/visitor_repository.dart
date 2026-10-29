import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/date_helper.dart';
import '../models/visitor.dart';

class VisitorRepository {
  final Dio _dio;

  VisitorRepository({Dio? dio}) : _dio = dio ?? DioClient.create();

  Future<List<Visitor>> getVisitors() => _guard(() async {
    final res = await _dio.get('/visitors');
    final data = res.data;
    if (data is! List) throw const FormatException('Expected a list');
    return data
        .map((e) => Visitor.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  Future<Visitor> getVisitor(String id) => _guard(() async {
    final res = await _dio.get('/visitors/$id');
    return Visitor.fromJson(res.data as Map<String, dynamic>);
  });

  Future<Visitor> createVisitor(Visitor visitor) => _guard(() async {
    final res = await _dio.post('/visitors', data: visitor.toJson());
    return Visitor.fromJson(res.data as Map<String, dynamic>);
  });

  Future<Visitor> updateVisitor(Visitor visitor) => _guard(() async {
    final res = await _dio.put(
      '/visitors/${visitor.id}',
      data: visitor.toEditJson(),
    );
    return Visitor.fromJson(res.data as Map<String, dynamic>);
  });

  Future<Visitor> checkIn(String id, DateTime time) => _guard(() async {
    final res = await _dio.patch(
      '/visitors/$id',
      data: {
        'status': VisitorStatus.checkedIn.label,
        'check_in_time': DateHelper.toIsoWithOffset(time),
      },
    );
    return Visitor.fromJson(res.data as Map<String, dynamic>);
  });

  Future<Visitor> checkOut(String id, DateTime time) => _guard(() async {
    final res = await _dio.patch(
      '/visitors/$id',
      data: {
        'status': VisitorStatus.checkedOut.label,
        'check_out_time': DateHelper.toIsoWithOffset(time),
      },
    );
    return Visitor.fromJson(res.data as Map<String, dynamic>);
  });

  Future<void> deleteVisitor(String id) =>
      _guard(() => _dio.delete('/visitors/$id'));

  /// Maps transport and parsing errors to [ApiException].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on FormatException {
      throw const ApiException('Invalid response from server.');
    } on TypeError {
      throw const ApiException('Invalid response from server.');
    }
  }
}
