import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum SpaceStatus {
  libre,
  ocupado,
  unknown;

  static SpaceStatus fromApi(String? value) {
    switch (value) {
      case 'LIBRE':
        return SpaceStatus.libre;
      case 'OCUPADO':
        return SpaceStatus.ocupado;
      default:
        return SpaceStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case SpaceStatus.libre:
        return 'LIBRE';
      case SpaceStatus.ocupado:
        return 'OCUPADO';
      case SpaceStatus.unknown:
        return 'LIBRE';
    }
  }

  String get label {
    switch (this) {
      case SpaceStatus.libre:
        return 'Libre';
      case SpaceStatus.ocupado:
        return 'Ocupado';
      case SpaceStatus.unknown:
        return 'Desconocido';
    }
  }

  Color get color {
    switch (this) {
      case SpaceStatus.libre:
        return AppColors.success;
      case SpaceStatus.ocupado:
        return AppColors.danger;
      case SpaceStatus.unknown:
        return AppColors.textMuted;
    }
  }

  IconData get icon {
    switch (this) {
      case SpaceStatus.libre:
        return Icons.check_circle_outline;
      case SpaceStatus.ocupado:
        return Icons.block;
      case SpaceStatus.unknown:
        return Icons.help_outline;
    }
  }
}

class ParkingSpaceModel {
  final int id;
  final String codigo;
  final String? ubicacion;
  final SpaceStatus estado;
  final DateTime? createdAt;

  const ParkingSpaceModel({
    required this.id,
    required this.codigo,
    this.ubicacion,
    required this.estado,
    this.createdAt,
  });

  factory ParkingSpaceModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpaceModel(
      id: json['id'] as int,
      codigo: (json['codigo'] ?? '') as String,
      ubicacion: json['ubicacion'] as String?,
      estado: SpaceStatus.fromApi(json['estado'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
