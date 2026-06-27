import '../core/enums/user_role.dart';

/// Usuario autenticado.
///
/// El backend devuelve en login: { "email", "rol", "message" }
/// El backend devuelve en /me:   { "id", "nombre", "email", "rol" }
class UserModel {
  final int id;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Para la respuesta del login: { "email", "rol", "message" }
  factory UserModel.fromLoginResponse(Map<String, dynamic> json) {
    return UserModel(
      id: 0, // No viene en el login, se completa al llamar /me si se necesita
      name: (json['nombre'] ?? json['name'] ?? json['email'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: UserRole.fromBackend(json['rol'] as String?), // ← 'rol' no 'role'
    );
  }

  /// Para la respuesta de /me: { "id", "nombre", "email", "rol" }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['nombre'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: UserRole.fromBackend(json['rol'] as String?), // ← 'rol' no 'role'
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}