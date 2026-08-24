import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/wear/wear_protocol.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import 'pago_visual.dart';

class NotificacionCard extends StatefulWidget {
  final TandaWearItem item;
  final bool reportando;
  final Future<void> Function() onReportar;

  const NotificacionCard({
    super.key,
    required this.item,
    required this.reportando,
    required this.onReportar,
  });

  @override
  State<NotificacionCard> createState() => _NotificacionCardState();
}

class _NotificacionCardState extends State<NotificacionCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 24,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.statusOk, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.statusOk, size: 16),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  String _formatearFechaLimite(DateTime? fechaLimite) {
    if (fechaLimite == null) return '';
    final dias = fechaLimite.difference(DateTime.now()).inDays;
    if (dias > 0) return 'vence en $dias día${dias == 1 ? '' : 's'}';
    if (dias < 0) return 'venció hace ${-dias} día${-dias == 1 ? '' : 's'}';
    return 'vence hoy';
  }

  @override
  Widget build(BuildContext context) {
    final visual = pagoVisualFor(widget.item.tipo);
    final accentColor = visual.color;
    final iconData = visual.icono;
    final titulo = visual.titulo;
    final showCheckBtn = visual.permiteReportar;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scaleX: 0.8 + (0.2 * value),
            scaleY: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          // Feedback de tap (solo UI)
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          transformAlignment: Alignment.center,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: CircularSafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: accentColor, size: 26),
                  const SizedBox(height: 4),
                  Text(
                    titulo,
                    style: AppTextStyles.body.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${widget.item.monto.toStringAsFixed(0)}',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.nombreTanda,
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatearFechaLimite(widget.item.fechaLimite),
                    style: AppTextStyles.body.copyWith(fontSize: 12, color: Colors.white70),
                  ),
                  if (showCheckBtn) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: widget.reportando
                          ? null
                          : () async {
                              await widget.onReportar();
                              if (!context.mounted) return;
                              _showToast(context, 'Reportado, esperando confirmación');
                              await Future.delayed(const Duration(milliseconds: 900));
                              if (context.mounted) Navigator.of(context).pop();
                            },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.statusOk.withAlpha(51), // approx 0.2 opacity
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.statusOk, width: 2),
                        ),
                        child: widget.reportando
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.statusOk,
                                ),
                              )
                            : const Icon(Icons.check, color: AppColors.statusOk, size: 16),
                      ),
                    ),
                  ],
                  // Espacio al fondo para no tapar los dots
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
