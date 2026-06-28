import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/room_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/room_card.dart';
import '../../widgets/shimmer_box.dart';

/// HU20 — Rooms list with visual status.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  RoomStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RoomProvider>().loadRooms(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();

    return Column(
      children: [
        _filterBar(),
        Expanded(child: _body(provider)),
      ],
    );
  }

  Widget _body(RoomProvider provider) {
    switch (provider.listState) {
      case LoadState.idle:
      case LoadState.loading:
        return _skeletonList();
      case LoadState.error:
        return EmptyState(
          icon: Icons.cloud_off,
          title: 'No se pudo cargar',
          message: provider.error ?? 'Error desconocido',
          actionLabel: 'Reintentar',
          onAction: () => provider.loadRooms(force: true),
        );
      case LoadState.success:
        final rooms = _filter == null
            ? provider.rooms
            : provider.rooms.where((r) => r.estado == _filter).toList();

        if (rooms.isEmpty) {
          return const EmptyState(
            icon: Icons.king_bed_outlined,
            title: 'Sin habitaciones',
            message: 'No hay habitaciones que coincidan con el filtro.', actionLabel: '',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.loadRooms(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => RoomCard(
              room: rooms[i],
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.roomDetail,
                arguments: rooms[i].id,
              ),
            ),
          ),
        );
    }
  }

  Widget _filterBar() {
    final filters = <(String, RoomStatus?)>[
      ('Todas', null),
      ('Disponibles', RoomStatus.disponible),
      ('Ocupadas', RoomStatus.finalizada),
      ('Mantenimiento', RoomStatus.mantenimiento),
    ];
    return Container(
      height: 56,
      alignment: Alignment.center,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filter == filters[i].$2;
          return ChoiceChip(
            label: Text(filters[i].$1),
            selected: selected,
            onSelected: (_) => setState(() => _filter = filters[i].$2),
            selectedColor: AppColors.primary.withOpacity(0.14),
            labelStyle: TextStyle(
              color: selected ? AppColors.primary : AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _skeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerBox(height: 260, radius: 20),
    );
  }
}
