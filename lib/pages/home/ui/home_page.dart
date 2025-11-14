import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_event.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';
import 'package:waste_track_driver_app/app/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSessionBloc, UserSessionState>(
      builder: (context, state) {
        // Si está cargando
        if (state is UserSessionLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos del usuario...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay error
        if (state is UserSessionError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si los datos están cargados
        if (state is UserSessionLoaded) {
          final user = state.user;
          final userProfile = state.userProfile;
          final district = state.district;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                'Inicio',
                style: AppTextStyles.h3.copyWith(color: AppColors.white),
              ),
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.white),
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con información del usuario
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información básica
                  _buildInfoSection(
                    title: 'Información Básica',
                    items: [
                      _InfoItem('Rol', user.primaryRole.displayName),
                      _InfoItem('Estado', user.status.displayName),
                      _InfoItem('Email', user.email),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información del perfil
                  _buildInfoSection(
                    title: 'Perfil de Usuario',
                    items: [
                      _InfoItem('ID Perfil', userProfile.id),
                      _InfoItem('Idioma', userProfile.languageDisplayName),
                      _InfoItem('Zona Horaria', userProfile.timezone),
                      if (userProfile.hasPhoneNumber)
                        _InfoItem('Teléfono', userProfile.phoneNumber!),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información del distrito
                  if (district != null)
                    _buildInfoSection(
                      title: 'Distrito Asignado',
                      items: [
                        _InfoItem('Nombre', district.name),
                        _InfoItem('Código', district.code),
                        _InfoItem('Estado', district.statusDisplayName),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No hay distrito asignado',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Banner en construcción
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.construction,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Más funcionalidades próximamente',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estamos trabajando en el sistema de rutas y recolección',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado inicial (no debería llegar aquí)
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final isLast = items.last == item;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        item.value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.grey.withOpacity(0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _InfoItem {

  _InfoItem(this.label, this.value);
  final String label;
  final String value;
}