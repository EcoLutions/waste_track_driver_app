import 'dart:ui';
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
      extendBody: true,
      body: Column(
        children: [
          GreetingHeader(
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones - Próximamente'),
                ),
              );
            },
          ),

          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _buildGreenNavBar(context),
    );
  }

  Widget _buildGreenNavBar(BuildContext context) {
    final index = navigationShell.currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 70,
                elevation: 0,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.white,
                iconTheme: MaterialStateProperty.resolveWith(
                      (states) {
                    final selected = states.contains(MaterialState.selected);
                    return IconThemeData(
                      size: selected ? 28 : 24,
                      color: selected ? AppColors.primary : Colors.white,
                    );
                  },
                ),
                labelTextStyle: MaterialStateProperty.resolveWith(
                      (states) {
                    final selected = states.contains(MaterialState.selected);
                    return TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: index,
                backgroundColor: Colors.transparent,
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