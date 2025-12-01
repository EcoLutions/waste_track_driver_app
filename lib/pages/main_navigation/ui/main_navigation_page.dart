import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/header/ui/greeting_header.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GreetingHeader(
            onNotificationTap: () {},
          ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _buildGreenNavBar(context),
    );
  }

  Widget _buildGreenNavBar(BuildContext context) {
    final index = navigationShell.currentIndex;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
        top: 10,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context,
              index: index,
              itemIndex: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Inicio',
            ),
            _navItem(
              context,
              index: index,
              itemIndex: 1,
              icon: Icons.history_outlined,
              selectedIcon: Icons.history_rounded,
              label: 'Historial',
            ),
            _navItem(
              context,
              index: index,
              itemIndex: 2,
              icon: Icons.person_outline,
              selectedIcon: Icons.person_rounded,
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, {
        required int index,
        required int itemIndex,
        required IconData icon,
        required IconData selectedIcon,
        required String label,
      }) {
    final isSelected = index == itemIndex;

    return GestureDetector(
      onTap: () => navigationShell.goBranch(itemIndex, initialLocation: itemIndex == index),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: isSelected ? 28 : 24,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}