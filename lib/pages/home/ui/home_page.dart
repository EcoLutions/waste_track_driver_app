import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/home_driver_stats/ui/quick_stats_card.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_bloc.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_event.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_state.dart';
import 'package:waste_track_driver_app/features/home_route/ui/active_route_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveRoute();
    });
  }

  void _loadActiveRoute() {
    final userSessionState = context.read<UserSessionBloc>().state;

    if (userSessionState.driver != null && userSessionState.district != null) {
      context.read<HomeRouteBloc>().add(
        LoadActiveRoute(
          driverId: userSessionState.driver!.id,
          districtId: userSessionState.district!.id,
        ),
      );
    } else {
      debugPrint(
        'Cannot load route: driverId=${userSessionState.driver?.id}, '
            'districtId=${userSessionState.district?.id}',
      );
    }
  }

  void _refreshRoute() {
    final userSessionState = context.read<UserSessionBloc>().state;

    if (userSessionState.driver != null && userSessionState.district != null) {
      context.read<HomeRouteBloc>().add(
        RefreshActiveRoute(
          driverId: userSessionState.driver!.id,
          districtId: userSessionState.district!.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<UserSessionBloc, UserSessionState>(
          listener: (context, state) {
            if (state is UserSessionLoaded) {
              debugPrint('✅ User session loaded, loading active route...');
              _loadActiveRoute();
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshRoute();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas rápidas
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: QuickStatsCard(),
                  ),

                  const SizedBox(height: 24),

                  // Título de sección
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Estado de Rutas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estado de ruta
                  BlocBuilder<HomeRouteBloc, HomeRouteState>(
                    builder: (context, state) {
                      return _buildRouteStatus(context, state);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Card de ruta activa (solo si hay ruta)
                  BlocBuilder<HomeRouteBloc, HomeRouteState>(
                    builder: (context, state) {
                      if (state is HomeRouteFound) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ActiveRouteModal(
                            route: state.route,
                            onStartRoute: () {
                              context.push('/route-map/${state.route.id}');
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteStatus(BuildContext context, HomeRouteState state) {
    return switch (state) {
      HomeRouteInitial() || HomeRouteLoading() => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando información de rutas...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      HomeRouteNotFound() => _buildNoRouteCard(context),
      HomeRouteFound() => const SizedBox.shrink(),
      HomeRouteError(:final message) => _buildErrorCard(context, message),
    };
  }

  Widget _buildNoRouteCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.route_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin rutas asignadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes rutas programadas en este momento',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Esperando nuevas rutas...',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 40),
          const SizedBox(height: 12),
          Text(
            'Error al cargar datos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadActiveRoute,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}