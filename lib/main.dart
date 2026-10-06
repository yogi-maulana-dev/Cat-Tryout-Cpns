import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/landing/presentation/pages/landing_page.dart';
import 'screens/splash_screen.dart';
import 'state/auth_provider.dart';

void main() {
  runApp(const TryOutBayogApp());
}

class TryOutBayogApp extends StatelessWidget {
  const TryOutBayogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..bootstrap(),
      child: MaterialApp(
        title: 'BisaPNS.id — Platform Tryout CPNS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/forgot-password': (_) => const ForgotPasswordPage(),
          // /pricing & /demo adalah section pada landing; route disediakan agar
          // deep-link tetap valid dan mudah diganti ke halaman khusus nanti.
          '/pricing': (_) => const LandingPage(),
          '/demo': (_) => const LandingPage(),
        },
      ),
    );
  }
}
