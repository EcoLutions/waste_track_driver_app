import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({
    required this.navigationShell, super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _buildModernNavBar(context),
    );
  }

  Widget _buildModernNavBar(BuildContext context) {
    final index = navigationShell.currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                elevation: 0,
                indicatorColor: AppColors.primary.withOpacity(0.15),
                labelTextStyle: MaterialStateProperty.resolveWith(
                      (states) {
                    final selected = states.contains(MaterialState.selected);
                    return TextStyle(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    );
                  },
                ),
                iconTheme: MaterialStateProperty.resolveWith(
                      (states) {
                    final selected = states.contains(MaterialState.selected);
                    return IconThemeData(
                      size: selected ? 30 : 26,
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade500,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                height: 70,
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedIndex: index,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (i) {
                  navigationShell.goBranch(
                    i,
                    initialLocation: i == index,
                  );
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history_rounded),
                    label: 'Historial',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
