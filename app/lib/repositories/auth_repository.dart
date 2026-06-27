import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';

/// Auth data source. Habla con el backend Spring Boot.
///
/// El backend maneja la sesión por cookie HttpOnly (jwt=).
/// El login devuelve: { "email": "...", "rol": "ROLE_X", "message": "..." }
/// No hay tokens en el body — la cookie se guarda automáticamente por el CookieJar.
class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  /// POST /auth/login -> guarda cookie jwt= y devuelve datos del usuario
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      return UserModel.fromLoginResponse(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /auth/me -> valida sesión activa (cookie enviada automáticamente)
  Future<UserModel> me() async {
    try {
      final res = await _api.dio.get('/auth/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /auth/logout -> invalida la cookie en el servidor
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } on DioException {
      // Ignorar errores de logout — igual limpiamos local
    }
  }
}