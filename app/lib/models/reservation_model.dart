class ReservationModel {
  final int id;
  final int habitacionId;
  final String codigo;
  final String habitacionNombre;
  final String habitacionNumero;
  final String habitacionTipo;
  final DateTime checkIn;
  final DateTime checkOut;
  final int noches;
  final int adultos;
  final int ninos;
  final String estado;
  final String pagoEstado;
  final double subtotal;
  final double impuestos;
  final double total;
  final String? origen;
  final DateTime? createdAt;

  const ReservationModel({
    required this.id,
    required this.habitacionId,
    required this.codigo,
    required this.habitacionNombre,
    required this.habitacionNumero,
    required this.habitacionTipo,
    required this.checkIn,
    required this.checkOut,
    required this.noches,
    required this.adultos,
    required this.ninos,
    required this.estado,
    required this.pagoEstado,
    required this.subtotal,
    required this.impuestos,
    required this.total,
    this.origen,
    this.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      habitacionId: json['habitacionId'] as int,
      codigo: (json['codigo'] ?? '') as String,
      habitacionNombre: (json['habitacionNombre'] ?? '') as String,
      habitacionNumero: (json['habitacionNumero'] ?? '') as String,
      habitacionTipo: (json['habitacionTipo'] ?? '') as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      noches: json['noches'] as int,
      adultos: json['adultos'] as int,
      ninos: json['ninos'] as int,
      estado: (json['estado'] ?? '') as String,
      pagoEstado: (json['pagoEstado'] ?? '') as String,
      subtotal: double.tryParse('${json['subtotal']}') ?? 0,
      impuestos: double.tryParse('${json['impuestos']}') ?? 0,
      total: double.tryParse('${json['total']}') ?? 0,
      origen: json['origen'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
