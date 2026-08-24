import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/circular_safe_area.dart';
import '../../../../shared/widgets/edge_swipe_hint.dart';
import '../../domain/models/cobro_wear_item.dart';
import '../providers/cobros_wear_state.dart';

/// Lista de los ciclos donde el usuario es el beneficiario: los que ya
/// cobró (pasados) y el que tiene actualmente en curso (próximo a
/// recibir), de todas las tandas donde participa.
class CobrosListaScreen extends StatelessWidget {
  final VoidCallback? onAnterior;

  const CobrosListaScreen({super.key, this.onAnterior});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CobrosWearState>();

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
                  'Pagos recibidos',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
          EdgeSwipeHint(alaIzquierda: true, onTap: onAnterior),
        ],
      ),
    );
  }

  Widget _buildBody(CobrosWearState state) {
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
            const Icon(Icons.inbox_outlined, color: AppColors.secondaryText, size: 26),
            const SizedBox(height: 6),
            Text(
              'Sin cobros por ahora',
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
      itemBuilder: (context, index) => _CobroRow(item: state.items[index]),
    );
  }
}

class _CobroRow extends StatelessWidget {
  final CobroWearItem item;

  const _CobroRow({required this.item});

  String _formatearFecha(DateTime? fecha, bool esProximo) {
    if (fecha == null) return '';
    if (esProximo) {
      final dias = fecha.difference(DateTime.now()).inDays;
      if (dias > 0) return 'en $dias día${dias == 1 ? '' : 's'}';
      if (dias < 0) return 'venció hace ${-dias} día${-dias == 1 ? '' : 's'}';
      return 'hoy';
    }
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final esProximo = item.estado == CobroWearEstado.proximo;
    final color = esProximo ? AppColors.statusCollect : AppColors.statusOk;
    final icono = esProximo ? Icons.arrow_circle_up_outlined : Icons.check_circle_outline;
    final titulo = esProximo ? 'Por recibir' : 'Recibido';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 16),
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
                  '$titulo · ${_formatearFecha(item.fecha, esProximo)}',
                  style: AppTextStyles.body.copyWith(fontSize: 9, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
