import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/activiti_model.dart';
import '../models/room_model.dart';
import '../services/api_client.dart';

class RoomRepository {
  final ApiClient _api;

  RoomRepository(this._api);

  /// GET /api/public/habitaciones
  Future<List<RoomModel>> fetchAll() async {
    try {
      final res = await _api.dio.get('/public/habitaciones');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<RoomModel> fetchById(int id, {required bool isAdmin}) async {
    try {
      if (isAdmin) {
        final res = await _api.dio.get('/admin/habitaciones/$id');
        return RoomModel.fromJson(res.data as Map<String, dynamic>);
      }
      final all = await fetchAll();
      return all.firstWhere(
            (r) => r.id == id,
        orElse: () => throw ApiException('Habitación no encontrada', statusCode: 404),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<RoomModel>> fetchAllAdmin() async {
    try {
      final res = await _api.dio.get('/admin/habitaciones');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PUT /api/admin/habitaciones/{id}
  /// Ahora acepta también `camas` y `sizeM2`.
  Future<RoomModel> update(int id, Map<String, dynamic> fields) async {
    try {
      final res = await _api.dio.put('/admin/habitaciones/$id', data: fields);
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<RoomModel> updateEstado(int id, RoomStatus estado) {
    return update(id, {'estado': estado.apiValue});
  }

  Future<RoomModel> updateAmenidades(int id, Map<String, bool> amenidades) async {
    try {
      final res = await _api.dio.put(
        '/admin/habitaciones/$id/amenidades',
        data: amenidades,
      );
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/admin/habitaciones/actividad
  Future<List<ActividadModel>> fetchActividad() async {
    try {
      final res = await _api.dio.get('/admin/habitaciones/actividad');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => ActividadModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}