import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/landing/presentation/pages/landing_page.dart';
import '../features/shell/presentation/main_shell.dart';
import '../state/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return const MainShell();
          case AuthStatus.unauthenticated:
            // Pengunjung yang belum login melihat landing page dulu.
            // Dari landing, tombol "Masuk"/"Daftar" membuka /login & /register.
            return const LandingPage();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
