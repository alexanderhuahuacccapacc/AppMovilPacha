import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cached session info: {email, rol}.
///
/// IMPORTANT — this does NOT store any token. The real session lives in
/// the httpOnly cookie that ApiClient's cookie jar manages. This is only
/// a local cache so the UI has something to render immediately on launch
/// without waiting on a network call (there's no /api/auth/me to refetch
/// it from). If the cookie is actually expired/invalid, the next API call
/// will get a 401/403 and ApiClient will call AuthProvider.onSessionExpired,
/// clearing this cache too.
class CachedSession {
  final String email;
  final String rol;

  const CachedSession({required this.email, required this.rol});
}

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Keys para session (email/rol)
  static const _kEmail = 'session_email';
  static const _kRol = 'session_rol';

  // Keys para tokens JWT
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  // ============================================
  // MÉTODOS PARA SESSION (EMAIL/ROL)
  // ============================================

  Future<void> saveSession({required String email, required String rol}) async {
    await _storage.write(key: _kEmail, value: email);
    await _storage.write(key: _kRol, value: rol);
  }

  Future<CachedSession?> readSession() async {
    final email = await _storage.read(key: _kEmail);
    final rol = await _storage.read(key: _kRol);
    if (email == null || rol == null) return null;
    return CachedSession(email: email, rol: rol);
  }

  Future<bool> hasSession() async {
    final email = await _storage.read(key: _kEmail);
    return email != null;
  }

  // ============================================
  // MÉTODOS PARA TOKENS JWT (NUEVOS)
  // ============================================

  /// Guarda ambos tokens (access y refresh)
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _kAccessToken, value: access);
    await _storage.write(key: _kRefreshToken, value: refresh);
  }

  /// Lee el access token
  Future<String?> readAccess() async {
    return await _storage.read(key: _kAccessToken);
  }

  /// Lee el refresh token
  Future<String?> readRefresh() async {
    return await _storage.read(key: _kRefreshToken);
  }

  /// Guarda solo el access token (usado después de refresh)
  Future<void> saveAccess(String token) async {
    await _storage.write(key: _kAccessToken, value: token);
  }

  /// Guarda solo el refresh token
  Future<void> saveRefresh(String token) async {
    await _storage.write(key: _kRefreshToken, value: token);
  }

  // ============================================
  // MÉTODO PARA LIMPIAR TODO
  // ============================================

  Future<void> clear() async {
    // Limpiar session (email/rol)
    await _storage.delete(key: _kEmail);
    await _storage.delete(key: _kRol);

    // Limpiar tokens
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }
}