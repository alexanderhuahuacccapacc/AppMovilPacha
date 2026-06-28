import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stay_progress_bar.dart';

class AssignedRoomScreen extends StatefulWidget {
  final int roomId;

  const AssignedRoomScreen({super.key, required this.roomId});

  @override
  State<AssignedRoomScreen> createState() => _AssignedRoomScreenState();
}

class _AssignedRoomScreenState extends State<AssignedRoomScreen> {
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
      appBar: AppBar(title: const Text('Mi Habitación')),
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
              icon: Icons.king_bed_outlined,
              title: 'No se pudo cargar',
              message: '${snapshot.error ?? 'Habitación no encontrada'}', actionLabel: '',
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(RoomModel room) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _photoHero(room),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roomInfo(room),
              const SizedBox(height: 16),
              _stayProgress(),
              const SizedBox(height: 24),
              _specsList(room),
              const SizedBox(height: 24),
              _amenidadesSection(room),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoHero(RoomModel room) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.chocolate,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: room.imagenPrincipal.isNotEmpty
          ? Image.network(
              room.imagenPrincipal,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroIcon(room),
            )
          : _heroIcon(room),
    );
  }

  Widget _heroIcon(RoomModel room) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.king_bed_outlined, color: Colors.white70, size: 64),
          const SizedBox(height: 8),
          Text(room.nombre,
              style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _roomInfo(RoomModel room) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('HAB.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  Text(room.numero,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.creamSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          room.tipoLabel,
                          style: const TextStyle(
                            color: AppColors.chocolate,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: room.estado.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room.estado.label,
                        style: TextStyle(
                          color: room.estado.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoChips(room),
      ],
    );
  }

  Widget _infoChips(RoomModel room) {
    return Row(
      children: [
        _chip(Icons.people_outline, '${room.capacidad} pers.'),
        const SizedBox(width: 8),
        _chip(Icons.bed_outlined, room.camas),
        if (room.sizeM2 != null) ...[
          const SizedBox(width: 8),
          _chip(Icons.straighten, '${room.sizeM2} m²'),
        ],
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.chocolate),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.chocolate)),
        ],
      ),
    );
  }

  Widget _stayProgress() {
    final reservation = context.watch<ReservationProvider>();
    if (reservation.state == ReservationState.success &&
        reservation.reservation != null) {
      return StayProgressBar(
        checkIn: reservation.reservation!.checkIn,
        checkOut: reservation.reservation!.checkOut,
      );
    }
    return StayProgressBar();
  }

  Widget _amenidadesSection(RoomModel room) {
    final entries = _amenidadLabels.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenidades incluidas',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _amenidadRow(
                label: e.value.$1,
                icon: e.value.$2,
                active: room.amenidad(e.key),
              ),
            )),
      ],
    );
  }

  Widget _amenidadRow({
    required String label,
    required IconData icon,
    required bool active,
  }) {
    final color = active ? AppColors.success : AppColors.textMuted;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.creamSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14, color: color)),
        ),
        Icon(
          active ? Icons.check_circle : Icons.cancel_outlined,
          size: 20,
          color: color,
        ),
      ],
    );
  }

  Widget _specsList(RoomModel room) {
    final specs = <(IconData, String, String)>[
      (Icons.king_bed_outlined, 'Tipo', room.tipoLabel),
      (Icons.people_outline, 'Capacidad', '${room.capacidad} personas'),
      (Icons.bed_outlined, 'Camas', room.camas),
      (Icons.straighten, 'Tamaño',
          room.sizeM2 == null ? '—' : '${room.sizeM2} m²'),
      (Icons.payments_outlined, 'Precio base',
          'S/ ${room.precioBase.toStringAsFixed(2)} /noche'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalles',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...specs.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.creamSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.$1, color: AppColors.chocolate, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$2,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                      Text(s.$3,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
