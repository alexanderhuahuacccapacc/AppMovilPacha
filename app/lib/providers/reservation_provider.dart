import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/reservation_model.dart';
import '../repositories/reservation_repository.dart';

enum ReservationState { idle, loading, success, error, notFound }

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository _repo;

  ReservationProvider(this._repo);

  ReservationState _state = ReservationState.idle;
  ReservationModel? _reservation;
  String? _error;

  ReservationState get state => _state;
  ReservationModel? get reservation => _reservation;
  String? get error => _error;

  Future<void> loadMiReserva({bool force = false}) async {
    if (_state == ReservationState.loading) return;
    if (_state == ReservationState.success && !force) return;

    _state = ReservationState.loading;
    _error = null;
    notifyListeners();
    try {
      _reservation = await _repo.fetchMiReserva();
      _state = ReservationState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = ReservationState.notFound;
    }
    notifyListeners();
  }
}
