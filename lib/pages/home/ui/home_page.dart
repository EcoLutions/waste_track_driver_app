import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/pages/home/ui/route_assigned_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🏠 HomePage - initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveRoute();
    });
  }

  void _loadActiveRoute() {
    debugPrint('🏠 HomePage - _loadActiveRoute called');
    try {
      final authState = context.read<AuthBloc>().state;
      debugPrint('🏠 Auth State: ${authState.runtimeType}');
      debugPrint('🏠 User ID: ${authState.userId}');

      if (authState.userId != null) {
        debugPrint('🏠 Loading route for driver: ${authState.userId}');
        context.read<RouteAssignmentBloc>().add(
          LoadActiveRoute(driverId: authState.userId!),
        );
      } else {
        debugPrint('⚠️ No userId found in AuthState');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading active route: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 HomePage - build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveRoute,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones - TODO')),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<RouteAssignmentBloc, RouteAssignmentState>(
        listener: (context, state) {
          debugPrint('🏠 RouteAssignment State: ${state.runtimeType}');

          if (state is RouteAssignmentAssigned &&
              state.route.status == RouteStatus.inProgress) {
            debugPrint('🏠 Route in progress, redirecting...');
            context.go('/route-active');
          }

          if (state is RouteAssignmentError) {
            debugPrint('❌ RouteAssignment Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint('🏠 Building UI for state: ${state.runtimeType}');
          return RefreshIndicator(
            onRefresh: () async {
              _loadActiveRoute();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, RouteAssignmentState state) {
    return switch (state) {
      RouteAssignmentInitial() => _buildLoadingState('Inicializando...'),
      RouteAssignmentLoading() => _buildLoadingState('Cargando rutas...'),
      RouteAssignmentNoRoute() => _buildNoRouteState(context),
      RouteAssignmentAssigned(:final route, :final waypoints) =>
          _buildRouteAssignedState(context, route, waypoints),
      RouteAssignmentError(:final message) => _buildErrorState(context, message),
    };
  }

  Widget _buildLoadingState(String message) {
    debugPrint('🏠 Building loading state: $message');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    debugPrint('🏠 Building error state: $message');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadActiveRoute,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRouteState(BuildContext context) {
    debugPrint('🏠 Building no route state');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Sin rutas asignadas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes rutas programadas para hoy',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () {
                context.go('/history');
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver Historial'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteAssignedState(
      BuildContext context,
      route,
      waypoints,
      ) {
    debugPrint('🏠 Building route assigned state');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ruta Asignada',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RouteAssignedCard(
          route: route,
          waypoints: waypoints,
          onViewMap: () {
            context.push('/route-map/${route.id}');
          },
          onViewDetails: () {
            context.push('/route-details/${route.id}');
          },
          onStartRoute: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Iniciando ruta...'),
              ),
            );
          },
        ),
      ],
    );
  }
}