import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/parking_record_model.dart';
import '../../models/parking_space_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cochera_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_box.dart';

class CocheraScreen extends StatefulWidget {
  const CocheraScreen({super.key});

  @override
  State<CocheraScreen> createState() => _CocheraScreenState();
}

class _CocheraScreenState extends State<CocheraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final p = context.read<CocheraProvider>();
    await Future.wait([
      p.loadEspacios(force: true),
      p.loadActivos(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CocheraProvider>();
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: _buildBody(provider, auth),
    );
  }

  Widget _buildBody(CocheraProvider provider, AuthProvider auth) {
    switch (provider.espaciosState) {
      case CocheraLoadState.idle:
      case CocheraLoadState.loading:
        return _skeleton();
      case CocheraLoadState.error:
        return EmptyState(
          icon: Icons.local_parking_outlined,
          title: 'No se pudo cargar',
          message: provider.error ?? 'Error desconocido',
          actionLabel: 'Reintentar',
          onAction: _load,
        );
      case CocheraLoadState.success:
        final espacios = provider.espacios;
        if (espacios.isEmpty) {
          return const EmptyState(
            icon: Icons.local_parking_outlined,
            title: 'Sin espacios',
            message: 'No hay espacios de cochera registrados.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summaryBar(provider),
            const SizedBox(height: 20),
            _parkingGrid(provider, auth),
            const SizedBox(height: 20),
            _activeVehiclesCard(provider, auth),
          ],
        );
    }
  }

  Widget _summaryBar(CocheraProvider provider) {
    final total = provider.espacios.length;
    final libres = provider.espaciosLibres;
    final ocupados = provider.espaciosOcupados;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _stat(Icons.local_parking_outlined, 'Total', '$total',
                AppColors.textDark),
            const _Dot(),
            _stat(Icons.check_circle_outline, 'Libres', '$libres',
                AppColors.success),
            const _Dot(),
            _stat(Icons.block, 'Ocupados', '$ocupados', AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18, color: color)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _parkingGrid(CocheraProvider provider, AuthProvider auth) {
    final espacios = provider.espacios;
    final activos = provider.activos;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF444444)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_parking, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Mapa de la cochera',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const Spacer(),
              _statusDot(AppColors.success, 'Libre'),
              const SizedBox(width: 12),
              _statusDot(AppColors.danger, 'Ocupado'),
              if (auth.user?.id != 0) ...[
                const SizedBox(width: 12),
                _statusDot(AppColors.amber, 'Tu espacio'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Entry/exit indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF444444),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, color: Colors.white54, size: 16),
                  SizedBox(width: 6),
                  Text('ENTRADA / SALIDA',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Parking grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: espacios.length,
            itemBuilder: (_, i) => _parkingSpot(
                espacios[i], activos, auth.user?.id ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _parkingSpot(
      ParkingSpaceModel espacio,
      List<ParkingRecordModel> activos,
      int currentUserId) {
    final activeRecord = activos.where((r) => r.espacio.id == espacio.id);
    final isOcupado = espacio.estado == SpaceStatus.ocupado;
    final isYours = activeRecord.any((r) => r.usuarioId == currentUserId);
    final record = activeRecord.isNotEmpty ? activeRecord.first : null;

    final Color bgColor;
    if (isYours) {
      bgColor = AppColors.amber.withOpacity(0.85);
    } else if (isOcupado) {
      bgColor = AppColors.danger.withOpacity(0.85);
    } else {
      bgColor = AppColors.success.withOpacity(0.85);
    }

    return GestureDetector(
      onTap: record != null
          ? () => _showVehicleInfo(context, record)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isYours ? AppColors.amber : Colors.white30,
            width: isYours ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  espacio.codigo,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isYours || isOcupado
                        ? Colors.white
                        : Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isYours)
                  const Icon(Icons.star,
                      color: Colors.white, size: 16),
              ],
            ),
            const Spacer(),
            if (record != null)
              Text(
                record.vehiculo.placa,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  void _showVehicleInfo(BuildContext context, ParkingRecordModel record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.creamSoft,
                  child: Icon(Icons.directions_car,
                      color: AppColors.chocolate, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.vehiculo.placa,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${record.vehiculo.marca} ${record.vehiculo.modelo}'
                        '${record.vehiculo.color != null ? ' · ${record.vehiculo.color}' : ''}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person_outline, 'Registrado por',
                record.usuarioNombre),
            _infoRow(
                Icons.access_time,
                'Ingreso',
                '${record.fechaIngreso.day}/${record.fechaIngreso.month}/${record.fechaIngreso.year} '
                '${record.fechaIngreso.hour.toString().padLeft(2, '0')}:'
                '${record.fechaIngreso.minute.toString().padLeft(2, '0')}'),
            if (record.observacion != null)
              _infoRow(
                  Icons.notes, 'Observación', record.observacion!),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _activeVehiclesCard(
      CocheraProvider provider, AuthProvider auth) {
    final activos = provider.activos;
    if (activos.isEmpty) return const SizedBox.shrink();

    final currentUserId = auth.user?.id ?? 0;
    final misActivos =
        activos.where((r) => r.usuarioId == currentUserId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (misActivos.isNotEmpty) ...[
          Text('Mi vehículo en cochera',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            color: AppColors.amber.withValues(alpha: 0.1),
            child: ListTile(
              leading: const Icon(Icons.directions_car,
                  color: AppColors.amber),
              title: Text(misActivos.first.vehiculo.placa,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                  'Espacio ${misActivos.first.espacio.codigo} · '
                  '${misActivos.first.vehiculo.marca} ${misActivos.first.vehiculo.modelo}'),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textMuted),
              onTap: () => _showVehicleInfo(context, misActivos.first),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text('Vehículos en cochera (${activos.length})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...activos.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.creamSoft,
                  child: Icon(Icons.directions_car,
                      color: AppColors.chocolate, size: 20),
                ),
                title: Text(r.vehiculo.placa,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Espacio ${r.espacio.codigo} · ${r.usuarioNombre}'),
                trailing: const Icon(Icons.info_outline,
                    size: 18, color: AppColors.textMuted),
                onTap: () => _showVehicleInfo(context, r),
              ),
            )),
      ],
    );
  }

  Widget _skeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ShimmerBox(height: 80, radius: 12),
        const SizedBox(height: 20),
        const ShimmerBox(height: 320, radius: 16),
        const SizedBox(height: 20),
        ...List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ShimmerBox(height: 64, radius: 12),
            )),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }
}
