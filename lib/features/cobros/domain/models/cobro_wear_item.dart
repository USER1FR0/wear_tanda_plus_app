/// Un turno de cobro (ciclo donde el usuario es el beneficiario), ya sea
/// uno pasado (ciclo cerrado, el bote ya se recibió) o el próximo (el
/// ciclo actualmente abierto de la tanda, si le toca a él).
enum CobroWearEstado { pasado, proximo }

class CobroWearItem {
  final String cicloId;
  final String tandaId;
  final String nombreTanda;
  final double monto;
  final DateTime? fecha;
  final int numeroCiclo;
  final CobroWearEstado estado;

  CobroWearItem({
    required this.cicloId,
    required this.tandaId,
    required this.nombreTanda,
    required this.monto,
    this.fecha,
    required this.numeroCiclo,
    required this.estado,
  });
}
