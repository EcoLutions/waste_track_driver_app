import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  final String driverName;
  final VoidCallback onNotificationTap;

  const GreetingHeader({
    super.key,
    required this.driverName,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Buenos días';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Icono de saludo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                greetingIcon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Texto de saludo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    driverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Botón de notificaciones
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: onNotificationTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
