// Testa se a tela inicial mostra a logo do app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ja_deu_play/screens/home_screen.dart';
import 'package:ja_deu_play/widgets/logo_app.dart';

void main() {
  testWidgets('Tela inicial mostra a logo do app', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(LogoApp), findsOneWidget);
  });
}
