import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/shared/services/geocoding_service.dart';

class WaypointBottomSheet extends StatefulWidget {
  final WayPointWithContainer waypoint;
  final Position? currentPosition;
  final VoidCallback onMarkAsCollected;

  const WaypointBottomSheet({
    super.key,
    required this.waypoint,
    required this.currentPosition,
    required this.onMarkAsCollected,
  });

  @override
  State<WaypointBottomSheet> createState() => _WaypointBottomSheetState();
}

class _WaypointBottomSheetState extends State<WaypointBottomSheet> {
  final GeocodingService _geocodingService = GeocodingService();
  String? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final address = await _geocodingService.getShortAddress(
      latitude: widget.waypoint.container.latitude,
      longitude: widget.waypoint.container.longitude,
    );

    if (mounted) {
      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = widget.waypoint.container;
    final waypointData = widget.waypoint.wayPoint;
    final fillPercentage = container.fillPercentage;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Título con número de secuencia
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punto ${waypointData.sequenceOrder}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      container.containerType.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(waypointData.status.displayName),
            ],
          ),

          const SizedBox(height: 24),

          // Dirección
          _buildInfoRow(
            Icons.map_outlined,
            'Dirección',
            _loadingAddress
                ? 'Cargando...'
                : _address ?? 'Lat: ${container.latitude.toStringAsFixed(6)}, Lng: ${container.longitude.toStringAsFixed(6)}',
          ),

          const SizedBox(height: 16),

          // Nivel de llenado
          _buildInfoRow(
            Icons.delete_outline,
            'Nivel de llenado',
            '${fillPercentage.toStringAsFixed(0)}%',
            trailing: _buildFillIndicator(fillPercentage),
          ),

          const SizedBox(height: 16),

          // Capacidad
          _buildInfoRow(
            Icons.scale,
            'Capacidad',
            '${container.volumeLiters}L / ${container.maxWeightKg}kg',
          ),

          if (widget.currentPosition != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.navigation,
              'Distancia',
              _calculateDistance(),
            ),
          ],

          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openInMaps(context),
                  icon: const Icon(Icons.directions),
                  label: const Text('Navegar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: waypointData.isCompleted ? null : widget.onMarkAsCollected,
                  icon: Icon(
                    waypointData.isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    waypointData.isCompleted ? 'Completado' : 'Marcar',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor:
                        waypointData.isCompleted ? Colors.grey : AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (trailing != null)
          trailing
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Visited':
        color = AppColors.success;
        break;
      case 'Pending':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFillIndicator(double percentage) {
    Color color;
    if (percentage >= 90) {
      color = AppColors.error;
    } else if (percentage >= 75) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
    }

    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String _calculateDistance() {
    if (widget.currentPosition == null) return 'N/A';

    final distance = Geolocator.distanceBetween(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
      widget.waypoint.container.latitude,
      widget.waypoint.container.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  Future<void> _openInMaps(BuildContext context) async {
    final lat = widget.waypoint.container.latitude;
    final lng = widget.waypoint.container.longitude;
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }
}
