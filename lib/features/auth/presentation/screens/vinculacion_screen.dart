import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import '../providers/vinculacion_state.dart';

/// Se muestra cuando el reloj todavía no tiene sesión. Pide un código al
/// backend y espera a que lo confirmen desde el celular.
class VinculacionScreen extends StatefulWidget {
  final VoidCallback onVinculado;

  const VinculacionScreen({super.key, required this.onVinculado});

  @override
  State<VinculacionScreen> createState() => _VinculacionScreenState();
}

class _VinculacionScreenState extends State<VinculacionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VinculacionState>().iniciar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CircularSafeArea(
        child: Consumer<VinculacionState>(
          builder: (context, state, _) {
            if (state.vinculado) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) widget.onVinculado();
              });
            }

            final isError = state.error != null;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.watch_outlined,
                      color: AppColors.primaryText,
                      size: isError ? 20 : 26,
                    ),
                    SizedBox(height: isError ? 4 : 8),
                    Text(
                      'Abre Tandas en tu celular y escribe:',
                      style: AppTextStyles.body.copyWith(
                        fontSize: isError ? 11 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isError ? 4 : 10),
                    if (state.cargando && state.codigo == null)
                      const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryText)
                    else if (isError) ...[
                      Text(
                        state.error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.statusLate,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 32,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => context.read<VinculacionState>().iniciar(),
                          child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ] else if (state.codigo != null)
                      Text(
                        state.codigo!,
                        style: AppTextStyles.title.copyWith(fontSize: 26, letterSpacing: 4),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
