import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/parking_record_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guest_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/empty_state.dart';
import '../../models/parking_space_model.dart';
import '../../widgets/shimmer_box.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestProvider>().loadGuestData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final guest = context.watch<GuestProvider>();
    final reservation = guest.activeReservation;
    final parkingRecord = guest.activeParkingRecord;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Estancia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: guest.isLoading ? null : () => guest.refreshData(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => guest.refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de bienvenida
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),

              // Estado de carga o error
              if (guest.status == GuestStatus.loading)
                _buildLoadingState()
              else if (guest.error != null)
                _buildErrorState(guest.error!)
              else if (reservation != null) ...[
                  // Tarjeta de reserva
                  _buildReservationCard(context, reservation),
                  const SizedBox(height: 20),

                  // Sección de cochera
                  _buildParkingSection(context, parkingRecord),
                ] else
                  _buildNoReservationState(),

              const SizedBox(height: 24),
              // Botón de cerrar sesión
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Aquí puedes ver tu reserva y gestionar tu vehículo',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        ShimmerBox(height: 200, radius: 16),
        const SizedBox(height: 16),
        ShimmerBox(height: 150, radius: 16),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
          TextButton(
            onPressed: () => context.read<GuestProvider>().refreshData(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, reservation) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final checkIn = dateFormat.format(reservation.checkIn);
    final checkOut = dateFormat.format(reservation.checkOut);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Reserva #${reservation.codigo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusChip(reservation.estado),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildInfoItem(
                  Icons.king_bed,
                  'Habitación ${reservation.habitacionNumero}',
                  reservation.habitacionNombre,
                ),
                const Spacer(),
                _buildInfoItem(
                  Icons.calendar_today,
                  'Check-in',
                  checkIn,
                ),
                const Spacer(),
                _buildInfoItem(
                  Icons.calendar_today,
                  'Check-out',
                  checkOut,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${reservation.noches} noches', 'Estancia'),
                  _buildStatItem('${reservation.adultos} adultos', 'Huéspedes'),
                  _buildStatItem('S/${reservation.total.toStringAsFixed(2)}', 'Total'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toUpperCase()) {
      case 'CONFIRMADA':
        color = Colors.green;
        label = 'Confirmada';
        break;
      case 'PENDIENTE':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'CANCELADA':
        color = Colors.red;
        label = 'Cancelada';
        break;
      case 'COMPLETADA':
        color = Colors.blue;
        label = 'Completada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildNoReservationState() {
    return EmptyState(
      icon: Icons.hotel_outlined,
      title: 'Sin reserva activa',
      message: 'No encontramos una reserva activa asociada a tu cuenta.\nContacta con recepción si crees que esto es un error.', actionLabel: '',
    );
  }

  Widget _buildParkingSection(BuildContext context, parkingRecord) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_parking, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Mi Vehículo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (parkingRecord != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Registrado',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20),
            if (parkingRecord != null) ...[
              _buildVehicleInfo(parkingRecord),
              const SizedBox(height: 12),
              _buildParkingSpaceInfo(parkingRecord.espacio),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Vehículo registrado correctamente',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Aún no has registrado tu vehículo en la cochera.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Registrar mi vehículo',
                icon: Icons.add_circle_outline,
                onPressed: () => _showVehicleRegistrationDialog(context),
                fullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(ParkingRecordModel record) {
    final vehicle = record.vehiculo;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.directions_car, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.marca} ${vehicle.modelo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Placa: ${vehicle.placa}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              if (vehicle.color != null)
                Text(
                  'Color: ${vehicle.color}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParkingSpaceInfo(ParkingSpaceModel space) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.pin_drop, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espacio ${space.codigo}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (space.ubicacion != null)
                  Text(
                    space.ubicacion!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              space.estado.label,
              style: TextStyle(
                color: space.estado.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleRegistrationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final placaCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final modeloCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final observacionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar vehículo'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: placaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa *',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: marcaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Marca *',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: modeloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Modelo *',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: colorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Color (opcional)',
                    prefixIcon: Icon(Icons.color_lens),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: observacionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final guest = context.read<GuestProvider>();
              await guest.registerVehicle(
                placa: placaCtrl.text.trim(),
                marca: marcaCtrl.text.trim(),
                modelo: modeloCtrl.text.trim(),
                color: colorCtrl.text.trim().isEmpty ? null : colorCtrl.text.trim(),
                observacion: observacionCtrl.text.trim().isEmpty ? null : observacionCtrl.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(ctx);
              if (guest.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Vehículo registrado correctamente!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Seguro que deseas cerrar tu sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;

        await context.read<AuthProvider>().logout();
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
              (route) => false,
        );
      },
      icon: const Icon(Icons.logout, color: AppColors.danger),
      label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.danger)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.danger),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}