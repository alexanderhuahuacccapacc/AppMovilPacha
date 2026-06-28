/// Mensaje de contacto enviado desde la app.
///
/// Los nombres de campo del JSON coinciden con `MensajeContactoRequest`
/// del backend: nombre, email, telefono, asunto, mensaje.
class ContactMessage {
  final String nombre;
  final String email;
  final String telefono;
  final String asunto;
  final String mensaje;

  const ContactMessage({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.asunto,
    required this.mensaje,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        // El backend acepta teléfono opcional; si va vacío lo mandamos null.
        'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
        'asunto': asunto,
        'mensaje': mensaje,
      };
}
