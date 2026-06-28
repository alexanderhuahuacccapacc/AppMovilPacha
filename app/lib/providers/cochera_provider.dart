import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/parking_record_model.dart';
import '../models/parking_space_model.dart';
import '../models/vehicle_model.dart';
import '../repositories/cochera_repository.dart';

enum CocheraLoadState { idle, loading, success, error }

class CocheraProvider extends ChangeNotifier {
  final CocheraRepository _repo;

  CocheraProvider(this._repo);

  // ── Espacios ──────────────────────────────────────────────

  CocheraLoadState _espaciosState = CocheraLoadState.idle;
  List<ParkingSpaceModel> _espacios = [];
  String? _error;

  CocheraLoadState get espaciosState => _espaciosState;
  List<ParkingSpaceModel> get espacios => _espacios;
  String? get error => _error;

  int get espaciosLibres =>
      _espacios.where((e) => e.estado == SpaceStatus.libre).length;
  int get espaciosOcupados =>
      _espacios.where((e) => e.estado == SpaceStatus.ocupado).length;

  Future<void> loadEspacios({bool force = false}) async {
    if (_espaciosState == CocheraLoadState.loading) return;
    if (_espaciosState == CocheraLoadState.success && !force) return;

    _espaciosState = CocheraLoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _espacios = await _repo.fetchEspacios();
      _espaciosState = CocheraLoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _espaciosState = CocheraLoadState.error;
    }
    notifyListeners();
  }

  // ── Registros activos ─────────────────────────────────────

  CocheraLoadState _activosState = CocheraLoadState.idle;
  List<ParkingRecordModel> _activos = [];

  CocheraLoadState get activosState => _activosState;
  List<ParkingRecordModel> get activos => _activos;

  Future<void> loadActivos({bool force = false}) async {
    if (_activosState == CocheraLoadState.loading) return;
    if (_activosState == CocheraLoadState.success && !force) return;

    _activosState = CocheraLoadState.loading;
    notifyListeners();
    try {
      _activos = await _repo.fetchActivos();
      _activosState = CocheraLoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _activosState = CocheraLoadState.error;
    }
    notifyListeners();
  }

  // ── Vehículos ─────────────────────────────────────────────

  CocheraLoadState _vehiculosState = CocheraLoadState.idle;
  List<VehicleModel> _vehiculos = [];

  CocheraLoadState get vehiculosState => _vehiculosState;
  List<VehicleModel> get vehiculos => _vehiculos;

  Future<void> loadVehiculos({bool force = false}) async {
    if (_vehiculosState == CocheraLoadState.loading) return;
    if (_vehiculosState == CocheraLoadState.success && !force) return;

    _vehiculosState = CocheraLoadState.loading;
    notifyListeners();
    try {
      _vehiculos = await _repo.fetchVehiculos();
      _vehiculosState = CocheraLoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _vehiculosState = CocheraLoadState.error;
    }
    notifyListeners();
  }

  // ── Ingreso / Salida ──────────────────────────────────────

  Future<ParkingRecordModel> registrarIngreso(
      Map<String, dynamic> data) async {
    final record = await _repo.registrarIngreso(data);
    _activos.add(record);
    _espaciosState = CocheraLoadState.idle;
    notifyListeners();
    return record;
  }

  Future<ParkingRecordModel> registrarSalida(
      int id, {Map<String, dynamic>? data}) async {
    final record = await _repo.registrarSalida(id, data: data);
    _activos.removeWhere((r) => r.id == id);
    _espaciosState = CocheraLoadState.idle;
    notifyListeners();
    return record;
  }

  void refresh() {
    _espaciosState = CocheraLoadState.idle;
    _activosState = CocheraLoadState.idle;
    _vehiculosState = CocheraLoadState.idle;
    notifyListeners();
  }
}
