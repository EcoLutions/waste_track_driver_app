import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/app/di/injection_container.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_bloc.dart';
import 'package:waste_track_driver_app/pages/home/ui/home_page.dart';
import 'package:waste_track_driver_app/pages/login/ui/login_page.dart';
import 'package:waste_track_driver_app/pages/main_navigation/ui/main_navigation_page.dart';
import 'package:waste_track_driver_app/pages/profile/ui/profile_page.dart';
import 'package:waste_track_driver_app/pages/route_history/ui/route_history_page.dart';
import 'package:waste_track_driver_app/pages/route_map/route_map_page.dart';
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
          // Si está autenticado y está en splash o login, redirigir a home
          if (currentLocation == '/splash' || currentLocation == '/login') {
            debugPrint('Authenticated - Redirecting to /home');
            return '/home';
          }
          return null;
        }

        if (authState is AuthUnauthenticated ||
            authState is AuthInitial ||
            authState is AuthError) {
          // Si no está autenticado, permitir solo splash y login
          if (currentLocation != '/login' && currentLocation != '/splash') {
            return '/login';
          }
          return null;
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

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) {
                    return BlocProvider(
                      create: (_) => sl<HomeRouteBloc>(),
                      child: const HomePage(),
                    );
                  },
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  name: 'history',
                  builder: (context, state) => const RouteHistoryPage(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/route-map/:id',
          name: 'route-map',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RouteMapPage(routeId: id);
          },
        ),
        GoRoute(
          path: '/route-details/:id',
          name: 'route-details',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return Scaffold(
              appBar: AppBar(title: Text('Detalles Ruta $id')),
              body: const Center(child: Text('Route Details Page - TODO')),
            );
          },
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