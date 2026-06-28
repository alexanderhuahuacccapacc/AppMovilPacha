import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum VehicleType {
  auto,
  moto,
  camioneta,
  unknown;

  static VehicleType fromApi(String? value) {
    switch (value) {
      case 'AUTO':
        return VehicleType.auto;
      case 'MOTO':
        return VehicleType.moto;
      case 'CAMIONETA':
        return VehicleType.camioneta;
      default:
        return VehicleType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case VehicleType.auto:
        return 'AUTO';
      case VehicleType.moto:
        return 'MOTO';
      case VehicleType.camioneta:
        return 'CAMIONETA';
      case VehicleType.unknown:
        return 'AUTO';
    }
  }

  String get label {
    switch (this) {
      case VehicleType.auto:
        return 'Auto';
      case VehicleType.moto:
        return 'Moto';
      case VehicleType.camioneta:
        return 'Camioneta';
      case VehicleType.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.auto:
        return Icons.directions_car;
      case VehicleType.moto:
        return Icons.motorcycle;
      case VehicleType.camioneta:
        return Icons.local_shipping;
      case VehicleType.unknown:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (this) {
      case VehicleType.auto:
        return AppColors.primary;
      case VehicleType.moto:
        return AppColors.amber;
      case VehicleType.camioneta:
        return AppColors.chocolate;
      case VehicleType.unknown:
        return AppColors.textMuted;
    }
  }
}

class VehicleModel {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String? color;
  final VehicleType tipo;
  final DateTime? createdAt;

  const VehicleModel({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    this.color,
    required this.tipo,
    this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      placa: (json['placa'] ?? '') as String,
      marca: (json['marca'] ?? '') as String,
      modelo: (json['modelo'] ?? '') as String,
      color: json['color'] as String?,
      tipo: VehicleType.fromApi(json['tipo'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  String get placaCompleta =>
      '$marca $modelo${color != null ? ' ($color)' : ''} - $placa';
}
