import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart' as rt;
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class RouteProgressCard extends StatelessWidget {
  const RouteProgressCard({
    required this.route, required this.waypoints, super.key,
  });
  final rt.Route route;
  final List<WayPointWithContainer> waypoints;

  @override
  Widget build(BuildContext context) {
    final completedCount = waypoints.where((w) => w.wayPoint.isCompleted).length;
    final totalCount = waypoints.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Ruta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$completedCount / $totalCount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const SizedBox(height: 16),

          // Información adicional
          Row(
            children: [
              _buildInfoChip(
                Icons.straighten,
                route.formattedTotalDistance,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.access_time,
                route.formattedEstimatedDuration,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
