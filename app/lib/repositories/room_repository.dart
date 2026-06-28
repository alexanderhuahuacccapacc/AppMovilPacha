import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/room_model.dart';
import '../services/api_client.dart';

/// Rooms data source.
///
/// Two distinct sets of endpoints on the real backend:
///  - /api/public/habitaciones      -> no auth, anyone can read (guests)
///  - /api/admin/habitaciones/...   -> requires the jwt cookie + ROLE_ADMIN
///
/// RoomProvider currently only calls the public list (used by both the
/// Dashboard's counts and the Rooms screen for any logged-in staff). The
/// admin-only write methods (update, amenidades) are here so Sprint 6's
/// edit screens have something real to call instead of being built from
/// scratch later.
class RoomRepository {
  final ApiClient _api;

  RoomRepository(this._api);

  /// GET /api/public/habitaciones — full list, no auth required.
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

  /// There is no GET /api/public/habitaciones/{id} on the backend — only
  /// the full list and the admin-only detail. For a logged-in staff
  /// member (the only Flutter use case right now), the admin detail is
  /// the correct one to use; for an unauthenticated guest, fall back to
  /// finding it inside the public list.
  /// There is no GET /api/public/habitaciones/{id} on the backend — only
  /// the full list and the admin-only detail. For a logged-in staff
  /// member (the only Flutter use case right now), the admin detail is
  /// the correct one to use; for an unauthenticated guest, fall back to
  /// finding it inside the public list.
  Future<RoomModel> fetchById(int id, {required bool isAdmin}) async {
    try {
      if (isAdmin) {
        final res = await _api.dio.get('/admin/habitaciones/$id');
        return RoomModel.fromJson(res.data as Map<String, dynamic>);
      }
      final all = await fetchAll();
      return all.firstWhere(
            (r) => r.id == id,
        orElse: () => throw ApiException(
          'Habitación no encontrada',  // ✅ Posicional
          statusCode: 404,              // ✅ Nombrado
        ),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/admin/habitaciones — admin-only list (same data shape as
  /// public, but requires the session cookie). Useful if later you want
  /// admin screens to keep working even when a public field gets hidden.
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

  /// PUT /api/admin/habitaciones/{id} — nombre, precio, estado, etc.
  /// `fields` should only include the keys you want to change; matches
  /// HabitacionUpdateDTO on the backend.
  Future<RoomModel> update(int id, Map<String, dynamic> fields) async {
    try {
      final res = await _api.dio.put('/admin/habitaciones/$id', data: fields);
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Convenience wrapper around update() for the status chips
  /// (Libre/Pendiente/Ocupada/Mantenimiento) seen in the admin cards.
  Future<RoomModel> updateEstado(int id, RoomStatus estado) {
    return update(id, {'estado': estado.apiValue});
  }

  /// PUT /api/admin/habitaciones/{id}/amenidades — toggle switches.
  /// `amenidades` example: {"internet": true, "cochera": false}
  Future<RoomModel> updateAmenidades(
      int id,
      Map<String, bool> amenidades,
      ) async {
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
}