import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/wear/wear_protocol.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import '../../../../shared/widgets/edge_swipe_hint.dart';
import '../../../pagos/presentation/providers/pagos_wear_state.dart';
import '../widgets/pago_visual.dart';
import 'notificacion_detalle_screen.dart';

/// Lista compacta de todos los pagos pendientes/próximos/atrasados del
/// usuario (puede tener varios porque puede estar en varias tandas). Al
/// tocar uno se abre su detalle, que es donde aparece el botón de reportar.
class PagosListaScreen extends StatelessWidget {
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;

  const PagosListaScreen({super.key, this.onAnterior, this.onSiguiente});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PagosWearState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CircularSafeArea(
            padding: 24,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  'Pagos pendientes',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
          EdgeSwipeHint(alaIzquierda: true, onTap: onAnterior),
          EdgeSwipeHint(onTap: onSiguiente),
        ],
      ),
    );
  }

  Widget _buildBody(PagosWearState state) {
    if (state.cargando && state.items.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryText),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.statusOk, size: 26),
            const SizedBox(height: 6),
            Text(
              'Sin pagos pendientes',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) => _PagoRow(item: state.items[index]),
    );
  }
}

class _PagoRow extends StatelessWidget {
  final TandaWearItem item;

  const _PagoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final visual = pagoVisualFor(item.tipo);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NotificacionDetalleScreen(item: item)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: visual.color.withAlpha(100), width: 1),
        ),
        child: Row(
          children: [
            Icon(visual.icono, color: visual.color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.nombreTanda,
                    style: AppTextStyles.body.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    visual.titulo,
                    style: AppTextStyles.body.copyWith(fontSize: 9, color: visual.color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '\$${item.monto.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
