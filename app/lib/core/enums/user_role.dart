/// Mirrors Usuario.UsuarioRol on the backend: only two roles exist for
/// hotel staff. Guests never log in — they're verified via the 6-digit
/// code flow (PublicController), not via /api/auth/login.
enum UserRole {
  admin,
  recepcionista,
  unknown;

  bool get isAdmin => this == UserRole.admin;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.recepcionista:
        return 'Recepcionista';
      case UserRole.unknown:
        return 'Sin rol';
    }
  }

  /// Maps the raw string the backend sends in the login response
  /// ({"rol": "ROLE_ADMIN" | "ROLE_RECEPCIONISTA"}).
  static UserRole fromBackend(String? raw) {
    switch (raw) {
      case 'ROLE_ADMIN':
        return UserRole.admin;
      case 'ROLE_RECEPCIONISTA':
        return UserRole.recepcionista;
      default:
        return UserRole.unknown;
    }
  }
}