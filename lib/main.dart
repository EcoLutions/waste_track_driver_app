import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_event.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_event.dart';
import 'package:waste_track_driver_app/app/di/injection_container.dart' as di;
import 'package:waste_track_driver_app/app/router/app_router.dart';
import 'package:waste_track_driver_app/app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection container initialization
  await di.init();

  runApp(const EcoLutionsDriverApp());
}

class EcoLutionsDriverApp extends StatelessWidget {
  const EcoLutionsDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc - Maneja autenticación (token, roles)
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()
            ..add(const TokenValidationRequested()),
        ),

        // UserSessionBloc - Maneja contexto del usuario (User, UserProfile, District)
        BlocProvider<UserSessionBloc>(
          create: (context) => di.sl<UserSessionBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Cuando se autentica exitosamente, cargar datos del usuario
          if (state is AuthAuthenticated) {
            context.read<UserSessionBloc>().add(
              LoadUserSession(userId: state.userId),
            );
          }

          // Cuando cierra sesión, limpiar datos del usuario
          if (state is AuthUnauthenticated) {
            context.read<UserSessionBloc>().add(const ClearUserSession());
          }
        },
        child: MaterialApp.router(
          title: 'EcoLutions Driver',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}