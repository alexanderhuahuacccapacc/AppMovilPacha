import 'package:dio/dio.dart';

/// Normalized, user-presentable error for any API failure.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// Builds a friendly message from a Dio error, reading DRF error bodies.
  factory ApiException.fromDio(DioException error) {
    final int? status = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(
          'Tiempo de espera agotado. Revisa tu conexión.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No se pudo conectar con el servidor. Verifica la URL y tu red.',
        );
      default:
        break;
    }

    if (status == 401) {
      return const ApiException(
        'Credenciales inválidas o sesión expirada.',
        statusCode: 401,
      );
    }
    if (status == 403) {
      return const ApiException(
        'No tienes permisos para realizar esta acción.',
        statusCode: 403,
      );
    }

    final data = error.response?.data;
    if (data is Map) {
      if (data['detail'] is String) {
        return ApiException(data['detail'] as String, statusCode: status);
      }
      // DRF field errors: take the first available message.
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) {
          return ApiException(value.first.toString(), statusCode: status);
        }
        if (value is String) {
          return ApiException(value, statusCode: status);
        }
      }
    }

    return ApiException(
      'Ocurrió un error inesperado (${status ?? 'sin código'}).',
      statusCode: status,
    );
  }

  @override
  String toString() => message;
}
