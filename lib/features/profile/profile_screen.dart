import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'widgets/profile_option_tile.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'user_details_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  static const Color _green = Color(0xFF15B86C);


  Uint8List? _webImageBytes;


  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      if (kIsWeb) {
        final imageBytes = await pickedFile.readAsBytes();

        if (!mounted) return;

        setState(() {
          _webImageBytes = imageBytes;
        });
      } else {
        final appDirectory = await getApplicationDocumentsDirectory();

        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final savedImage = await File(pickedFile.path).copy(
          '${appDirectory.path}/$fileName',
        );

        if (!mounted) return;

        await context.read<UserProvider>().updateImage(savedImage.path);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select image: $e'),
        ),
      );
    }
  }


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

    if (kIsWeb && _webImageBytes != null) {
      avatarImage = MemoryImage(_webImageBytes!);
    } else if (!kIsWeb &&
        user.imagePath != null &&
        user.imagePath!.isNotEmpty) {
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

              ProfileAvatar(
                image: avatarImage,
                displayName: displayName,
                green: _green,
                iconColor: iconColor,
                backgroundColor: isDark
                    ? const Color(0xFF2C2C2E)
                    : Colors.white,
                isDark: isDark,
                onPickImage: _pickProfileImage,
              ),

              const SizedBox(height: 16),

              ProfileHeader(
                name: displayName,
                quote: displayQuote,
                textColor: textColor,
                subTextColor: subTextColor,
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

              ProfileOptionTile(
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
              ProfileOptionTile(
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
              ProfileOptionTile(
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

