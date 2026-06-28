import 'package:flutter/material.dart';

/// Una amenidad/servicio del hotel: la clave (`key`) coincide EXACTAMENTE
/// con las llaves del mapa `amenidades` del backend (HabitacionDTO), para
/// poder reutilizar este catálogo tanto en la lista de servicios (HU36)
/// como en los switches de amenidades por habitación.
class Amenity {
  final String key;
  final String nombre;
  final String descripcion;
  final IconData icon;

  const Amenity({
    required this.key,
    required this.nombre,
    required this.descripcion,
    required this.icon,
  });
}

/// Catálogo único de amenidades/servicios del hotel.
///
/// Las llaves (`internet`, `cableNetflix`, ...) son las mismas que usa el
/// backend en el JSON de `amenidades`, verificadas contra
/// `AdminHabitacionController.updateAmenidades`.
class AmenitiesCatalog {
  AmenitiesCatalog._();

  static const List<Amenity> all = [
    Amenity(
      key: 'internet',
      nombre: 'Internet Wi-Fi',
      descripcion: 'Conexión de alta velocidad en todas las áreas.',
      icon: Icons.wifi,
    ),
    Amenity(
      key: 'cableNetflix',
      nombre: 'Cable / Netflix',
      descripcion: 'TV con canales por cable y streaming incluido.',
      icon: Icons.tv_outlined,
    ),
    Amenity(
      key: 'banoPrivado',
      nombre: 'Baño privado',
      descripcion: 'Baño exclusivo con agua caliente las 24 horas.',
      icon: Icons.bathtub_outlined,
    ),
    Amenity(
      key: 'buffetAndino',
      nombre: 'Buffet Andino',
      descripcion: 'Desayuno buffet con productos locales de la región.',
      icon: Icons.restaurant_outlined,
    ),
    Amenity(
      key: 'cochera',
      nombre: 'Cochera',
      descripcion: 'Estacionamiento privado y vigilado para huéspedes.',
      icon: Icons.local_parking_outlined,
    ),
    Amenity(
      key: 'spa',
      nombre: 'Spa & Bienestar',
      descripcion: 'Zona de relajación, sauna y masajes a solicitud.',
      icon: Icons.spa_outlined,
    ),
  ];

  /// Búsqueda rápida por llave; útil para resolver íconos/nombres a partir
  /// del mapa de amenidades de una habitación.
  static Amenity? byKey(String key) {
    for (final a in all) {
      if (a.key == key) return a;
    }
    return null;
  }
}
