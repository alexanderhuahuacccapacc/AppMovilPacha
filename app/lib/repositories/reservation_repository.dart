import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/reservation_model.dart';
import '../services/api_client.dart';

class ReservationRepository {
  final ApiClient _api;

  ReservationRepository(this._api);

  Future<ReservationModel> fetchMiReserva() async {
    try {
      final res = await _api.dio.get('/reservas/mi-reserva');
      return ReservationModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
