import '../core/errors/api_exception.dart';
import '../models/reservation_model.dart';
import '../models/parking_record_model.dart';
import '../services/api_client.dart';

class GuestRepository {
  final ApiClient _apiClient;

  GuestRepository(this._apiClient);

  Future<ReservationModel> getMyReservation() async {
    try {
      final response = await _apiClient.get(
        '/reservas/mis-reservas/',
      );

      final data = response.data;
      if (data == null || (data is List && data.isEmpty)) {
        throw const ApiException('No tienes una reserva activa');
      }

      final reservationData = data is List ? data.first : data;
      return ReservationModel.fromJson(reservationData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error al cargar tu reserva: $e');
    }
  }

  Future<ParkingRecordModel?> getMyParkingRecord() async {
    try {
      final response = await _apiClient.get(
        '/cocheras/mis-registros/',
      );

      final data = response.data;
      if (data == null || (data is List && data.isEmpty)) {
        return null;
      }

      final recordData = data is List ? data.first : data;
      return ParkingRecordModel.fromJson(recordData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error al cargar tu registro de cochera: $e');
    }
  }

  Future<ParkingRecordModel> registerVehicle({
    required String placa,
    required String marca,
    required String modelo,
    String? color,
    String? observacion,
  }) async {
    try {
      final vehicle = {
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'color': color,
        'observaciones': observacion,
        'tipo': 'AUTO',
      };

      final response = await _apiClient.post(
        '/cocheras/registrar/',
        data: vehicle,
      );

      return ParkingRecordModel.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error al registrar tu vehículo: $e');
    }
  }
}