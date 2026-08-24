import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/wear/wear_protocol.dart';

/// Cómo se ve cada [TandaWearTipo] en la UI del reloj (color, ícono, texto).
/// Centralizado para que la lista de pagos y el detalle se vean consistentes.
class PagoVisual {
  final Color color;
  final IconData icono;
  final String titulo;
  final bool permiteReportar;

  const PagoVisual({
    required this.color,
    required this.icono,
    required this.titulo,
    required this.permiteReportar,
  });
}

PagoVisual pagoVisualFor(TandaWearTipo tipo) {
  switch (tipo) {
    case TandaWearTipo.pagoAtrasado:
      return const PagoVisual(
        color: AppColors.statusLate,
        icono: Icons.warning_amber_rounded,
        titulo: 'Pago atrasado',
        permiteReportar: true,
      );
    case TandaWearTipo.pagoProximo:
      return const PagoVisual(
        color: AppColors.statusPending,
        icono: Icons.access_time,
        titulo: 'Pago próximo',
        permiteReportar: true,
      );
    case TandaWearTipo.pagoPendiente:
      return const PagoVisual(
        color: Colors.blueGrey,
        icono: Icons.calendar_today,
        titulo: 'Pago pendiente',
        permiteReportar: true,
      );
    case TandaWearTipo.pagoReportado:
      return const PagoVisual(
        color: AppColors.statusOk,
        icono: Icons.hourglass_top,
        titulo: 'Ya reportado',
        permiteReportar: false,
      );
  }
}
