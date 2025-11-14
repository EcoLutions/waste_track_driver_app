import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_event.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const TokenValidationRequested());

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Browse by status
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo-with-name.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 48),

              const Text(
                'Driver App',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),

              const SizedBox(height: 16),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Text(
                    state is AuthValidating
                        ? 'Verificando sesión...'
                        : 'Cargando...',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}