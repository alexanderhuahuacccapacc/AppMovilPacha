/// Global, compile-time app configuration.
///
/// Override the base URL at build time without touching code:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000/api
class AppConfig {
  AppConfig._();

  /// Default points to the Django backend.
  ///
  /// - Android emulator reaches the host machine via 10.0.2.2
  /// - iOS simulator / desktop use localhost
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //defaultValue: 'http://10.0.2.2:8000/api',
    defaultValue: 'https://prod-back-pachasuite.onrender.com/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
