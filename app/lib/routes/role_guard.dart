import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/unauthorized/unauthorized_screen.dart';

/// Wraps an admin-only screen. Recepcionistas get the Unauthorized screen
/// instead of the protected content.
class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);
    return isAdmin ? child : const UnauthorizedScreen();
  }
}
