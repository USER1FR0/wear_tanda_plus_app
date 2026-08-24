import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/wear/wear_protocol.dart';
import '../../../pagos/presentation/providers/pagos_wear_state.dart';
import '../widgets/notificacion_card.dart';

/// Pantalla completa a la que se llega al tocar un pago en la lista. Aquí
/// sí aparece el botón para reportarlo (a diferencia de la fila compacta
/// de la lista).
class NotificacionDetalleScreen extends StatelessWidget {
  final TandaWearItem item;

  const NotificacionDetalleScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PagosWearState>();
    return NotificacionCard(
      item: item,
      reportando: state.estaReportando(item.pagoId),
      onReportar: () => state.reportarPago(item.pagoId),
    );
  }
}
