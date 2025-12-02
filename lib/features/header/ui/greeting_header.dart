import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({
    required this.onNotificationTap,
    super.key,
  });

  final VoidCallback onNotificationTap;

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSessionBloc, UserSessionState>(
      builder: (context, state) {
        // Obtenemos el nombre
        final name = state is UserSessionLoaded
            ? state.driver?.firstName ?? 'Conductor'
            : 'Conductor';

        // Obtenemos la URL de la foto (si existe)
        final photoUrl = state is UserSessionLoaded
            ? state.userProfile?.temporalPhotoUrl
            : null;

        // Greeting dependiendo de la hora
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Buenos días'
            : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: _buildHeader(name, greeting, photoUrl),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, String greeting, String? photoUrl) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      margin: EdgeInsets.only(
        top: topPadding + 8,
        left: 18,
        right: 18,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              image: photoUrl != null && photoUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            // Mostrar icono solo si NO hay foto
            child: photoUrl == null || photoUrl.isEmpty
                ? const Icon(Icons.person_rounded, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    )),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: widget.onNotificationTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),

        // Badge (podrías conectarlo al estado también si tienes contador de notificaciones)
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        )
      ],
    );
  }
}