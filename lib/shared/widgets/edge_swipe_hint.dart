import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Flechita discreta pegada al borde de la pantalla que insinúa que hay
/// otra página al deslizar. Si se le pasa [onTap] también funciona como
/// botón para cambiar de página (con un área táctil más generosa que el
/// ícono visual, para que sea fácil de tocar sin verse más grande).
/// Se usa dentro de un [Stack] junto con el contenido de la pantalla.
class EdgeSwipeHint extends StatelessWidget {
  final bool alaIzquierda;
  final VoidCallback? onTap;

  const EdgeSwipeHint({super.key, this.alaIzquierda = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final icono = Icon(
      alaIzquierda ? Icons.chevron_left : Icons.chevron_right,
      color: AppColors.secondaryText.withAlpha(90),
      size: 18,
    );

    return Positioned(
      left: alaIzquierda ? 0 : null,
      right: alaIzquierda ? null : 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: onTap == null
            ? Padding(padding: const EdgeInsets.all(4), child: icono)
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: icono,
                ),
              ),
      ),
    );
  }
}
