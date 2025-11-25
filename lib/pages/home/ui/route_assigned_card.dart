import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart' as entities;
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class RouteAssignedCard extends StatelessWidget {

  const RouteAssignedCard({
    super.key,
    required this.route,
    required this.waypoints,
    required this.onViewMap,
    required this.onViewDetails,
    required this.onStartRoute,
  });
  final entities.Route route;
  final List<WayPointWithContainer> waypoints;
  final VoidCallback onViewMap;
  final VoidCallback onViewDetails;
  final VoidCallback onStartRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canStartRoute = _canStartRoute();
    final timeUntilStart = _getTimeUntilStart();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Asignada',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Distrito: ${route.districtId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Información principal
            _buildInfoRow(
              Icons.location_on_outlined,
              'Puntos de recolección',
              '${waypoints.length}',
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Inicio programado',
              DateFormat('HH:mm a').format(route.scheduledStartAt),
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.route_outlined,
              'Distancia estimada',
              route.formattedTotalDistance,
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.timer_outlined,
              'Duración estimada',
              route.formattedEstimatedDuration,
              theme,
            ),

            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewMap,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Mapa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Detalles'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botón de iniciar ruta o countdown
            if (!canStartRoute)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeUntilStart,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStartRoute,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Ruta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String value,
      ThemeData theme,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _canStartRoute() {
    final now = DateTime.now();
    final startTime = route.scheduledStartAt;
    final difference = startTime.difference(now);

    // Se puede iniciar 15 minutos antes
    return difference.inMinutes <= 15;
  }

  String _getTimeUntilStart() {
    final now = DateTime.now();
    final startTime = route.scheduledStartAt;
    final difference = startTime.difference(now);

    if (difference.isNegative) {
      return 'Ya disponible para iniciar';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'Disponible en ${hours}h ${minutes}m';
    } else {
      return 'Disponible en ${minutes}m';
    }
  }
}