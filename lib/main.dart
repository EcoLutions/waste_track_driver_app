import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  await di.init();
  runApp(const EcoLutionsDriverApp());
}

class EcoLutionsDriverApp extends StatefulWidget {
  const EcoLutionsDriverApp({super.key});

  @override
  State<EcoLutionsDriverApp> createState() => _EcoLutionsDriverAppState();
}

class _EcoLutionsDriverAppState extends State<EcoLutionsDriverApp> {
  late final AuthBloc _authBloc;
  late final UserSessionBloc _userSessionBloc;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(const TokenValidationRequested());
    _userSessionBloc = di.sl<UserSessionBloc>();
    router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _userSessionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<UserSessionBloc>.value(value: _userSessionBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<UserSessionBloc>().add(
              LoadUserSession(userId: state.userId),
            );
          }

          if (state is AuthUnauthenticated) {
            context.read<UserSessionBloc>().add(const ClearUserSession());
          }
        },
        child: MaterialApp.router(
          title: 'EcoLutions Driver',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}