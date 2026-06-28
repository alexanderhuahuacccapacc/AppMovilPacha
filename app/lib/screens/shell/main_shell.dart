import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../cochera/cochera_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../rooms/rooms_screen.dart';

/// Authenticated container: bottom navigation + a modern drawer.
/// The navigation set adapts to the current role.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Habitaciones', 'Cochera', 'Perfil'];
  static const _pages = [
    DashboardScreen(),
    RoomsScreen(),
    CocheraScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(
                auth.isAdmin ? Icons.shield : Icons.badge,
                color: AppColors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(onSelect: (i) => setState(() => _index = i)),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.king_bed_outlined),
            selectedIcon: Icon(Icons.king_bed),
            label: 'Habitaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking),
            label: 'Cochera',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const _AppDrawer({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: AppColors.textDark,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      auth.isAdmin ? Icons.shield : Icons.badge,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.role.label ?? '—',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.role.label,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            _item(context, Icons.dashboard_outlined, 'Dashboard', 0),
            _item(context, Icons.king_bed_outlined, 'Habitaciones', 1),
            _item(context, Icons.local_parking_outlined, 'Cochera', 2),
            _item(context, Icons.person_outline, 'Perfil', 3),
            if (auth.isAdmin) const _AdminOnlyHint(),
            const Spacer(),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF8A80)),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Color(0xFFFF8A80)),
              ),
              onTap: () => _confirmLogout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.of(context).pop();
        onSelect(index);
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
    );
  }
}

class _AdminOnlyHint extends StatelessWidget {
  const _AdminOnlyHint();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.shield_outlined, color: AppColors.amber),
      title: Text(
        'Acceso de administrador',
        style: TextStyle(color: AppColors.amber, fontSize: 13),
      ),
      subtitle: Text(
        'Gestión avanzada (próximos sprints)',
        style: TextStyle(color: Colors.white38, fontSize: 11),
      ),
    );
  }
}