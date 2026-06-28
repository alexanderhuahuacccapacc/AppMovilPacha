/// Entrada del feed de actividad reciente devuelta por
/// GET /api/admin/habitaciones/actividad
class ActividadModel {
  final String titulo;
  final String subtitulo;
  final String tipo; // "update" | "amenidades" | "estado" | "checkin" | "reserva"
  final DateTime fecha;

  const ActividadModel({
    required this.titulo,
    required this.subtitulo,
    required this.tipo,
    required this.fecha,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      titulo: json['titulo'] as String? ?? '',
      subtitulo: json['subtitulo'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'update',
      fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
    );
  }
}