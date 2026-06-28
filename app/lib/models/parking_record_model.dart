import 'vehicle_model.dart';
import 'parking_space_model.dart';

class ParkingRecordModel {
  final int id;
  final VehicleModel vehiculo;
  final ParkingSpaceModel espacio;
  final int usuarioId;
  final String usuarioNombre;
  final int? reservaId;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final String? observacion;
  final DateTime? createdAt;

  const ParkingRecordModel({
    required this.id,
    required this.vehiculo,
    required this.espacio,
    required this.usuarioId,
    required this.usuarioNombre,
    this.reservaId,
    required this.fechaIngreso,
    this.fechaSalida,
    this.observacion,
    this.createdAt,
  });

  bool get activo => fechaSalida == null;

  factory ParkingRecordModel.fromJson(Map<String, dynamic> json) {
    return ParkingRecordModel(
      id: json['id'] as int,
      vehiculo: VehicleModel.fromJson(
          json['vehiculo'] as Map<String, dynamic>),
      espacio: ParkingSpaceModel.fromJson(
          json['espacio'] as Map<String, dynamic>),
      usuarioId: json['usuarioId'] as int,
      usuarioNombre: (json['usuarioNombre'] ?? '') as String,
      reservaId: json['reservaId'] as int?,
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      fechaSalida: json['fechaSalida'] != null
          ? DateTime.parse(json['fechaSalida'] as String)
          : null,
      observacion: json['observacion'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
