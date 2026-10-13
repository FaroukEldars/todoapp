import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'user_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  static const Color _green = Color(0xFF15B86C);

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await _authService.logout();

      if (!mounted) return;

      context.read<UserProvider>().clearUser();
      context.read<TaskProvider>().clearTasks();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subTextColor = isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF6E7177);
    final dividerColor = isDark
        ? const Color(0xFF282828)
        : const Color(0xFFF0F0F0);
    final iconColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final arrowColor = isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF33373B);

    final displayName = user.name.isNotEmpty ? user.name : 'Usama Elgendy';
    final displayQuote = user.quote.isNotEmpty
        ? user.quote
        : 'One task at a time. One step closer.';

    ImageProvider? avatarImage;
    if (!kIsWeb && user.imagePath != null && user.imagePath!.isNotEmpty) {
      final file = File(user.imagePath!);
      if (file.existsSync()) {
        avatarImage = FileImage(file);
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Avatar with camera badge
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: _green.withValues(alpha: 0.15),
                      foregroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _green,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UserDetailsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3A3A3C)
                                  : const Color(0xFFE5E5EA),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // User Name
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 6),

              // User Quote / Subtitle
              Text(
                displayQuote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 36),

              // Profile Info section header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 1. User Details
              _ProfileOptionTile(
                icon: Icons.person_outline_rounded,
                iconColor: iconColor,
                title: 'User Details',
                textColor: textColor,
                trailing: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: arrowColor,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserDetailsScreen(),
                    ),
                  );
                },
              ),

              Divider(height: 1, thickness: 1, color: dividerColor),

              // 2. Dark Mode
              _ProfileOptionTile(
                icon: Icons.nightlight_round_outlined,
                iconColor: iconColor,
                title: 'Dark Mode',
                textColor: textColor,
                trailing: Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (val) {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  activeTrackColor: _green,
                  activeThumbColor: Colors.white,
                  inactiveTrackColor: isDark
                      ? const Color(0xFF3A3A3C)
                      : const Color(0xFFE5E5EA),
                  inactiveThumbColor: Colors.white,
                ),
              ),

              Divider(height: 1, thickness: 1, color: dividerColor),

              // 3. Log Out
              _ProfileOptionTile(
                icon: Icons.logout_rounded,
                iconColor: iconColor,
                title: 'Log Out',
                textColor: textColor,
                trailing: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: arrowColor,
                      ),
                onTap: _isLoggingOut ? null : _logout,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color textColor;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.textColor,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
