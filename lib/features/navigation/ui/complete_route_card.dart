import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart' as rt;
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class CompleteRouteCard extends StatelessWidget {
  const CompleteRouteCard({
    required this.route,
    required this.waypoints,
    required this.onCompleteRoute,
    super.key,
  });

  final rt.Route route;
  final List<WayPointWithContainer> waypoints;
  final VoidCallback onCompleteRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de éxito
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 40,
          ),
        ),

        const SizedBox(height: 16),

        // Título
        const Text(
          '¡Ruta Completada!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Has completado todos los puntos de recolección',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Resumen de la ruta
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildSummaryItem(
                icon: Icons.check_circle_outline,
                label: 'Puntos completados',
                value: '${waypoints.length}',
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                icon: Icons.straighten,
                label: 'Distancia total',
                value: route.formattedTotalDistance,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                icon: Icons.access_time,
                label: 'Tiempo estimado',
                value: route.formattedEstimatedDuration,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Botón Finalizar Ruta
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCompleteRoute,
            icon: const Icon(Icons.flag, size: 22),
            label: const Text(
              'Finalizar Ruta',
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
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
}