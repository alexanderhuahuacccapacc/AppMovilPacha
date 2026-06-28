import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/contact_message_model.dart';
import '../repositories/contact_repository.dart';

enum ContactState { idle, sending, success, error }

/// Maneja el envío del formulario de contacto (HU38).
class ContactProvider extends ChangeNotifier {
  final ContactRepository _repo;

  ContactProvider(this._repo);

  ContactState _state = ContactState.idle;
  String? _error;

  ContactState get state => _state;
  String? get error => _error;
  bool get isSending => _state == ContactState.sending;

  Future<bool> enviar(ContactMessage message) async {
    _state = ContactState.sending;
    _error = null;
    notifyListeners();
    try {
      await _repo.enviar(message);
      _state = ContactState.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _state = ContactState.error;
      notifyListeners();
      return false;
    }
  }

  /// Vuelve al estado inicial (por ej. al salir de la pantalla o reenviar).
  void reset() {
    _state = ContactState.idle;
    _error = null;
    notifyListeners();
  }
}
