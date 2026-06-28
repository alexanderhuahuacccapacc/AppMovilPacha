import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/amenities_catalog.dart';
import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

/// HU21 — Room detail (numero, tipo, capacidad, precio, estado, amenidades).
class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Future<RoomModel> _future;

  static const _amenidadLabels = <String, (String, IconData)>{
    'internet': ('Internet', Icons.wifi),
    'cableNetflix': ('Cable/Netflix', Icons.tv_outlined),
    'banoPrivado': ('Baño privado', Icons.bathtub_outlined),
    'buffetAndino': ('Buffet Andino', Icons.restaurant_outlined),
    'cochera': ('Cochera', Icons.local_parking_outlined),
    'spa': ('Spa', Icons.spa_outlined),
  };

  @override
  void initState() {
    super.initState();
    final isAdmin = context.read<AuthProvider>().isAdmin;
    _future = context.read<RoomProvider>().getRoom(widget.roomId, isAdmin: isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de habitación')),
      body: FutureBuilder<RoomModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'No se pudo cargar',
              message: '${snapshot.error ?? 'Habitación no encontrada'}',
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(RoomModel room) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _hero(room),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(room.nombre,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  StatusBadge(status: room.estado),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${room.tipoLabel} · Nº ${room.numero}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              _specsGrid(room),
              const SizedBox(height: 24),
              Text('Amenidades',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              // Admin: switches SI/NO que persisten contra el backend.
              // Huésped/recepción: vista de solo lectura.
              if (isAdmin)
                _AmenitiesEditor(room: room)
              else
                _amenidadesGrid(room),
              const SizedBox(height: 24),
              _actions(isAdmin),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero(RoomModel room) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.chocolate, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: room.imagenPrincipal.isNotEmpty
          ? Image.network(
        room.imagenPrincipal,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _heroIcon(),
      )
          : _heroIcon(),
    );
  }

  Widget _heroIcon() => const Center(
    child: Icon(Icons.king_bed_outlined, color: Colors.white70, size: 64),
  );

  Widget _specsGrid(RoomModel room) {
    final specs = <(IconData, String, String)>[
      (Icons.people_outline, 'Capacidad', '${room.capacidad} personas'),
      (Icons.bed_outlined, 'Camas', room.camas.isEmpty ? '—' : room.camas),
      (Icons.straighten, 'Tamaño',
      room.sizeM2 == null ? '—' : '${room.sizeM2} m²'),
      (Icons.payments_outlined, 'Precio base',
      'S/ ${room.precioBase.toStringAsFixed(2)} / noche'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2, // ← era 2.6, más alto = más espacio vertical
      children: [
        for (final s in specs)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(s.$1, color: AppColors.chocolate, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // ← centra verticalmente
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        s.$2,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.$3,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12, // ← era 13
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _amenidadesGrid(RoomModel room) {
    final entries = _amenidadLabels.entries.toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: [
        for (final e in entries)
          _amenidadChip(
            label: e.value.$1,
            icon: e.value.$2,
            active: room.amenidad(e.key),
          ),
      ],
    );
  }

  Widget _amenidadChip({
    required String label,
    required IconData icon,
    required bool active,
  }) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.08) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
          active ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            active ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _actions(bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _notImplemented('Reservar'),
          icon: const Icon(Icons.event_available, size: 18),
          label: const Text('Reservar (próximamente)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _notImplemented('Cambiar estado'),
            icon: const Icon(Icons.build_outlined, size: 18),
            label: const Text('Cambiar estado (admin · próximamente)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.chocolate,
              side: const BorderSide(color: AppColors.chocolate),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _notImplemented(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$action" se habilita en próximos sprints.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Editor de amenidades con switches SI/NO (solo admin).
///
/// Cada cambio se persiste con `PUT /admin/habitaciones/{id}/amenidades`
/// vía [RoomProvider.setAmenidades]. Si el backend falla, revierte el
/// switch y muestra el error.
class _AmenitiesEditor extends StatefulWidget {
  final RoomModel room;

  const _AmenitiesEditor({required this.room});

  @override
  State<_AmenitiesEditor> createState() => _AmenitiesEditorState();
}

class _AmenitiesEditorState extends State<_AmenitiesEditor> {
  late final Map<String, bool> _values = {
    for (final a in AmenitiesCatalog.all)
      a.key: widget.room.amenidad(a.key),
  };
  String? _saving; // key actualmente guardándose

  Future<void> _toggle(String key, bool value) async {
    final previous = _values[key] ?? false;
    setState(() {
      _values[key] = value;
      _saving = key;
    });
    try {
      await context
          .read<RoomProvider>()
          .setAmenidades(widget.room.id, Map<String, bool>.from(_values));
    } catch (e) {
      if (!mounted) return;
      setState(() => _values[key] = previous); // revierte
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              value: _values[AmenitiesCatalog.all[i].key] ?? false,
              activeColor: AppColors.primary,
              onChanged: _saving != null
                  ? null
                  : (v) => _toggle(AmenitiesCatalog.all[i].key, v),
              secondary: Icon(AmenitiesCatalog.all[i].icon,
                  color: AppColors.chocolate),
              title: Text(
                AmenitiesCatalog.all[i].nombre,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                (_values[AmenitiesCatalog.all[i].key] ?? false) ? 'SI' : 'NO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: (_values[AmenitiesCatalog.all[i].key] ?? false)
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}