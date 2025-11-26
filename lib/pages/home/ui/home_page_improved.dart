import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/pages/home/ui/widgets/active_route_modal.dart';
import 'package:waste_track_driver_app/pages/home/ui/widgets/greeting_header.dart';
import 'package:waste_track_driver_app/pages/home/ui/widgets/quick_stats_card.dart';

class HomePageImproved extends StatefulWidget {
  const HomePageImproved({super.key});

  @override
  State<HomePageImproved> createState() => _HomePageImprovedState();
}

class _HomePageImprovedState extends State<HomePageImproved> {
  bool _isGeneratingWaypoints = false;

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
      context.read<RouteAssignmentBloc>().add(
            LoadActiveRoute(
              driverId: userSessionState.driver!.id,
              districtId: userSessionState.district!.id,
            ),
          );
    } else {
      debugPrint('⚠️ Cannot load route: driverId=${userSessionState.driver?.id}, districtId=${userSessionState.district?.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<RouteAssignmentBloc, RouteAssignmentState>(
          listener: (context, state) {
            // Navegar automáticamente al mapa cuando se generan los waypoints
            if (state is RouteAssignmentAssigned && _isGeneratingWaypoints) {
              _isGeneratingWaypoints = false;
              debugPrint('🗺️ Waypoints generated, navigating to map...');
              context.push('/route-map/${state.route.id}');
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _loadActiveRoute();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con saludo
                  BlocBuilder<UserSessionBloc, UserSessionState>(
                    builder: (context, state) {
                      final name = state is UserSessionLoaded
                          ? (state.driver?.firstName ?? 'Conductor')
                          : 'Conductor';
                      return GreetingHeader(
                        driverName: name,
                        onNotificationTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notificaciones - Próximamente')),
                          );
                        },
                      );
                    },
                  ),

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
                      'Estado de Ruta',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estado de ruta (tarjeta de error o "Sin rutas")
                  BlocBuilder<RouteAssignmentBloc, RouteAssignmentState>(
                    builder: (context, state) {
                      return _buildRouteStatus(context, state);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Card de ruta activa (se mueve con el scroll)
                  BlocBuilder<RouteAssignmentBloc, RouteAssignmentState>(
                    builder: (context, state) {
                      if (state is RouteAssignmentAssigned) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ActiveRouteModal(
                            route: state.route,
                            waypoints: state.waypoints,
                            onTap: () {
                              // Navegar al mapa de ruta
                              context.push('/route-map/${state.route.id}');
                            },
                            onStartRoute: () {
                              // Marcar que estamos generando waypoints
                              _isGeneratingWaypoints = true;
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

  Widget _buildRouteStatus(BuildContext context, RouteAssignmentState state) {
    return switch (state) {
      RouteAssignmentInitial() || RouteAssignmentLoading() => Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(
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
      RouteAssignmentNoRoute() => _buildNoRouteCard(context),
      RouteAssignmentAssigned() => const SizedBox.shrink(), // No mostrar nada, solo el modal flotante
      RouteAssignmentError(:final message) => _buildErrorCard(context, message),
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
            color: Colors.black.withOpacity(0.05),
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
              Icons.check_circle_outline,
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
