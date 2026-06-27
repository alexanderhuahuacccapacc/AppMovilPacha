import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Mirrors Habitacion.Estado on the backend exactly — 4 values, all
/// UPPERCASE. PENDIENTE was missing from the original model; without it,
/// any room in that state silently fell into `unknown` everywhere
/// (badges, filters, dashboard counts).
enum RoomStatus {
  disponible,
  pendiente,
  //ocupada,
  finalizada,
  mantenimiento,
  unknown;

  // Backend real (ver HabitacionService.ESTADOS_VALIDOS) manda siempre
  // minúsculas: "libre", "pendiente", "ocupada", "mantenimiento".
  // El frontend Angular compara contra estos mismos strings
  // (h.estado === 'libre'), así que aquí hacemos lo mismo.
  static RoomStatus fromApi(String? value) {
    switch (value) {
      case 'libre':
        return RoomStatus.disponible;
      case 'pendiente':
        return RoomStatus.pendiente;
      case 'ocupada':
        return RoomStatus.finalizada;
      case 'mantenimiento':
        return RoomStatus.mantenimiento;
      default:
        return RoomStatus.unknown;
    }
  }

  /// Inverse of fromApi — needed when sending a status change back to
  /// PUT /api/admin/habitaciones/{id}. Debe mandar los mismos strings en
  /// minúscula que espera ESTADOS_VALIDOS en el backend.
  String get apiValue {
    switch (this) {
      case RoomStatus.disponible:
        return 'libre';
      case RoomStatus.pendiente:
        return 'pendiente';
      case RoomStatus.finalizada:
        return 'ocupada';
      case RoomStatus.mantenimiento:
        return 'mantenimiento';
      case RoomStatus.unknown:
        return 'libre';
    }
  }

  String get label {
    switch (this) {
      case RoomStatus.disponible:
        return 'Libre';
      case RoomStatus.pendiente:
        return 'Pendiente';
      case RoomStatus.finalizada:
        return 'Ocupada';
      case RoomStatus.mantenimiento:
        return 'Mantenimiento';
      case RoomStatus.unknown:
        return 'Desconocido';
    }
  }

  Color get color {
    switch (this) {
      case RoomStatus.disponible:
        return AppColors.success;
      case RoomStatus.pendiente:
        return AppColors.warning;
      case RoomStatus.finalizada:
        return AppColors.danger;
      case RoomStatus.mantenimiento:
        return AppColors.textMuted;
      case RoomStatus.unknown:
        return AppColors.textMuted;
    }
  }

  IconData get icon {
    switch (this) {
      case RoomStatus.disponible:
        return Icons.check_circle_outline;
      case RoomStatus.pendiente:
        return Icons.hourglass_empty;
      case RoomStatus.finalizada:
        return Icons.person_outline;
      case RoomStatus.mantenimiento:
        return Icons.build_outlined;
      case RoomStatus.unknown:
        return Icons.help_outline;
    }
  }
}

/// Hotel room. Field names match HabitacionDTO exactly — verified against
/// the real backend DTO, not assumed from the web screenshots.
class RoomModel {
  final int id;
  final String numero;
  final String nombre;
  final String tipo;
  final int capacidad;
  final double precioBase;
  final int? sizeM2;
  final String camas;
  final RoomStatus estado;
  final Map<String, bool> amenidades;
  final List<String> imagenes;

  const RoomModel({
    required this.id,
    required this.numero,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precioBase,
    required this.sizeM2,
    required this.camas,
    required this.estado,
    required this.amenidades,
    required this.imagenes,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      numero: (json['numero'] ?? '') as String,
      nombre: (json['nombre'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      capacidad: (json['capacidad'] ?? 0) as int,
      precioBase: double.tryParse('${json['precioBase']}') ?? 0,
      sizeM2: json['sizeM2'] as int?,
      camas: (json['camas'] ?? '') as String,
      estado: RoomStatus.fromApi(json['estado'] as String?),
      amenidades: (json['amenidades'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v == true)) ??
          const {},
      imagenes: (json['imagenes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
    );
  }

  /// First image, or '' if the room has none yet — convenient for list
  /// cards and the detail hero, which only show one image at a time.
  String get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : '';

  String get tipoLabel =>
      tipo.isEmpty ? '' : tipo[0].toUpperCase() + tipo.substring(1).toLowerCase();

  bool amenidad(String key) => amenidades[key] == true;
}