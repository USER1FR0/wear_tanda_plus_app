// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:app_wear/core/network/dio_client.dart';
import 'package:app_wear/core/storage/secure_storage_service.dart';
import 'package:app_wear/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_wear/features/auth/presentation/providers/vinculacion_state.dart';
import 'package:app_wear/features/pagos/domain/repositories/pagos_wear_repository.dart';
import 'package:app_wear/features/pagos/presentation/providers/pagos_wear_state.dart';
import 'package:app_wear/main.dart';

void main() {
  testWidgets('App builds and shows the dashboard', (WidgetTester tester) async {
    // Se arma el mismo arbol de providers que main(), porque RaizScreen los
    // necesita desde su initState. El keystore no existe en un test, pero
    // _verificarSesion() trata ese fallo como "sin sesion".
    final storage = SecureStorageService();
    final dioClient = DioClient(storage);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<SecureStorageService>(create: (_) => storage),
          ChangeNotifierProvider(
            create: (_) => VinculacionState(AuthRepository(dioClient, storage)),
          ),
          ChangeNotifierProvider(
            create: (_) => PagosWearState(PagosWearRepository(dioClient, storage)),
          ),
        ],
        child: const AppWear(),
      ),
    );

    // Verify that our main text appears.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
