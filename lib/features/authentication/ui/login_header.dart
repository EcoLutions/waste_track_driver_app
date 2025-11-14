import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/app/theme/app_text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    required this.scaleAnimation, required this.fadeAnimation, super.key,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo con animación
        ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Image.asset(
                  'assets/images/logo-with-name.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // Título
        Text(
          'Bienvenido',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtítulo
        Text(
          'Inicia sesión con tu cuenta de conductor',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.greyLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}