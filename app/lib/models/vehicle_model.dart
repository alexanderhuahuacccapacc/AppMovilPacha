class VehicleModel {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String? color;
  final String? observaciones;
  final String tipo;
  final int usuarioId;

  const VehicleModel({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    this.color,
    this.observaciones,
    required this.tipo,
    required this.usuarioId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      placa: (json['placa'] ?? '') as String,
      marca: (json['marca'] ?? '') as String,
      modelo: (json['modelo'] ?? '') as String,
      color: json['color'] as String?,
      observaciones: json['observaciones'] as String?,
      tipo: (json['tipo'] ?? 'AUTO') as String,
      usuarioId: json['usuarioId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'observaciones': observaciones,
      'tipo': tipo,
    };
  }
}