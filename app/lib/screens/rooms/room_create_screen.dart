import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/amenities_catalog.dart';
import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/room_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// HU54 — Formulario "Crear nueva habitación".
///
/// NOTA: el backend desplegado aún no expone un POST para crear
/// habitaciones, así que esta pantalla agrega la habitación únicamente a
/// la lista en memoria (demo). Las amenidades se gestionan con switches
/// SI/NO. Cuando exista el endpoint real, basta con reemplazar la llamada
/// `addLocalRoom` por un `repo.create(...)`.
class RoomCreateScreen extends StatefulWidget {
  const RoomCreateScreen({super.key});

  @override
  State<RoomCreateScreen> createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends State<RoomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numero = TextEditingController();
  final _nombre = TextEditingController();
  final _capacidad = TextEditingController(text: '2');
  final _precio = TextEditingController();
  final _sizeM2 = TextEditingController();
  final _camas = TextEditingController();

  // Coinciden con Habitacion.HabitacionTipo del backend.
  static const _tipos = ['simple', 'doble', 'matrimonial', 'triple', 'cuadruple'];
  String _tipo = 'doble';
  RoomStatus _estado = RoomStatus.disponible;

  late final Map<String, bool> _amenidades = {
    for (final a in AmenitiesCatalog.all) a.key: false,
  };

  @override
  void dispose() {
    _numero.dispose();
    _nombre.dispose();
    _capacidad.dispose();
    _precio.dispose();
    _sizeM2.dispose();
    _camas.dispose();
    super.dispose();
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RoomProvider>();
    final room = RoomModel(
      id: provider.nextLocalId,
      numero: _numero.text.trim(),
      nombre: _nombre.text.trim(),
      tipo: _tipo,
      capacidad: int.tryParse(_capacidad.text.trim()) ?? 1,
      precioBase: double.tryParse(_precio.text.trim().replaceAll(',', '.')) ?? 0,
      sizeM2: int.tryParse(_sizeM2.text.trim()),
      camas: _camas.text.trim(),
      estado: _estado,
      amenidades: Map<String, bool>.from(_amenidades),
      imagenes: const [],
    );

    provider.addLocalRoom(room);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Habitación creada localmente (demo · no persiste en el servidor).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear habitación')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _demoBanner(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _numero,
                    label: 'Número',
                    prefixIcon: Icons.tag,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Obligatorio'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _capacidad,
                    label: 'Capacidad',
                    prefixIcon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    validator: _validarEntero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _nombre,
              label: 'Nombre',
              prefixIcon: Icons.bed_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 14),
            _tipoDropdown(),
            const SizedBox(height: 14),
            _estadoDropdown(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _precio,
                    label: 'Precio base (S/)',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n =
                          double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Mayor a 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _sizeM2,
                    label: 'Tamaño m² (opcional)',
                    prefixIcon: Icons.straighten,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _camas,
              label: 'Camas (ej: 1 matrimonial)',
              prefixIcon: Icons.king_bed_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            Text('Amenidades',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Activa o desactiva cada servicio (SI / NO).',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _amenidadesSwitches(),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Crear habitación',
              icon: Icons.add,
              onPressed: _guardar,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _demoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.amber, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo: la habitación se agrega solo a la lista de la app. '
              'Aún no existe el endpoint para guardarla en el servidor.',
              style: TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipoDropdown() {
    return DropdownButtonFormField<String>(
      value: _tipo,
      decoration: const InputDecoration(
        labelText: 'Tipo',
        prefixIcon: Icon(Icons.category_outlined, size: 20),
      ),
      items: [
        for (final t in _tipos)
          DropdownMenuItem(
            value: t,
            child: Text(t[0].toUpperCase() + t.substring(1)),
          ),
      ],
      onChanged: (v) => setState(() => _tipo = v ?? _tipo),
    );
  }

  Widget _estadoDropdown() {
    const estados = [
      RoomStatus.disponible,
      RoomStatus.pendiente,
      RoomStatus.finalizada,
      RoomStatus.mantenimiento,
    ];
    return DropdownButtonFormField<RoomStatus>(
      value: _estado,
      decoration: const InputDecoration(
        labelText: 'Estado',
        prefixIcon: Icon(Icons.flag_outlined, size: 20),
      ),
      items: [
        for (final e in estados)
          DropdownMenuItem(value: e, child: Text(e.label)),
      ],
      onChanged: (v) => setState(() => _estado = v ?? _estado),
    );
  }

  Widget _amenidadesSwitches() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < AmenitiesCatalog.all.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            SwitchListTile(
              value: _amenidades[AmenitiesCatalog.all[i].key] ?? false,
              onChanged: (v) => setState(
                  () => _amenidades[AmenitiesCatalog.all[i].key] = v),
              activeColor: AppColors.primary,
              secondary: Icon(AmenitiesCatalog.all[i].icon,
                  color: AppColors.chocolate),
              title: Text(AmenitiesCatalog.all[i].nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }

  String? _validarEntero(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Inválido';
    return null;
  }
}
