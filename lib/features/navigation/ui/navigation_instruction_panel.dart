import 'package:flutter/material.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/features/navigation/model/route_directions.dart';

class NavigationInstructionPanel extends StatelessWidget {
  const NavigationInstructionPanel({
    required this.instruction,
    super.key,
  });

  final NavigationInstruction instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DISTANCIA + ÍCONO
          Row(
            children: [
              _buildManeuverIcon(instruction.maneuver),
              const SizedBox(width: 10),

              // Texto de distancia + instrucción principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instruction.distanceText,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instruction.instruction,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ETA
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                instruction.durationText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManeuverIcon(NavigationManeuver maneuver) {
    IconData icon;

    switch (maneuver) {
      case NavigationManeuver.turnLeft:
        icon = Icons.turn_left;
        break;
      case NavigationManeuver.turnRight:
        icon = Icons.turn_right;
        break;
      case NavigationManeuver.turnSlightLeft:
        icon = Icons.turn_slight_left;
        break;
      case NavigationManeuver.turnSlightRight:
        icon = Icons.turn_slight_right;
        break;
      case NavigationManeuver.turnSharpLeft:
        icon = Icons.turn_sharp_left;
        break;
      case NavigationManeuver.turnSharpRight:
        icon = Icons.turn_sharp_right;
        break;
      case NavigationManeuver.roundabout:
        icon = Icons.roundabout_left;
        break;
      case NavigationManeuver.straight:
        icon = Icons.arrow_upward;
        break;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 28,
        color: AppColors.primary,
      ),
    );
  }
}
