import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Decides where to go on launch: validates the stored session and routes
/// to the shell (authenticated) or the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;

    final route = auth.status == AuthStatus.authenticated
        ? AppRoutes.shell
        : AppRoutes.login;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.textDark, AppColors.chocolate],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.landscape,
                    color: AppColors.white, size: 44),
              ),
              const SizedBox(height: 24),
              Text(
                'Pacha Suite',
                style: AppTheme.light.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'HOTEL MANAGEMENT',
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 4,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
