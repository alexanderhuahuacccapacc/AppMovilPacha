import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/parking_record_model.dart';
import '../models/parking_space_model.dart';
import '../models/vehicle_model.dart';
import '../services/api_client.dart';

class CocheraRepository {
  final ApiClient _api;

  CocheraRepository(this._api);

  // ── Espacios ──────────────────────────────────────────────

  Future<List<ParkingSpaceModel>> fetchEspacios() async {
    try {
      final res = await _api.dio.get('/cochera/espacios');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => ParkingSpaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ParkingSpaceModel>> fetchEspaciosAdmin() async {
    try {
      final res = await _api.dio.get('/admin/cochera/espacios');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => ParkingSpaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ParkingSpaceModel> createEspacio(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.dio.post('/admin/cochera/espacios', data: data);
      return ParkingSpaceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ParkingSpaceModel> updateEspacio(
      int id, Map<String, dynamic> data) async {
    try {
      final res =
          await _api.dio.put('/admin/cochera/espacios/$id', data: data);
      return ParkingSpaceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Vehículos ─────────────────────────────────────────────

  Future<List<VehicleModel>> fetchVehiculos() async {
    try {
      final res = await _api.dio.get('/admin/cochera/vehiculos');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Registros (IN/OUT) ────────────────────────────────────

  Future<List<ParkingRecordModel>> fetchActivos() async {
    try {
      final res = await _api.dio.get('/cochera/registros/activos');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => ParkingRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ParkingRecordModel>> fetchRegistrosAdmin() async {
    try {
      final res = await _api.dio.get('/admin/cochera/registros');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => ParkingRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ParkingRecordModel> registrarIngreso(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.dio.post('/cochera/ingreso', data: data);
      return ParkingRecordModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ParkingRecordModel> registrarSalida(
      int id, {Map<String, dynamic>? data}) async {
    try {
      final res =
          await _api.dio.put('/cochera/$id/salida', data: data ?? {});
      return ParkingRecordModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
