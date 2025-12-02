import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_event.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/app/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  File? _selectedImage;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Carga los datos iniciales al controlador cuando el estado está listo
  void _initializeData(dynamic driver) {
    if (!_isEditing && _phoneController.text.isEmpty) {
      _phoneController.text = driver.phoneNumber ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _saveChanges(BuildContext context) {
    context.read<UserSessionBloc>().add(
      SaveProfileChanges(
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        newPhotoFile: _selectedImage,
      ),
    );

    // Limpiamos la selección local y el foco
    setState(() {
      _selectedImage = null;
      _isEditing = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<UserSessionBloc, UserSessionState>(
        listener: (context, state) {
          if (state is UserSessionInitial) {
            // El estado inicial indica que se cerró sesión
            context.go('/login');
          } else if (state is UserSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! UserSessionLoaded) {
            return const Center(child: Text("No se pudo cargar la sesión"));
          }

          final driver = state.driver;
          final userProfile = state.userProfile;

          // Inicializamos el controlador solo una vez con los datos del servidor
          _initializeData(driver);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Avatar con edición
                _buildAvatarSection(userProfile?.temporalPhotoUrl),

                const SizedBox(height: 16),

                // Nombre y Correo
                Text(
                  "${driver?.firstName} ${driver?.lastName}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.user.email,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600]
                  ),
                ),

                const SizedBox(height: 32),

                // Tarjeta de Información Editable
                _buildInfoCard(driver),

                const SizedBox(height: 24),

                // Botón Guardar
                if (_selectedImage != null || _phoneController.text != (driver?.phoneNumber ?? ''))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _saveChanges(context),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text("Guardar Cambios"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                // Opciones adicionales (Historial, etc.)
                _buildOptionsCard(context),

                const SizedBox(height: 24),

                // Botón Cerrar Sesión
                _buildLogoutButton(context),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(String? serverPhotoUrl) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: _getAvatarImage(serverPhotoUrl),
              child: _selectedImage == null && (serverPhotoUrl == null || serverPhotoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? serverUrl) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (serverUrl != null && serverUrl.isNotEmpty) {
      return NetworkImage(serverUrl);
    }
    return null;
  }

  Widget _buildInfoCard(dynamic driver) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary
            ),
          ),
          const SizedBox(height: 24),
          _buildReadOnlyRow(Icons.badge_outlined, 'DNI', driver.documentNumber),
          const Divider(height: 32),
          _buildReadOnlyRow(Icons.credit_card_outlined, 'Licencia', driver.driverLicense),
          const Divider(height: 32),
          // Campo editable para teléfono
          Row(
            children: [
              Icon(Icons.phone_outlined, color: Colors.grey[600], size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teléfono',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                        hintText: 'Ingrese teléfono',
                      ),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) {
                        setState(() { _isEditing = true; });
                      },
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, size: 18, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 22),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            Icons.history_rounded,
            'Historial de Rutas',
                () => context.go('/history'),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildOptionTile(
            Icons.help_outline_rounded,
            'Ayuda y Soporte',
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- MÉTODO AÑADIDO: _buildOptionTile ---
  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
  // -----------------------------------------

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    context.read<UserSessionBloc>().add(const PerformLogout());
                  },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}