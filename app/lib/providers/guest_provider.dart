import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../models/parking_record_model.dart';
import '../repositories/guest_repository.dart';

enum GuestStatus { idle, loading, success, error }

class GuestProvider extends ChangeNotifier {
  final GuestRepository _repository;

  GuestProvider(this._repository);

  GuestStatus _status = GuestStatus.idle;
  String? _error;
  ReservationModel? _activeReservation;
  ParkingRecordModel? _activeParkingRecord;

  GuestStatus get status => _status;
  String? get error => _error;
  ReservationModel? get activeReservation => _activeReservation;
  ParkingRecordModel? get activeParkingRecord => _activeParkingRecord;
  bool get isLoading => _status == GuestStatus.loading;
  bool get hasActiveReservation => _activeReservation != null;

  Future<void> loadGuestData() async {
    _status = GuestStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final reservation = await _repository.getMyReservation();
      _activeReservation = reservation;

      final parkingRecord = await _repository.getMyParkingRecord();
      _activeParkingRecord = parkingRecord;

      _status = GuestStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = GuestStatus.error;
    }
    notifyListeners();
  }

  Future<void> registerVehicle({
    required String placa,
    required String marca,
    required String modelo,
    String? color,
    String? observacion,
  }) async {
    _status = GuestStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final record = await _repository.registerVehicle(
        placa: placa,
        marca: marca,
        modelo: modelo,
        color: color,
        observacion: observacion,
      );
      _activeParkingRecord = record;
      _status = GuestStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = GuestStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadGuestData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}