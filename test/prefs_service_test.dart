// Testa as preferências salvas e o uso delas na tela de login.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ja_deu_play/models/filme.dart';
import 'package:ja_deu_play/screens/login_screen.dart';
import 'package:ja_deu_play/services/prefs_service.dart';

void main() {
  test('sem nada salvo, carrega os valores padrão', () async {
    SharedPreferences.setMockInitialValues({});

    await PrefsService.carregar();

    expect(PrefsService.ultimoEmail, '');
    expect(PrefsService.temaEscuro, isFalse);
    expect(PrefsService.filtroStatus, 'todos');
    expect(PrefsService.ordenacao, 'titulo');
  });

  test('o que é salvo continua lá ao carregar de novo', () async {
    SharedPreferences.setMockInitialValues({});

    await PrefsService.salvarUltimoEmail('ana@exemplo.com');
    await PrefsService.salvarTemaEscuro(true);
    await PrefsService.salvarFiltroStatus('assistido');
    await PrefsService.salvarOrdenacao('nota');
    await PrefsService.carregar();

    expect(PrefsService.ultimoEmail, 'ana@exemplo.com');
    expect(PrefsService.temaEscuro, isTrue);
    expect(PrefsService.filtroStatus, 'assistido');
    expect(PrefsService.ordenacao, 'nota');
  });

  test('só guarda as quatro chaves, sem senha nem token', () async {
    SharedPreferences.setMockInitialValues({});

    await PrefsService.salvarUltimoEmail('ana@exemplo.com');
    await PrefsService.salvarTemaEscuro(true);
    await PrefsService.salvarFiltroStatus('todos');
    await PrefsService.salvarOrdenacao('ano');

    final preferencias = await SharedPreferences.getInstance();
    expect(
      preferencias.getKeys(),
      {'ultimo_email', 'tema_escuro', 'filtro_status', 'ordenacao'},
    );
  });

  test('as ordenações seguem título, ano e nota', () {
    const a = Filme(id: 'a', titulo: 'alien', ano: 1979, nota: 5);
    const b = Filme(id: 'b', titulo: 'Blade', ano: 1982, nota: 3);
    const c = Filme(id: 'c', titulo: 'Coco', ano: 2017, nota: 5);

    List<String> ordenar(int Function(Filme, Filme) comparar) {
      return ([c, a, b]..sort(comparar)).map((f) => f.id).toList();
    }

    expect(ordenar(Filme.compararPorTitulo), ['a', 'b', 'c']);
    expect(ordenar(Filme.compararPorAno), ['c', 'b', 'a']);
    expect(ordenar(Filme.compararPorNota), ['a', 'c', 'b']);
  });

  testWidgets('Login começa com o último e-mail usado',
      (WidgetTester tester) async {
    PrefsService.ultimoEmail = 'ana@exemplo.com';

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('ana@exemplo.com'), findsOneWidget);
    PrefsService.ultimoEmail = '';
  });

  testWidgets('Esqueci minha senha valida o e-mail e pode ser cancelado',
      (WidgetTester tester) async {
    PrefsService.ultimoEmail = '';
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.text('Esqueci minha senha'));
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enviar'));
    await tester.pump();
    expect(find.text('Informe o e-mail.'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Enviar'), findsNothing);
  });
}
