import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

/// Thin Dio wrapper que:
///  - maneja cookies HttpOnly automáticamente (sesión por cookie jwt=),
///  - señala pérdida de sesión a través de [onSessionExpired].
class ApiClient {
  late final Dio dio;
  late final PersistCookieJar _cookieJar;

  /// Invocado cuando el servidor responde 401 y la sesión expiró.
  void Function()? onSessionExpired;

  ApiClient({Dio? dioOverride}) {
    dio = dioOverride ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            contentType: 'application/json',
          ),
        );
  }

  /// Debe llamarse una vez en main() antes de usar la app.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    dio.interceptors.add(CookieManager(_cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: _onError,
      ),
    );
  }

  Future<void> _onError(
      DioException error,
      ErrorInterceptorHandler handler,
      ) async {
    final isAuthCall = error.requestOptions.path.contains('/auth/login');

    if (error.response?.statusCode == 401 && !isAuthCall) {
      onSessionExpired?.call();
    }
    handler.next(error);
  }

  /// Limpia todas las cookies guardadas (logout).
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  // ---------------------------------------------------------------------
  // Métodos HTTP genéricos usados por los repositories (auth, guest, etc.)
  // ---------------------------------------------------------------------

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.delete(path, data: data, queryParameters: queryParameters);
  }
}