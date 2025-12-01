import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';
import 'package:waste_track_driver_app/features/navigation/model/navigation_service.dart';
import 'package:waste_track_driver_app/features/navigation/model/navigation_state.dart';
import 'package:waste_track_driver_app/features/navigation/ui/navigation_instruction_panel.dart';
import 'package:waste_track_driver_app/features/navigation/ui/next_waypoint_card.dart';
import 'package:waste_track_driver_app/features/navigation/ui/route_progress_card.dart';
import 'package:waste_track_driver_app/features/navigation/ui/waypoint_bottom_sheet.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/shared/services/location_service.dart';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({
    required this.routeId,
    super.key,
  });

  final String routeId;

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  final Logger _logger = Logger();
  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService();

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  NavigationState _navState = NavigationState.initial();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingMap = true;
  bool _isLoadingDirections = false;
  double _sheetPosition = 0.35;

  @override
  void initState() {
    super.initState();
    _logger.i('RouteMapPage initState - routeId: ${widget.routeId}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRouteLoaded();
      _initializeLocation();
    });
  }

  void _ensureRouteLoaded() {
    final routeBloc = context.read<RouteAssignmentBloc>();
    final currentState = routeBloc.state;

    _logger.d('Current RouteAssignmentBloc state: ${currentState.runtimeType}');

    if (currentState is! RouteAssignmentAssigned) {
      _logger.i('Route not loaded, loading now...');
      final userSessionState = context.read<UserSessionBloc>().state;

      if (userSessionState.driver != null && userSessionState.district != null) {
        routeBloc.add(LoadActiveRoute(
          driverId: userSessionState.driver!.id,
          districtId: userSessionState.district!.id,
        ));
      } else {
        _logger.e('No driverId or districtId available');
      }
    } else {
      _logger.i('Route already loaded with ${currentState.waypoints.length} waypoints');
      _updateMarkers(currentState);
    }
  }

  Future<void> _initializeLocation() async {
    _logger.i('Initializing location...');

    try {
      final hasPermission = await _locationService.checkPermissions();
      _logger.d('Location permission: $hasPermission');

      if (!hasPermission) {
        _logger.w('Location permissions denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de ubicación'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoadingMap = false);
        return;
      }

      final position = await _locationService.getCurrentLocation();
      _logger.d('Current position: ${position?.latitude}, ${position?.longitude}');

      if (position != null && mounted) {
        setState(() {
          _navState = _navState.copyWith(currentPosition: position);
          _isLoadingMap = false;
        });

        _startLocationTracking();

        final routeBloc = context.read<RouteAssignmentBloc>();
        final currentState = routeBloc.state;

        if (currentState is RouteAssignmentAssigned) {
          _logger.i('Location ready, loading directions...');
          await _loadGoogleDirections(currentState);

          await Future.delayed(const Duration(milliseconds: 500));
          _focusOnNextWaypoint();
        }
      } else {
        _logger.w('Could not get current position');
        setState(() => _isLoadingMap = false);
      }
    } catch (e) {
      _logger.e('Error initializing location: $e');
      setState(() => _isLoadingMap = false);
    }
  }

  void _startLocationTracking() {
    _logger.i('Starting location tracking...');

    _positionStream = _locationService.startLocationTracking(
      intervalSeconds: 1,
    ).listen((position) {
      _logger.d('Location update: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        setState(() {
          _navState = _navState.copyWith(currentPosition: position);
        });

        context.read<RouteAssignmentBloc>().add(
          UpdateDriverLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
            speed: position.speed,
          ),
        );

        if (_navState.isNavigationMode) {
          _updateNavigationState();
          _updateCameraPosition(position);
        }
      }
    });
  }

  Future<void> _updateMarkersAndDirections(RouteAssignmentAssigned state) async {
    _logger.i('Updating markers and directions...');

    final nextWaypoint = _navigationService.getNextWaypoint(state.waypoints);

    final distanceToNext = _navigationService.calculateDistanceToWaypoint(
      _navState.currentPosition,
      nextWaypoint,
    );

    setState(() {
      _navState = _navState.copyWith(
        nextWaypoint: nextWaypoint,
        distanceToNextWaypoint: distanceToNext,
      );
    });

    _updateMarkers(state);

    if (_navState.currentPosition != null) {
      await _loadGoogleDirections(state);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _focusOnNextWaypoint();
  }

  void _updateMarkers(RouteAssignmentAssigned state) {
    _logger.d('Updating ${state.waypoints.length} markers');

    final markers = <Marker>{};

    if (_navState.currentPosition != null && !_navState.isNavigationMode) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _navState.currentPosition!.latitude,
            _navState.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ),
      );
    }

    for (final waypoint in state.waypoints) {
      final container = waypoint.container;

      markers.add(
        Marker(
          markerId: MarkerId(waypoint.wayPoint.id),
          position: LatLng(container.latitude, container.longitude),
          icon: _getMarkerIcon(waypoint.wayPoint.status),
          onTap: () => _onWaypointTap(waypoint),
          infoWindow: InfoWindow(
            title: 'Punto ${waypoint.wayPoint.sequenceOrder}',
            snippet: '${container.containerType.displayName} - ${container.fillPercentage.toStringAsFixed(0)}%',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }

    _logger.d('Markers updated: ${_markers.length} total');
  }

  Future<void> _loadGoogleDirections(RouteAssignmentAssigned state) async {
    if (_navState.currentPosition == null) {
      _logger.w('Cannot load directions without current position');
      return;
    }

    setState(() {
      _isLoadingDirections = true;
    });

    _logger.i('Loading Google Directions API...');

    final directions = await _navigationService.loadDirections(
      currentPosition: _navState.currentPosition!,
      waypoints: state.waypoints,
    );

    if (directions != null && mounted) {
      _logger.i('Directions loaded successfully');

      final simplifiedPoints = _simplifyPolyline(directions.polylinePoints);

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: simplifiedPoints,
        color: AppColors.primary,
        width: 5,
        geodesic: true,
      );

      setState(() {
        _navState = _navState.copyWith(directions: directions);
        _polylines = {polyline};
        _isLoadingDirections = false;
      });

      _updateNavigationState();

      if (!_navState.isNavigationMode && _mapController != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted && _mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(directions.bounds, 80),
          );
        }
      }
    } else {
      _logger.e('Failed to load directions');
      setState(() {
        _isLoadingDirections = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar la ruta. Usando ruta aproximada.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<LatLng> _simplifyPolyline(List<LatLng> points) {
    if (points.length <= 50) return points;

    final simplified = <LatLng>[];
    for (int i = 0; i < points.length; i += 2) {
      simplified.add(points[i]);
    }
    if (points.length % 2 != 0) {
      simplified.add(points.last);
    }

    _logger.d('Polyline simplified: ${points.length} → ${simplified.length} points');
    return simplified;
  }

  void _updateNavigationState() {
    final currentInstruction = _navigationService.getCurrentInstruction(
      _navState.currentPosition,
      _navState.directions,
    );

    if (currentInstruction != _navState.currentInstruction) {
      setState(() {
        _navState = _navState.copyWith(currentInstruction: currentInstruction);
      });
      _logger.d('Current instruction updated: ${currentInstruction?.instruction}');
    }

    final distanceToNext = _navigationService.calculateDistanceToWaypoint(
      _navState.currentPosition,
      _navState.nextWaypoint,
    );

    if (distanceToNext != _navState.distanceToNextWaypoint) {
      setState(() {
        _navState = _navState.copyWith(distanceToNextWaypoint: distanceToNext);
      });
    }
  }

  void _updateCameraPosition(Position position) {
    if (_mapController == null) return;

    final zoom = _navState.isNavigationMode ? 17.5 : 15.0;
    final tilt = _navState.isNavigationMode ? 45.0 : 0.0;
    final bearing = _navState.isNavigationMode ? position.heading : 0.0;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        ),
      ),
    );
  }

  void _focusOnNextWaypoint() {
    if (_mapController == null || _navState.nextWaypoint == null) return;

    final nextWaypoint = _navState.nextWaypoint!;
    final waypointLat = nextWaypoint.container.latitude;
    final waypointLng = nextWaypoint.container.longitude;

    const latOffset = 0.002;
    final adjustedLat = waypointLat + latOffset;

    _logger.i('📍 Enfocando en el siguiente waypoint #${nextWaypoint.sequenceOrder}');

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(adjustedLat, waypointLng),
          zoom: 16.5,
          tilt: 0.0,
          bearing: 0.0,
        ),
      ),
    );
  }

  void _toggleNavigationMode() {
    _logger.i('Toggling navigation mode: ${!_navState.isNavigationMode}');

    setState(() {
      _navState = _navState.copyWith(isNavigationMode: !_navState.isNavigationMode);
    });

    final routeBloc = context.read<RouteAssignmentBloc>();
    final currentState = routeBloc.state;
    if (currentState is RouteAssignmentAssigned) {
      _updateMarkers(currentState);
    }

    if (_navState.currentPosition != null) {
      _updateCameraPosition(_navState.currentPosition!);
    }

    if (!_navState.isNavigationMode && _navState.directions != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mapController != null && _navState.directions != null && mounted) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_navState.directions!.bounds, 80),
          );
        }
      });
    }
  }

  BitmapDescriptor _getMarkerIcon(WayPointStatus status) {
    switch (status) {
      case WayPointStatus.visited:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case WayPointStatus.pending:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case WayPointStatus.skipped:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _onWaypointTap(WayPointWithContainer waypoint) {
    _logger.d('Waypoint tapped: ${waypoint.wayPoint.id}');

    // Obtener el siguiente waypoint directamente del BLoC state
    final routeBloc = context.read<RouteAssignmentBloc>();
    final currentState = routeBloc.state;

    WayPointWithContainer? nextWaypoint;
    if (currentState is RouteAssignmentAssigned) {
      nextWaypoint = _navigationService.getNextWaypoint(currentState.waypoints);

      _logger.i(' DEBUG - Total waypoints: ${currentState.waypoints.length}');
      for (var w in currentState.waypoints) {
        _logger.i('   Waypoint #${w.wayPoint.sequenceOrder}: ${w.wayPoint.status} (id: ${w.wayPoint.id})');
      }
      _logger.i('Next waypoint: #${nextWaypoint?.wayPoint.sequenceOrder} (id: ${nextWaypoint?.wayPoint.id})');
      _logger.i('Tapped waypoint: #${waypoint.wayPoint.sequenceOrder} (id: ${waypoint.wayPoint.id})');
    }

    final isNextInSequence = nextWaypoint?.wayPoint.id == waypoint.wayPoint.id;

    _logger.i('isNextInSequence: $isNextInSequence');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WaypointBottomSheet(
        waypoint: waypoint,
        currentPosition: _navState.currentPosition,
        isNextInSequence: isNextInSequence,
        onMarkAsCollected: () {
          _markWaypointAsCollected(waypoint);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _markWaypointAsCollected(WayPointWithContainer waypoint) {
    _logger.i('Marking waypoint as collected: ${waypoint.wayPoint.id}');

    context.read<RouteAssignmentBloc>().add(
      MarkWaypointAsVisited(waypointId: waypoint.wayPoint.id),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Punto ${waypoint.wayPoint.sequenceOrder} marcado como recolectado'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mostrar diálogo de confirmación antes de marcar como recolectado
  void _showConfirmationDialog(WayPointWithContainer waypoint) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text('Confirmar Recolección'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmas que has recolectado el contenedor en este punto?',
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punto #${waypoint.wayPoint.sequenceOrder}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waypoint.container.containerType.displayName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Llenado: ${waypoint.container.fillPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar diálogo
              _markWaypointAsCollected(waypoint); // Marcar como recolectado
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Verificar si todos los waypoints están completados
  bool _areAllWaypointsCompleted(RouteAssignmentAssigned state) {
    return state.waypoints.every((w) => w.wayPoint.status == WayPointStatus.visited);
  }

  /// Mostrar diálogo de finalización de ruta
  void _showCompleteRouteDialog(RouteAssignmentAssigned state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Ruta Completada!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Has completado todos los puntos de recolección de esta ruta.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            _buildRouteSummary(state),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
            },
            child: const Text('Ver Resumen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Finalizar Ruta'),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary(RouteAssignmentAssigned state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            Icons.check_circle_outline,
            'Puntos completados',
            '${state.waypoints.length}',
            AppColors.success,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.straighten,
            'Distancia total',
            state.route.formattedTotalDistance,
            AppColors.primary,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.access_time,
            'Tiempo estimado',
            state.route.formattedEstimatedDuration,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _logger.i('RouteMapPage disposing...');
    _positionStream?.cancel();
    _locationService.stopLocationTracking();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RouteAssignmentBloc, RouteAssignmentState>(
        listener: (context, state) {
          _logger.d('📡 RouteAssignmentBloc state changed: ${state.runtimeType}');

          if (state is RouteAssignmentAssigned) {
            _logger.i('Route assigned with ${state.waypoints.length} waypoints');

            if (_navState.currentPosition != null) {
              _updateMarkersAndDirections(state);
            } else {
              _logger.w('Waiting for location before loading directions...');
              _updateMarkers(state);
            }

            // Verificar si todos los waypoints están completados
            if (_areAllWaypointsCompleted(state)) {
              _logger.i('🎉 All waypoints completed!');
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _showCompleteRouteDialog(state);
                }
              });
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _navState.currentPosition != null
                      ? LatLng(
                    _navState.currentPosition!.latitude,
                    _navState.currentPosition!.longitude,
                  )
                      : const LatLng(-12.0464, -77.0428),
                  zoom: 14,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                trafficEnabled: false,
                onMapCreated: (controller) {
                  _logger.i('Google Map created');
                  _mapController = controller;
                  setState(() => _isLoadingMap = false);
                },
              ),

              if (_isLoadingMap)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando mapa...'),
                      ],
                    ),
                  ),
                ),

              if (_isLoadingDirections)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Calculando ruta...',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_navState.isNavigationMode && !_isLoadingDirections && _navState.currentInstruction != null)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: NavigationInstructionPanel(
                    instruction: _navState.currentInstruction!,
                  ),
                ),

              if (!_navState.isNavigationMode && state is RouteAssignmentAssigned && !_isLoadingDirections)
                Positioned(
                  top: 60,
                  left: 16,
                  right: 16,
                  child: RouteProgressCard(
                    route: state.route,
                    waypoints: state.waypoints,
                  ),
                ),

              if (_navState.nextWaypoint != null && !_isLoadingDirections)
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() {
                      _sheetPosition = notification.extent;
                    });
                    return true;
                  },
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.35, // 35% de la pantalla
                    minChildSize: 0.08, // Minimizado: 8%
                    maxChildSize: 0.4, // Máximo: 40%
                    snap: true,
                    snapSizes: const [0.08, 0.35],
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Handle indicator
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 12, bottom: 8),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // Contenido del card con botón
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: NextWaypointCard(
                                waypoint: _navState.nextWaypoint!,
                                distanceToWaypoint: _navState.distanceToNextWaypoint,
                                onMarkAsCollected: () {
                                  _showConfirmationDialog(_navState.nextWaypoint!);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              Positioned(
                top: _navState.isNavigationMode ? 200 : 200,
                left: 16,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).size.height * _sheetPosition + 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'location',
                      backgroundColor: Colors.white,
                      mini: true,
                      elevation: 4,
                      onPressed: () {
                        if (_navState.currentPosition != null) {
                          _updateCameraPosition(_navState.currentPosition!);
                        }
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FloatingActionButton.extended(
                      heroTag: 'navigation',
                      backgroundColor: _navState.isNavigationMode
                          ? AppColors.primary
                          : Colors.white,
                      elevation: 4,
                      onPressed: _toggleNavigationMode,
                      icon: Icon(
                        _navState.isNavigationMode ? Icons.map : Icons.navigation,
                        color: _navState.isNavigationMode
                            ? Colors.white
                            : AppColors.primary,
                      ),
                      label: Text(
                        _navState.isNavigationMode ? 'Ver Mapa' : 'Navegar',
                        style: TextStyle(
                          color: _navState.isNavigationMode
                              ? Colors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}