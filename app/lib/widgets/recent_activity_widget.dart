import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/activiti_model.dart';
import '../providers/room_provider.dart';

/// Feed de actividad reciente — conectado a GET /api/admin/habitaciones/actividad
class RecentActivityWidget extends StatefulWidget {
  const RecentActivityWidget({super.key});

  @override
  State<RecentActivityWidget> createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  @override
  void initState() {
    super.initState();
    // Carga al montar, sin bloquear el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadActividad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
            child: Row(
              children: [
                Text('Actividad reciente',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Actualizar',
                  onPressed: () =>
                      context.read<RoomProvider>().loadActividad(force: true),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _body(provider),
        ],
      ),
    );
  }

  Widget _body(RoomProvider provider) {
    switch (provider.actividadState) {
      case LoadState.loading:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );

      case LoadState.error:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No se pudo cargar la actividad.',
              style: TextStyle(color: AppColors.textMuted)),
        );

      case LoadState.success when provider.actividad.isEmpty:
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('Sin actividad reciente.',
                style: TextStyle(color: AppColors.textMuted)),
          ),
        );

      default:
        final items = provider.actividad;
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _tile(items[i]),
              if (i < items.length - 1) const Divider(height: 1),
            ],
          ],
        );
    }
  }

  Widget _tile(ActividadModel item) {
    final (icon, color) = _iconFor(item.tipo);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(item.titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
        '${item.subtitulo} · ${_timeAgo(item.fecha)}',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }

  (IconData, Color) _iconFor(String tipo) {
    return switch (tipo) {
      'checkin'    => (Icons.login, AppColors.primary),
      'reserva'    => (Icons.event_available, Colors.green),
      'estado'     => (Icons.swap_horiz, Colors.orange),
      'amenidades' => (Icons.tune, Colors.purple),
      _            => (Icons.edit_outlined, AppColors.chocolate),
    };
  }

  String _timeAgo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }
}