import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart' as rt;
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class ActiveRouteModal extends StatelessWidget {
  const ActiveRouteModal({
    required this.route, required this.waypoints, required this.onTap, super.key,
    this.onStartRoute,
  });

  final rt.Route route;
  final List<WayPointWithContainer> waypoints;
  final VoidCallback onTap;
  final VoidCallback? onStartRoute;

  @override
  Widget build(BuildContext context) {
    final completed = waypoints.where((w) => w.wayPoint.isCompleted).length;
    final total = waypoints.length;
    final double progress = total > 0 ? (completed / total).toDouble() : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra de progreso
                  if (route.status == RouteStatus.inProgress)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          route.status == RouteStatus.inProgress
                              ? Icons.navigation_rounded
                              : Icons.route_rounded,
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
                              route.status == RouteStatus.inProgress
                                  ? 'Ruta en Progreso'
                                  : 'Ruta Asignada',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              route.status == RouteStatus.inProgress
                                  ? '$completed de $total puntos completados'
                                  : "Inicio: ${DateFormat('HH:mm').format(route.scheduledStartAt)}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info fila
                  Row(
                    children: [
                      Expanded(child: _info('Puntos', '$total', Icons.location_on)),
                      _divider(),
                      Expanded(child: _info('Distancia', route.formattedTotalDistance, Icons.straighten)),
                      _divider(),
                      Expanded(child: _info('Tiempo', route.formattedEstimatedDuration, Icons.access_time)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BOTÓN PRINCIPAL
                  _buildActionButton(context),
                ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 350.ms)
        .slide(begin: const Offset(0, 0.2), curve: Curves.easeOut));
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.grey[200],
  );

  Widget _info(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isAssigned = route.status == RouteStatus.assigned;

    return GestureDetector(
      onTapDown: (_) {},
      onTap: () {
        if (isAssigned) {
          onStartRoute?.call();
          context.read<RouteAssignmentBloc>().add(
            GenerateWaypoints(routeId: route.id),
          );
        } else {
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              isAssigned ? 'Iniciar Ruta' : 'Ver Mapa de Ruta',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}
