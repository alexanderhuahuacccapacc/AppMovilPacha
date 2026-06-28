import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/hotel_info.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/contact_message_model.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/hotel_map_card.dart';
import '../../widgets/primary_button.dart';

/// HU37 — Formulario de contacto con validaciones.
/// HU38 — Conecta el envío con MensajeContactoController (POST).
/// HU39 — Muestra datos de contacto y confirmación visual de envío.
/// HU40 — Integra el mapa con la ubicación del hotel.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _asunto = TextEditingController();
  final _mensaje = TextEditingController();

  bool _enviado = false;

  @override
  void initState() {
    super.initState();
    // Estado limpio cada vez que se entra a la pantalla.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ContactProvider>().reset(),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _telefono.dispose();
    _asunto.dispose();
    _mensaje.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ContactProvider>();
    final ok = await provider.enviar(
      ContactMessage(
        nombre: _nombre.text.trim(),
        email: _email.text.trim(),
        telefono: _telefono.text.trim(),
        asunto: _asunto.text.trim(),
        mensaje: _mensaje.text.trim(),
      ),
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _enviado = true);
      _formKey.currentState!.reset();
      _nombre.clear();
      _email.clear();
      _telefono.clear();
      _asunto.clear();
      _mensaje.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'No se pudo enviar el mensaje.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSending = context.watch<ContactProvider>().isSending;

    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(),
          const SizedBox(height: 16),
          const HotelMapCard(),
          const SizedBox(height: 24),
          Text('Escríbenos',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Completa el formulario y te responderemos pronto.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_enviado) _successBanner(),
          _form(isSending),
        ],
      ),
    );
  }

  // ── HU39: datos de contacto (ubicación, teléfono, email) ──
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.place_outlined,
            label: 'Ubicación',
            value: HotelInfo.direccion,
            onTap: () => _launch(HotelInfo.googleMapsUrl),
          ),
          const Divider(height: 22, color: AppColors.border),
          _infoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: HotelInfo.telefono,
            onTap: () => _launch(
                'tel:${HotelInfo.telefono.replaceAll(' ', '')}'),
          ),
          const Divider(height: 22, color: AppColors.border),
          _infoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: HotelInfo.email,
            onTap: () => _launch('mailto:${HotelInfo.email}'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _successBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '¡Mensaje enviado! Te responderemos a la brevedad.',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.success),
            onPressed: () => setState(() => _enviado = false),
          ),
        ],
      ),
    );
  }

  Widget _form(bool isSending) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nombre,
            label: 'Nombre',
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'El nombre es obligatorio'
                : (v.trim().length > 150 ? 'Máximo 150 caracteres' : null),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _email,
            label: 'Correo',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _telefono,
            label: 'Teléfono (opcional)',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return null; // opcional
              if (t.length > 30) return 'Máximo 30 caracteres';
              if (!RegExp(r'^[\d\s()+-]{6,}$').hasMatch(t)) {
                return 'Teléfono inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _asunto,
            label: 'Asunto',
            prefixIcon: Icons.subject,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'El asunto es obligatorio'
                : (v.trim().length > 200 ? 'Máximo 200 caracteres' : null),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _mensaje,
            maxLines: 5,
            maxLength: 5000,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.message_outlined, size: 20),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'El mensaje es obligatorio'
                : null,
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Enviar mensaje',
            icon: Icons.send_outlined,
            loading: isSending,
            onPressed: _enviar,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
