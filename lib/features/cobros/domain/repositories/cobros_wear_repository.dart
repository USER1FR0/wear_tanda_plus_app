import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/cobro_wear_item.dart';

/// Recorre las tandas activas del usuario y arma la lista de ciclos donde
/// él es el beneficiario (quien recibe el bote): pasados (ciclo cerrado)
/// y el próximo (el ciclo actualmente abierto, si le toca a él). Mismo
/// patrón que PagosWearRepository: habla directo con el backend.
class CobrosWearRepository {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  CobrosWearRepository(this._dioClient, this._storageService);

  Future<List<CobroWearItem>> obtenerCobros() async {
    final userId = await _storageService.getUserId();
    if (userId == null) return [];

    final tandasResponse = await _dioClient.dio.get('/tandas/mis-tandas');
    final tandas = (tandasResponse.data as List).cast<Map<String, dynamic>>();
    final activas = tandas.where((t) => t['estado'] == 'ACTIVA');

    final items = <CobroWearItem>[];
    for (final tanda in activas) {
      try {
        final detalleResponse = await _dioClient.dio.get('/tandas/${tanda['id']}');
        final detalle = detalleResponse.data as Map<String, dynamic>;
        final ciclos = (detalle['ciclos'] as List?) ?? [];
        if (ciclos.isEmpty) continue;

        final numParticipantes = detalle['numParticipantes'] as int? ?? 0;
        final montoAportacion =
            double.tryParse(detalle['montoAportacion']?.toString() ?? '0') ?? 0.0;
        // El beneficiario de un ciclo recibe el bote completo (su propia
        // parte no se cobra como Pago porque de todas formas la recibiría).
        final boteTotal = montoAportacion * numParticipantes;

        for (final c in ciclos) {
          final ciclo = c as Map<String, dynamic>;
          final turnoBeneficiario = ciclo['turnoBeneficiario'] as Map<String, dynamic>?;
          final usuario = turnoBeneficiario?['usuario'] as Map<String, dynamic>?;
          if (usuario == null || usuario['id'] != userId) continue;

          final cerrado = ciclo['cerrado'] as bool? ?? false;
          final fecha = ciclo['fechaLimite'] != null
              ? DateTime.tryParse(ciclo['fechaLimite'] as String)
              : null;

          items.add(CobroWearItem(
            cicloId: ciclo['id'] as String,
            tandaId: tanda['id'] as String,
            nombreTanda: tanda['nombre'] as String? ?? '',
            monto: boteTotal,
            fecha: fecha,
            numeroCiclo: ciclo['numeroCiclo'] as int? ?? 0,
            estado: cerrado ? CobroWearEstado.pasado : CobroWearEstado.proximo,
          ));
        }
      } catch (_) {
        // Si una tanda falla al cargar su detalle, seguimos con las demás.
        continue;
      }
    }

    // Próximos primero (los más cercanos arriba), luego pasados (el más
    // reciente arriba).
    items.sort((a, b) {
      if (a.estado != b.estado) {
        return a.estado == CobroWearEstado.proximo ? -1 : 1;
      }
      if (a.fecha == null || b.fecha == null) return 0;
      return a.estado == CobroWearEstado.proximo
          ? a.fecha!.compareTo(b.fecha!)
          : b.fecha!.compareTo(a.fecha!);
    });

    return items;
  }
}
