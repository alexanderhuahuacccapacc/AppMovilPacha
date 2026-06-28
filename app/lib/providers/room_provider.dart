import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';

enum LoadState { idle, loading, success, error }

/// Holds the room list and the currently selected room detail.
class RoomProvider extends ChangeNotifier {
  final RoomRepository _repo;

  RoomProvider(this._repo);

  LoadState _listState = LoadState.idle;
  List<RoomModel> _rooms = [];
  String? _error;

  LoadState get listState => _listState;
  List<RoomModel> get rooms => _rooms;
  String? get error => _error;

  int get total => _rooms.length;
  int countByStatus(RoomStatus status) =>
      _rooms.where((r) => r.estado == status).length;

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

  /// Returns the cached room if present, otherwise fetches the detail.
  /// `isAdmin` decides which backend endpoint is used — there's no public
  /// single-room endpoint, only the full public list and the admin detail.
  Future<RoomModel> getRoom(int id, {required bool isAdmin}) async {
    final cached = _rooms.where((r) => r.id == id);
    if (cached.isNotEmpty) return cached.first;
    return _repo.fetchById(id, isAdmin: isAdmin);
  }

  /// Updates the local cache after an admin edit, so screens that already
  /// loaded the list reflect the change without a full refetch.
  void replaceInCache(RoomModel updated) {
    final idx = _rooms.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    _rooms[idx] = updated;
    notifyListeners();
  }

  /// HU "amenidades SI/NO": persiste el toggle de amenidades de una
  /// habitación (PUT /admin/habitaciones/{id}/amenidades) y refresca la
  /// caché local. Lanza [ApiException] si el backend rechaza el cambio.
  Future<void> setAmenidades(int id, Map<String, bool> amenidades) async {
    final updated = await _repo.updateAmenidades(id, amenidades);
    replaceInCache(updated);
  }

  // ── Crear habitación (demo local) ──
  //
  // El backend desplegado todavía no expone POST para crear habitaciones,
  // así que la nueva habitación solo se agrega a la lista en memoria. Se
  // pierde al cerrar la app; sirve para demostrar el formulario y la UI.
  int _localIdSeq = -1;

  /// id negativo y decreciente para no chocar con los ids reales del
  /// backend (siempre positivos).
  int get nextLocalId => _localIdSeq--;

  /// Agrega una habitación creada localmente al inicio de la lista.
  void addLocalRoom(RoomModel room) {
    _rooms = [room, ..._rooms];
    if (_listState != LoadState.success) _listState = LoadState.success;
    notifyListeners();
  }
}