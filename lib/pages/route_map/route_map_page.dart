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

        _updateCameraPosition(position);
        _startLocationTracking();

        final routeBloc = context.read<RouteAssignmentBloc>();
        final currentState = routeBloc.state;

        if (currentState is RouteAssignmentAssigned) {
          _logger.i('Location ready, loading directions...');
          await _loadGoogleDirections(currentState);
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
    _logger.d(' Waypoint tapped: ${waypoint.wayPoint.id}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WaypointBottomSheet(
        waypoint: waypoint,
        currentPosition: _navState.currentPosition,
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
                Positioned(
                  bottom: 160,
                  left: 0,
                  right: 0,
                  child: NextWaypointCard(
                    waypoint: _navState.nextWaypoint!,
                    distanceToWaypoint: _navState.distanceToNextWaypoint,
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
                bottom: 30,
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