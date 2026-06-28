/// Datos de contacto y ubicación del Hotel Pacha Suite.
///
/// Centralizados aquí para que la Pantalla de Contacto (HU37/39) y el mapa
/// (HU40) lean de una sola fuente. Ajusta estos valores a los reales del
/// hotel cuando los tengas — sobre todo [lat]/[lng] de la ubicación física.
class HotelInfo {
  HotelInfo._();

  static const String nombre = 'Hotel Pacha Suite';
  static const String direccion =
      'Av. El Sol 123, Cusco, Perú';
  static const String telefono = '+51 984 123 456';
  static const String email = 'contacto@pachasuite.com';

  /// Coordenadas usadas por el mapa embebido y por el botón
  /// "Abrir en Google Maps". Por defecto apuntan al centro del Cusco;
  /// reemplázalas por las del hotel.
  static const double lat = -13.516667;
  static const double lng = -71.978768;

  /// URL del mapa embebido (no requiere API key). Centrado en lat/lng.
  static String get mapaEmbedUrl =>
      'https://maps.google.com/maps?q=$lat,$lng&z=16&output=embed';

  /// URL que abre la app de Google Maps (o el navegador) en la ubicación.
  static String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}
