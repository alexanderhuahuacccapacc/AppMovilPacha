/// Mirrors Usuario.UsuarioRol on the backend.
enum UserRole {
  admin,
  recepcionista,
  guest,
  unknown;

  bool get isAdmin => this == UserRole.admin;
  bool get isGuest => this == UserRole.guest;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.recepcionista:
        return 'Recepcionista';
      case UserRole.guest:
        return 'Huésped';
      case UserRole.unknown:
        return 'Sin rol';
    }
  }

  /// Maps the raw string the backend sends in the login response
  /// ({"rol": "ROLE_ADMIN" | "ROLE_RECEPCIONISTA" | "ROLE_GUEST"}).
  static UserRole fromBackend(String? raw) {
    switch (raw) {
      case 'ROLE_ADMIN':
        return UserRole.admin;
      case 'ROLE_RECEPCIONISTA':
        return UserRole.recepcionista;
      case 'ROLE_GUEST':
        return UserRole.guest;
      default:
        return UserRole.unknown;
    }
  }
}