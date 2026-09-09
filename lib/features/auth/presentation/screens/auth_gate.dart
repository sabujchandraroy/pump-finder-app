import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../petrol_pump/presentation/screens/map_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.isAuthenticated) {
      return const MapScreen();
    }

    return const LoginScreen();
  }
}
