import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../core/enums/user_role.dart';
import '../core/errors/api_exception.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Single source of truth para la sesión.
/// La autenticación se maneja por cookie HttpOnly (jwt=).
/// No se almacenan tokens en el dispositivo.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final ApiClient _apiClient;

  AuthProvider(this._repo, this._apiClient);

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  UserRole get role => _user?.role ?? UserRole.unknown;
  bool get isAdmin => role.isAdmin;
  bool get loading => _loading;
  String? get error => _error;

  /// Llamado al iniciar la app: valida si la cookie guardada sigue activa.
  Future<void> tryAutoLogin() async {
    try {
      _user = await _repo.me();
      _setStatus(AuthStatus.authenticated);
    } on ApiException {
      _setStatus(AuthStatus.unauthenticated);
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    print('🔑 Intentando login con: $email');
    print('🌐 URL: ${AppConfig.apiBaseUrl}/auth/login');

    try {
      // El CookieJar guarda automáticamente la cookie jwt= que devuelve el servidor
      _user = await _repo.login(email: email, password: password);
      print('✅ Login exitoso: ${_user!.email}');

      _loading = false;
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      print('❌ Error de API: ${e.message}');
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      _error = 'Error inesperado: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();          // invalida cookie en el servidor
    await _apiClient.clearCookies(); // limpia cookie local
    _user = null;
    _error = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  /// Disparado por ApiClient cuando recibe un 401 inesperado.
  void onSessionExpired() {
    _apiClient.clearCookies();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}