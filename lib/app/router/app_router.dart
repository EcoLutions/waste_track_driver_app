import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/app/di/injection_container.dart';
import 'package:waste_track_driver_app/pages/home/ui/home_page.dart';
import 'package:waste_track_driver_app/pages/login/ui/login_page.dart';
import 'package:waste_track_driver_app/pages/splash/ui/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final _authBloc = sl<AuthBloc>();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // ==================== REDIRECT LOGIC ====================
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';

      /**
       * If validating, keep in splash
       */
      if (authState is AuthValidating && !isGoingToSplash) {
        return '/splash';
      }

      /**
       * If you are authenticated and go to login/splash, redirect to home
       */
      if (authState is AuthAuthenticated) {
        if (isGoingToLogin || isGoingToSplash) {
          return '/home';
        }
      }

      /**
       * If NOT authenticated and NOT going to login/splash, redirect to login
       */
      if (authState is AuthUnauthenticated && !isGoingToLogin && !isGoingToSplash) {
        return '/login';
      }

      // If none of the above, do nothing
      return null;
    },

    // ==================== REFRESH LISTENER ====================
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),

    // ==================== ROUTES ====================
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],

    // ==================== ERROR HANDLER ====================
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

/// Helper to refresh the router when the auth status changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}