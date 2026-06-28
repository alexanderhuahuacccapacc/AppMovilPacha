import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/guest_provider.dart';
import 'providers/cochera_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/room_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/guest_repository.dart';
import 'repositories/cochera_repository.dart';
import 'repositories/reservation_repository.dart';
import 'repositories/room_repository.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/guests/GuestHomeScreen.dart';
import 'screens/rooms/room_detail_screen.dart';
import 'screens/rooms/assigned_room_screen.dart';
import 'screens/unauthorized/unauthorized_screen.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Un solo ApiClient para toda la app: maneja la cookie HttpOnly (jwt=)
  // y centraliza el manejo de 401 (sesión expirada).
  final apiClient = ApiClient();
  await apiClient.init();

  // Todos los repositorios reciben el mismo ApiClient, así la cookie de
  // sesión viaja en TODAS las llamadas, no solo en auth/guest.
  final authRepo = AuthRepository(apiClient);
  final guestRepo = GuestRepository(apiClient);
  final cocheraRepo = CocheraRepository(apiClient);
  final reservationRepo = ReservationRepository(apiClient);
  final roomRepo = RoomRepository(apiClient);

  final authProvider = AuthProvider(authRepo, apiClient);

  // Si el backend responde 401 en cualquier request, AuthProvider limpia
  // la sesión y la UI puede reaccionar (redirigir a login).
  apiClient.onSessionExpired = authProvider.onSessionExpired;

  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<GuestRepository>.value(value: guestRepo),
        Provider<CocheraRepository>.value(value: cocheraRepo),
        Provider<ReservationRepository>.value(value: reservationRepo),
        Provider<RoomRepository>.value(value: roomRepo),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (context) => GuestProvider(guestRepo),
        ),
        ChangeNotifierProvider(
          create: (context) => CocheraProvider(cocheraRepo),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(reservationRepo),
        ),
        ChangeNotifierProvider(
          create: (context) => RoomProvider(roomRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pacha Suite',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.guestHome: (_) => const GuestHomeScreen(),
        AppRoutes.unauthorized: (_) => const UnauthorizedScreen(),
      },
      // roomDetail y assignedRoom necesitan un roomId dinámico, que no se
      // puede pasar en el mapa `routes` estático de arriba — por eso se
      // resuelven aquí, leyendo el argumento que mande Navigator.pushNamed.
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.roomDetail:
            final roomId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => RoomDetailScreen(roomId: roomId),
              settings: settings,
            );
          case AppRoutes.assignedRoom:
            final roomId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => AssignedRoomScreen(roomId: roomId),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}