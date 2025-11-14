import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/pages/home/ui/home_page.dart';
import 'package:waste_track_driver_app/pages/login/ui/login_page.dart';
import 'package:waste_track_driver_app/pages/splash/ui/splash_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: _AuthNotifier(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final currentLocation = state.matchedLocation;

        debugPrint('Router Redirect - State: ${authState.runtimeType}, Location: $currentLocation');

        if (authState is AuthValidating) {
          return currentLocation == '/splash' ? null : '/splash';
        }

        if (authState is AuthAuthenticated) {
          debugPrint('Authenticated - Redirecting to /home');
          return currentLocation == '/home' ? null : '/home';
        }

        if (authState is AuthUnauthenticated ||
            authState is AuthInitial ||
            authState is AuthError) {
          return (currentLocation == '/login' || currentLocation == '/splash')
              ? null
              : '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Página no encontrada: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      debugPrint('AuthBloc changed - Notifying GoRouter');
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}