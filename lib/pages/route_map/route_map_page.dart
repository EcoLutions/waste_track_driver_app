import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/pages/route_map/widgets/route_progress_card.dart';
import 'package:waste_track_driver_app/pages/route_map/widgets/waypoint_bottom_sheet.dart';
import 'package:waste_track_driver_app/shared/services/directions_service.dart';
import 'package:waste_track_driver_app/shared/services/location_service.dart';

class RouteMapPage extends StatefulWidget {
  final String routeId;

  const RouteMapPage({
    super.key,
    required this.routeId,
  });

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();

  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionStream;

  RouteAssignmentState? _currentRouteState;
  WayPointWithContainer? _selectedWaypoint;

  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    print('🗺️ RouteMapPage initState - routeId: ${widget.routeId}');

    // ✅ NUEVO: Cargar la ruta activa si no está cargada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRouteLoaded();
    });

    _initializeLocation();
    _startLocationTracking();
  }

  // ✅ NUEVO: Método para asegurar que la ruta esté cargada
  void _ensureRouteLoaded() {
    final routeBloc = context.read<RouteAssignmentBloc>();
    final currentState = routeBloc.state;

    print('📦 Current RouteAssignmentBloc state: ${currentState.runtimeType}');

    // Si no hay ruta asignada, cargarla
    if (currentState is! RouteAssignmentAssigned) {
      print('🔄 Route not loaded, loading now...');
      final userSessionState = context.read<UserSessionBloc>().state;

      if (userSessionState.driver != null && userSessionState.district != null) {
        routeBloc.add(LoadActiveRoute(
          driverId: userSessionState.driver!.id,
          districtId: userSessionState.district!.id,
        ));
      } else {
        print('❌ No driverId or districtId available');
      }
    } else {
      print('✅ Route already loaded with ${currentState.waypoints.length} waypoints');
      // Actualizar marcadores inmediatamente si ya hay ruta
      _currentRouteState = currentState;
      _updateMarkers();
    }
  }

  Future<void> _initializeLocation() async {
    print('📍 Initializing location...');

    try {
      // Verificar permisos primero
      final hasPermission = await _locationService.checkPermissions();
      print('🔐 Location permission: $hasPermission');

      if (!hasPermission) {
        print('⚠️ Location permissions denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de ubicación para usar el mapa'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isLoadingMap = false);
        return;
      }

      final position = await _locationService.getCurrentLocation();
      print('📍 Current position: ${position?.latitude}, ${position?.longitude}');

      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingMap = false;
        });
        _updateCameraPosition(position);
      } else {
        print('⚠️ Could not get current position');
        setState(() => _isLoadingMap = false);
      }
    } catch (e) {
      print('❌ Error initializing location: $e');
      setState(() => _isLoadingMap = false);
    }
  }

  void _startLocationTracking() {
    print('🔄 Starting location tracking...');
    _positionStream = _locationService.startLocationTracking(
      intervalSeconds: 60,
    ).listen((position) {
      print('📍 Location update: ${position.latitude}, ${position.longitude}');
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _updateMarkers();
      }
    });
  }

  void _updateCameraPosition(Position position) {
    print('📹 Updating camera position to: ${position.latitude}, ${position.longitude}');
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  Future<void> _updateMarkers() async {
    print('📍 Updating markers...');

    if (_currentRouteState is! RouteAssignmentAssigned) {
      print('⚠️ No route assigned - cannot update markers');
      return;
    }

    final state = _currentRouteState as RouteAssignmentAssigned;
    print('✅ Route state: ${state.waypoints.length} waypoints');

    final markers = <Marker>{};

    // Marcador de ubicación actual del conductor
    if (_currentPosition != null) {
      print('📍 Adding current location marker');
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ),
      );
    }

    // Marcadores de waypoints
    for (var i = 0; i < state.waypoints.length; i++) {
      final waypoint = state.waypoints[i];
      final container = waypoint.container;

      print('📍 Adding waypoint marker ${i + 1}:');
      print('   - Waypoint ID: ${waypoint.wayPoint.id}');
      print('   - Container ID: ${container.id}');
      print('   - Sequence: ${waypoint.wayPoint.sequenceOrder}');
      print('   - Latitude: ${container.latitude}');
      print('   - Longitude: ${container.longitude}');
      print('   - Type: ${container.containerType.displayName}');
      print('   - Fill: ${container.fillPercentage.toStringAsFixed(1)}%');
      print('   - Status: ${waypoint.wayPoint.status}');

      markers.add(
        Marker(
          markerId: MarkerId(waypoint.wayPoint.id),
          position: LatLng(container.latitude, container.longitude),
          icon: _getMarkerIcon(waypoint.wayPoint.status),
          onTap: () => _onWaypointTap(waypoint),
          infoWindow: InfoWindow(
            title: 'Punto ${waypoint.wayPoint.sequenceOrder}',
            snippet: container.containerType.displayName,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    print('✅ Markers updated: ${_markers.length} total markers');

    // Obtener direcciones entre waypoints
    await _loadDirections(state);
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

  Future<void> _loadDirections(RouteAssignmentAssigned state) async {
    print('🗺️ Loading directions...');

    if (state.waypoints.isEmpty || _currentPosition == null) {
      print('⚠️ Cannot load directions - waypoints: ${state.waypoints.length}, currentPosition: $_currentPosition');
      return;
    }

    // Crear lista de waypoints para la ruta
    final waypoints = state.waypoints
        .map((w) => LatLng(w.container.latitude, w.container.longitude))
        .toList();

    if (waypoints.isEmpty) {
      print('⚠️ Waypoints list is empty');
      return;
    }

    final origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final destination = waypoints.last;
    final intermediatePoints = waypoints.sublist(0, waypoints.length - 1);

    print('🗺️ Origin: ${origin.latitude}, ${origin.longitude}');
    print('🗺️ Destination: ${destination.latitude}, ${destination.longitude}');
    print('🗺️ Intermediate points: ${intermediatePoints.length}');

    // Obtener direcciones
    final result = await _directionsService.getDirections(
      origin: origin,
      destination: destination,
      waypoints: intermediatePoints,
    );

    if (result != null && mounted) {
      print('✅ Directions loaded: ${result.polylinePoints.length} points');
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: result.polylinePoints,
            color: AppColors.primary,
            width: 5,
          ),
        };
      });
    } else {
      print('⚠️ Could not load directions');
    }
  }

  void _onWaypointTap(WayPointWithContainer waypoint) {
    print('👆 Waypoint tapped: ${waypoint.wayPoint.id}');
    setState(() {
      _selectedWaypoint = waypoint;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WaypointBottomSheet(
        waypoint: waypoint,
        currentPosition: _currentPosition,
        onMarkAsCollected: () {
          _markWaypointAsCollected(waypoint);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _markWaypointAsCollected(WayPointWithContainer waypoint) {
    print('✅ Marking waypoint as collected: ${waypoint.wayPoint.id}');

    // Disparar el evento para marcar como visitado en el backend
    context.read<RouteAssignmentBloc>().add(
      MarkWaypointAsVisited(waypointId: waypoint.wayPoint.id),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Punto ${waypoint.wayPoint.sequenceOrder} marcado como recolectado'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    print('🧹 RouteMapPage disposing...');
    _positionStream?.cancel();
    _locationService.stopLocationTracking();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building RouteMapPage');
    print('🎨 Current position: $_currentPosition');
    print('🎨 Markers count: ${_markers.length}');
    print('🎨 Polylines count: ${_polylines.length}');

    return Scaffold(
      body: BlocConsumer<RouteAssignmentBloc, RouteAssignmentState>(
        listener: (context, state) {
          print('📡 RouteAssignmentBloc state changed: ${state.runtimeType}');
          if (state is RouteAssignmentAssigned) {
            print('✅ Route assigned with ${state.waypoints.length} waypoints');
            _currentRouteState = state;
            _updateMarkers();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Mapa de Google
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(-12.1199, -77.0340), // Lima, Perú
                  zoom: 14,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  print('✅ Google Map created successfully!');
                  _mapController = controller;
                  setState(() => _isLoadingMap = false);
                },
              ),

              // Indicador de carga del mapa
              if (_isLoadingMap)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando mapa...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              // Card de progreso de ruta
              if (state is RouteAssignmentAssigned)
                Positioned(
                  top: 60,
                  left: 16,
                  right: 16,
                  child: RouteProgressCard(
                    route: state.route,
                    waypoints: state.waypoints,
                  ),
                ),

              // Botón de regresar (debajo de la card)
              Positioned(
                top: 200,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      print('⬅️ Back button pressed');
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}