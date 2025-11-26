import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart' as rt;
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

/// Modal flotante estilo Uber que aparece en la parte inferior de la pantalla
/// cuando hay una ruta activa.
class ActiveRouteModal extends StatelessWidget {
  final rt.Route route;
  final List<WayPointWithContainer> waypoints;
  final VoidCallback onTap;

  const ActiveRouteModal({
    super.key,
    required this.route,
    required this.waypoints,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedWaypoints = waypoints.where((w) => w.wayPoint.isCompleted).length;
    final totalWaypoints = waypoints.length;
    final progress = totalWaypoints > 0 ? completedWaypoints / totalWaypoints : 0.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra de progreso
              if (route.status == RouteStatus.inProgress)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            route.status == RouteStatus.inProgress
                                ? Icons.navigation
                                : Icons.route,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.status == RouteStatus.inProgress
                                    ? 'Ruta en Progreso'
                                    : 'Ruta Asignada',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (route.status == RouteStatus.inProgress)
                                Text(
                                  '$completedWaypoints de $totalWaypoints puntos completados',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Text(
                                  'Inicio: ${DateFormat('HH:mm').format(route.scheduledStartAt)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Información de ruta
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.location_on_outlined,
                            'Puntos',
                            '$totalWaypoints',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.straighten,
                            'Distancia',
                            route.totalDistance > 0 
                                ? route.formattedTotalDistance 
                                : 'N/A',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.access_time,
                            'Tiempo',
                            route.estimatedDuration > Duration.zero
                                ? route.formattedEstimatedDuration
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CTA Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.map,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            route.status == RouteStatus.inProgress
                                ? 'Ver Mapa de Ruta'
                                : 'Iniciar Ruta',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
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
}
