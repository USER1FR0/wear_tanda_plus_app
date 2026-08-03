import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/wear/wear_protocol.dart';
import '../../../../shared/widgets/circular_safe_area.dart';

class NotificacionCard extends StatefulWidget {
  final TandaWearItem item;
  final bool reportando;
  final VoidCallback onReportar;

  const NotificacionCard({
    super.key,
    required this.item,
    required this.reportando,
    required this.onReportar,
  });

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

  /// El celular manda una fecha límite; aquí se traduce a algo legible en la
  /// pantalla chica del reloj.
  String _formatearFechaLimite(DateTime? fechaLimite) {
    if (fechaLimite == null) return '';
    final dias = fechaLimite.difference(DateTime.now()).inDays;
    if (dias > 0) return 'vence en $dias día${dias == 1 ? '' : 's'}';
    if (dias < 0) return 'venció hace ${-dias} día${-dias == 1 ? '' : 's'}';
    return 'vence hoy';
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData iconData;
    String titulo;
    bool showCheckBtn = false;

    switch (widget.item.tipo) {
      case TandaWearTipo.pagoAtrasado:
        accentColor = AppColors.statusLate;
        iconData = Icons.warning_amber_rounded;
        titulo = 'Pago atrasado';
        showCheckBtn = true;
        break;
      case TandaWearTipo.pagoProximo:
        accentColor = AppColors.statusPending;
        iconData = Icons.access_time;
        titulo = 'Pago próximo';
        showCheckBtn = true;
        break;
      case TandaWearTipo.pagoPendiente:
        accentColor = Colors.blueGrey;
        iconData = Icons.calendar_today;
        titulo = 'Pago pendiente';
        showCheckBtn = true;
        break;
      case TandaWearTipo.pagoReportado:
        accentColor = AppColors.statusOk;
        iconData = Icons.hourglass_top;
        titulo = 'Ya reportado';
        showCheckBtn = false;
        break;
    }

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
                          style: AppTextStyles.body.copyWith(
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
                          '\$${widget.item.monto.toStringAsFixed(0)}',
                          style: AppTextStyles.title.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.nombreTanda,
                          style: AppTextStyles.body.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatearFechaLimite(widget.item.fechaLimite),
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
                            onTap: widget.reportando
                                ? null
                                : () {
                                    widget.onReportar();
                                    _showToast(
                                      context,
                                      'Reportado, esperando confirmación',
                                    );
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.statusOk.withAlpha(51),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.statusOk, width: 1.5),
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
                                  : const Icon(Icons.check,
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
