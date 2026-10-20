import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../navigation/main_navigation_screen.dart';
import '../shared/theme/app_palette.dart';
import 'welcome_screen.dart';

/// Splash Screen that checks auth status and routes accordingly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Show splash briefly for smooth visual transition
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final savedUser = await _authService.getSavedUser();

      if (savedUser != null) {
        final userId = int.tryParse(savedUser['id'] ?? '');

        if (userId != null) {
          if (!mounted) return;

          // Restore user session in UserProvider
          context.read<UserProvider>().setUser(
            userId: userId,
            name: savedUser['name'] ?? '',
            email: savedUser['email'] ?? '',
          );

          // Preload tasks for this user
          await context.read<TaskProvider>().loadTasks(userId.toString());

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }

    if (!mounted) return;

    // Navigate to Welcome screen if no valid session exists
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          if (palette.isDark) ...[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppPalette.green.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    center: Alignment.bottomRight,
                    radius: 1.1,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppPalette.green.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    center: Alignment.topLeft,
                    radius: 1.1,
                  ),
                ),
              ),
            ),
          ],
          Center(child: Image.asset('assets/logo.png', width: 96, height: 96)),
        ],
      ),
    );
  }
}
