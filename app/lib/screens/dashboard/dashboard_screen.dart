import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/shimmer_box.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
      context.read<ReservationProvider>().loadMiReserva();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rooms = context.watch<RoomProvider>();
    final loading = rooms.listState == LoadState.loading ||
        rooms.listState == LoadState.idle;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<RoomProvider>().loadRooms(force: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _greeting(context, auth),
          const SizedBox(height: 20),
          _assignedRoomCard(context, rooms, loading),
          const SizedBox(height: 20),
          loading ? _kpiSkeleton() : _kpiGrid(rooms),
          const SizedBox(height: 24),
          Text('Resumen del hotel',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _occupancyCard(rooms, loading),
          const SizedBox(height: 24),
          Text('Actividad reciente',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _recentActivity(),
        ],
      ),
    );
  }

  /// The backend's login response only carries {email, rol} — no display
  /// name — so the greeting falls back to the email instead of a first
  /// name.
  Widget _assignedRoomCard(BuildContext context, RoomProvider rooms, bool loading) {
    final reservation = context.watch<ReservationProvider>();
    final hasReservation = reservation.state == ReservationState.success &&
        reservation.reservation != null;

    if (hasReservation) {
      final r = reservation.reservation!;
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.assignedRoom,
            arguments: r.habitacionId,
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 90,
                color: AppColors.chocolate,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.king_bed_outlined,
                          color: Colors.white38, size: 28),
                      const SizedBox(height: 2),
                      Text('Nº ${r.habitacionNumero}',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_available,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Mi Reserva',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.habitacionNombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${r.habitacionTipo} · ${r.noches} noche${r.noches == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback: show first room from list if reservation unavailable
    if (loading || rooms.rooms.isEmpty) return const SizedBox.shrink();
    final room = rooms.rooms.first;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.assignedRoom,
          arguments: room.id,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 90,
              child: room.imagenPrincipal.isNotEmpty
                  ? Image.network(room.imagenPrincipal,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _roomPlaceholder())
                  : _roomPlaceholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.king_bed_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Mi Habitación',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nº ${room.numero}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      '${room.nombre} · ${room.tipoLabel}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomPlaceholder() {
    return Container(
      color: AppColors.chocolate,
      child: const Center(
        child:
            Icon(Icons.king_bed_outlined, color: Colors.white38, size: 32),
      ),
    );
  }

  Widget _greeting(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola 👋',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          auth.user?.email ?? 'Resumen operativo de Hotel Pacha Suite',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _kpiGrid(RoomProvider rooms) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        KpiCard(
          icon: Icons.king_bed_outlined,
          accent: AppColors.primary,
          value: '${rooms.total}',
          label: 'Habitaciones',
        ),
        KpiCard(
          icon: Icons.check_circle_outline,
          accent: AppColors.success,
          value: '${rooms.countByStatus(RoomStatus.disponible)}',
          label: 'Disponibles',
        ),
        KpiCard(
          icon: Icons.person_outline,
          accent: AppColors.danger,
          value: '${rooms.countByStatus(RoomStatus.finalizada)}',
          label: 'Ocupadas',
        ),
        KpiCard(
          icon: Icons.build_outlined,
          accent: AppColors.warning,
          value: '${rooms.countByStatus(RoomStatus.mantenimiento)}',
          label: 'Mantenimiento',
          badgeCount: rooms.countByStatus(RoomStatus.mantenimiento),
        ),
      ],
    );
  }

  Widget _kpiSkeleton() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: List.generate(4, (_) => const ShimmerBox(height: 110)),
    );
  }

  Widget _occupancyCard(RoomProvider rooms, bool loading) {
    final total = rooms.total;
    final occupied = rooms.countByStatus(RoomStatus.finalizada);
    final ratio = total == 0 ? 0.0 : occupied / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: 10),
                const Text('Ocupación actual',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  loading ? '—' : '${(ratio * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: loading ? null : ratio,
                minHeight: 10,
                backgroundColor: AppColors.creamSoft,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              loading
                  ? 'Calculando ocupación…'
                  : '$occupied de $total habitaciones ocupadas',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivity() {
    // Placeholder timeline — wired to real events in later sprints.
    final items = [
      ('Check-in registrado', 'Suite Titicaca · hace 1 h', Icons.login),
      ('Habitación en mantenimiento', 'Suite Uros · hace 3 h', Icons.build),
      ('Nueva reserva web', 'Suite Inca · hoy', Icons.event_available),
    ];
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.creamSoft,
                child: Icon(items[i].$3, color: AppColors.chocolate, size: 20),
              ),
              title: Text(items[i].$1,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(items[i].$2,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}