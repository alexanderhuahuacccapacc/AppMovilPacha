import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/contact_message_model.dart';
import '../services/api_client.dart';

/// Fuente de datos para los mensajes de contacto.
///
/// El backend expone el POST de forma pública (sin auth):
///   POST /api/mensajes-contacto  -> crea el mensaje (HTTP 201)
/// Como `ApiClient.baseUrl` ya incluye `/api`, aquí usamos
/// `/mensajes-contacto`.
class ContactRepository {
  final ApiClient _api;

  ContactRepository(this._api);

  Future<void> enviar(ContactMessage message) async {
    try {
      await _api.dio.post('/mensajes-contacto', data: message.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
