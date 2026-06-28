import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cochera_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/room_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cochera_repository.dart';
import 'repositories/reservation_repository.dart';
import 'repositories/room_repository.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/rooms/assigned_room_screen.dart';
import 'screens/rooms/room_detail_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/unauthorized/unauthorized_screen.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Dependency wiring ──
  final apiClient = ApiClient();
  await apiClient.init(); // inicializa el CookieJar (necesita path_provider)

  final authRepository = AuthRepository(apiClient);
  final roomRepository = RoomRepository(apiClient);
  final cocheraRepository = CocheraRepository(apiClient);
  final reservationRepository = ReservationRepository(apiClient);

  final authProvider = AuthProvider(authRepository, apiClient);
  apiClient.onSessionExpired = authProvider.onSessionExpired;

  runApp(
    PachaSuiteApp(
      authProvider: authProvider,
      roomRepository: roomRepository,
      cocheraRepository: cocheraRepository,
      reservationRepository: reservationRepository,
    ),
  );
}

class PachaSuiteApp extends StatelessWidget {
  final AuthProvider authProvider;
  final RoomRepository roomRepository;
  final CocheraRepository cocheraRepository;
  final ReservationRepository reservationRepository;

  const PachaSuiteApp({
    super.key,
    required this.authProvider,
    required this.roomRepository,
    required this.cocheraRepository,
    required this.reservationRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => RoomProvider(roomRepository)),
        ChangeNotifierProvider(
            create: (_) => CocheraProvider(cocheraRepository)),
        ChangeNotifierProvider(
            create: (_) => ReservationProvider(reservationRepository)),
      ],
      child: MaterialApp(
        title: 'Pacha Suite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.shell: (_) => const MainShell(),
          AppRoutes.unauthorized: (_) => const UnauthorizedScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.roomDetail) {
            final id = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => RoomDetailScreen(roomId: id),
            );
          }
          if (settings.name == AppRoutes.assignedRoom) {
            final id = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => AssignedRoomScreen(roomId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}