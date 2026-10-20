import 'package:flutter/material.dart';

import '../completed/completed_tasks_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/theme/app_palette.dart';
import '../todo/my_tasks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyTasksScreen(),
    CompletedTasksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.navBar,
          border: Border(
            top: BorderSide(color: palette.navBarBorder, width: 1),
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
                  activeColor: AppPalette.green,
                  inactiveColor: palette.navInactive,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment_outlined,
                  label: 'To Do',
                  isSelected: _currentIndex == 1,
                  activeColor: AppPalette.green,
                  inactiveColor: palette.navInactive,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavBarItem(
                  icon: Icons.assignment_turned_in_outlined,
                  activeIcon: Icons.assignment_turned_in_outlined,
                  label: 'Completed',
                  isSelected: _currentIndex == 2,
                  activeColor: AppPalette.green,
                  inactiveColor: palette.navInactive,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  activeColor: AppPalette.green,
                  inactiveColor: palette.navInactive,
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
              Icon(isSelected ? activeIcon : icon, size: 26, color: color),
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
