import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import '../../data/mock_notificaciones.dart';

class NotificacionCard extends StatefulWidget {
  final NotificacionMock notificacion;

  const NotificacionCard({super.key, required this.notificacion});

  @override
  State<NotificacionCard> createState() => _NotificacionCardState();
}

class _NotificacionCardState extends State<NotificacionCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 24,
        left: 8,
        right: 8,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.statusOk, width: 1),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.statusOk, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData iconData;
    String titulo;
    bool showCheckBtn = false;

    switch (widget.notificacion.tipo) {
      case TipoNotificacion.teTocaCobrar:
        accentColor = AppColors.statusCollect;
        iconData = Icons.emoji_events;
        titulo = '¡Te toca cobrar!';
        break;
      case TipoNotificacion.pagoAtrasado:
        accentColor = AppColors.statusLate;
        iconData = Icons.warning_amber_rounded;
        titulo = 'Pago atrasado';
        showCheckBtn = true;
        break;
      case TipoNotificacion.pagoProximo:
        accentColor = AppColors.statusPending;
        iconData = Icons.access_time;
        titulo = 'Pago próximo';
        break;
      case TipoNotificacion.pagoPendiente:
        accentColor = Colors.blueGrey;
        iconData = Icons.calendar_today;
        titulo = 'Pago pendiente';
        showCheckBtn = true;
        break;
    }

    final bool isCobrar =
        widget.notificacion.tipo == TipoNotificacion.teTocaCobrar;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scaleX: 0.85 + (0.15 * value),
            scaleY: 0.85 + (0.15 * value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
          transformAlignment: Alignment.center,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: CircularSafeArea(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(iconData, color: accentColor, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          titulo,
                          style: isCobrar
                              ? AppTextStyles.title.copyWith(
                                  color: accentColor, fontSize: 15)
                              : AppTextStyles.body.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.notificacion.monto.toStringAsFixed(0)}',
                          style: isCobrar
                              ? AppTextStyles.title.copyWith(fontSize: 20)
                              : AppTextStyles.title.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.notificacion.nombreTanda,
                          style: AppTextStyles.body.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.notificacion.tiempoInfo,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showCheckBtn) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () =>
                                _showToast(context, 'Marcado como pagado'),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.statusOk.withAlpha(51),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.statusOk, width: 1.5),
                              ),
                              child: const Icon(Icons.check,
                                  color: AppColors.statusOk, size: 14),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
