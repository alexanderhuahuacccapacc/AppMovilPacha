import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/activiti_model.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';

enum LoadState { idle, loading, success, error }

class RoomProvider extends ChangeNotifier {
  final RoomRepository _repo;

  RoomProvider(this._repo);

  // ── Rooms ──
  LoadState _listState = LoadState.idle;
  List<RoomModel> _rooms = [];
  String? _error;

  LoadState get listState => _listState;
  List<RoomModel> get rooms => _rooms;
  String? get error => _error;

  int get total => _rooms.length;
  int countByStatus(RoomStatus status) =>
      _rooms.where((r) => r.estado == status).length;

  // ── Actividad reciente ──
  LoadState _actividadState = LoadState.idle;
  List<ActividadModel> _actividad = [];

  LoadState get actividadState => _actividadState;
  List<ActividadModel> get actividad => _actividad;

  Future<void> loadRooms({bool force = false}) async {
    if (_listState == LoadState.loading) return;
    if (_listState == LoadState.success && !force) return;

    _listState = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _rooms = await _repo.fetchAll();
      _listState = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _listState = LoadState.error;
    }
    notifyListeners();
  }

  Future<RoomModel> getRoom(int id, {required bool isAdmin}) async {
    final cached = _rooms.where((r) => r.id == id);
    if (cached.isNotEmpty) return cached.first;
    return _repo.fetchById(id, isAdmin: isAdmin);
  }

  void replaceInCache(RoomModel updated) {
    final idx = _rooms.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    _rooms[idx] = updated;
    notifyListeners();
  }

  Future<void> loadActividad({bool force = false}) async {
    if (_actividadState == LoadState.loading) return;
    if (_actividadState == LoadState.success && !force) return;

    _actividadState = LoadState.loading;
    notifyListeners();
    try {
      _actividad = await _repo.fetchActividad();
      _actividadState = LoadState.success;
    } on ApiException {
      _actividadState = LoadState.error;
    }
    notifyListeners();
  }
}