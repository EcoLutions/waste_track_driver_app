import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class NextWaypointCard extends StatelessWidget {
  const NextWaypointCard({
    required this.waypoint,
    required this.distanceToWaypoint,
    this.onMarkAsCollected,
    super.key,
  });

  final WayPointWithContainer waypoint;
  final double? distanceToWaypoint;
  final VoidCallback? onMarkAsCollected;

  @override
  Widget build(BuildContext context) {
    final container = waypoint.container;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con distancia
        Row(
          children: [
            // Número de secuencia
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${waypoint.sequenceOrder}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Título
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximo Punto',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    container.containerType.displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Distancia
            if (distanceToWaypoint != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  distanceToWaypoint! < 1000
                      ? '${distanceToWaypoint!.toStringAsFixed(0)} m'
                      : '${(distanceToWaypoint! / 1000).toStringAsFixed(2)} km',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        Divider(color: Colors.grey[200], height: 1),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.delete_outline,
                label: 'Tipo',
                value: container.containerType.displayName,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.water_drop_outlined,
                label: 'Llenado',
                value: '${container.fillPercentage.toStringAsFixed(0)}%',
                valueColor: _getFillColor(container.fillPercentage),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.warning_amber_rounded,
                label: 'Prioridad',
                value: waypoint.wayPoint.priority.displayName,
                valueColor: _getPriorityColor(waypoint.wayPoint.priority),
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_on_outlined,
                label: 'Ubicación',
                value: '${container.latitude.toStringAsFixed(4)}, ${container.longitude.toStringAsFixed(4)}',
                valueStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (onMarkAsCollected != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMarkAsCollected,
              icon: const Icon(Icons.check_circle_outline, size: 22),
              label: const Text(
                'Marcar como Recolectado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ?? TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getFillColor(double percentage) {
    if (percentage >= 80) return Colors.red;
    if (percentage >= 50) return Colors.orange;
    return Colors.green;
  }

  Color _getPriorityColor(priority) {
    final priorityStr = priority.toString().split('.').last.toLowerCase();

    if (priorityStr.contains('critical')) return Colors.red;
    if (priorityStr.contains('high')) return Colors.orange;
    if (priorityStr.contains('medium')) return Colors.blue;
    return Colors.grey;
  }
}