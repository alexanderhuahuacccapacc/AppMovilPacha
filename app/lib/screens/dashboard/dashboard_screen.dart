import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/recent_activity_widget.dart';
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
      final provider = context.read<RoomProvider>();
      provider.loadRooms();
      provider.loadActividad();
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
      onRefresh: () async {
        final provider = context.read<RoomProvider>();
        await Future.wait([
          provider.loadRooms(force: true),
          provider.loadActividad(force: true),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _greeting(context, auth),
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
          const RecentActivityWidget(),
        ],
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
}