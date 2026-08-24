import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import '../../../../shared/widgets/edge_swipe_hint.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onCerrarSesion;
  final VoidCallback? onSiguiente;

  const DashboardScreen({super.key, this.onCerrarSesion, this.onSiguiente});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _nombre;

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final nombre = await context.read<SecureStorageService>().getUserName();
    if (mounted) setState(() => _nombre = nombre);
  }

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: const Text(
          '¿Vincular este reloj a otra cuenta?',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sí', style: TextStyle(color: AppColors.statusLate)),
          ),
        ],
      ),
    );
    if (confirmar == true) widget.onCerrarSesion?.call();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _nombre;
    final inicial = (nombre != null && nombre.isNotEmpty) ? nombre.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CircularSafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Hola,',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                Text(
                  nombre ?? '...',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),
                const SizedBox(height: 16), // Espacio para los dots globales
              ],
            ),
          ),
          EdgeSwipeHint(onTap: widget.onSiguiente),
          if (widget.onCerrarSesion != null)
            Positioned(
              top: 28,
              right: 28,
              child: GestureDetector(
                onTap: () => _confirmarCerrarSesion(context),
                child: const Icon(Icons.logout, color: AppColors.secondaryText, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
