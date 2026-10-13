import 'package:flutter/material.dart';

import '../completed/completed_tasks_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../todo/my_tasks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const Color _green = Color(0xFF15B86C);

  final List<Widget> _screens = const [
    HomeScreen(),
    MyTasksScreen(),
    CompletedTasksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181818) : Colors.white;
    final inactiveColor =
        isDark ? const Color(0xFF8E9196) : const Color(0xFF373A3E);
    final borderColor =
        isDark ? const Color(0xFF282828) : const Color(0xFFEEEEEE);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  activeColor: _green,
                  inactiveColor: inactiveColor,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment_outlined,
                  label: 'To Do',
                  isSelected: _currentIndex == 1,
                  activeColor: _green,
                  inactiveColor: inactiveColor,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavBarItem(
                  icon: Icons.assignment_turned_in_outlined,
                  activeIcon: Icons.assignment_turned_in_outlined,
                  label: 'Completed',
                  isSelected: _currentIndex == 2,
                  activeColor: _green,
                  inactiveColor: inactiveColor,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  activeColor: _green,
                  inactiveColor: inactiveColor,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 26,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
