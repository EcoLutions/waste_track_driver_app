import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_track_driver_app/app/di/injection_container.dart' as di;
import 'package:waste_track_driver_app/app/router/app_router.dart';
import 'package:waste_track_driver_app/app/theme/app_theme.dart';
import 'package:waste_track_driver_app/features/auth/model/auth_bloc.dart';

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
    return BlocProvider(
      // AuthBloc global
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'EcoLutions Driver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}