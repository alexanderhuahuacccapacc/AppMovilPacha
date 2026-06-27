/// Reusable form validators for the auth flow.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El email es obligatorio';
    if (!_emailRegex.hasMatch(v)) return 'Formato de email inválido';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}
