import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/models/cobro_wear_item.dart';
import '../../domain/repositories/cobros_wear_repository.dart';

class CobrosWearState extends ChangeNotifier {
  final CobrosWearRepository _repository;
  CobrosWearState(this._repository);

  List<CobroWearItem> _items = [];
  bool _cargando = false;
  Timer? _autoRefresh;

  List<CobroWearItem> get items => _items;
  bool get cargando => _cargando;

  void iniciar() {
    cargar();
    _autoRefresh?.cancel();
    _autoRefresh = Timer.periodic(const Duration(seconds: 45), (_) => cargar());
  }

  void detener() {
    _autoRefresh?.cancel();
    _items = [];
    notifyListeners();
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    try {
      _items = await _repository.obtenerCobros();
    } catch (_) {
      // Silencioso: el próximo auto-refresco lo vuelve a intentar.
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }
}
