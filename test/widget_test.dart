// Testa os formulários, o cartão da lista, o modelo Filme e a tradução
// dos erros. Nenhum teste aqui acessa o Firebase de verdade.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ja_deu_play/models/filme.dart';
import 'package:ja_deu_play/screens/cadastro_screen.dart';
import 'package:ja_deu_play/screens/formulario_screen.dart';
import 'package:ja_deu_play/screens/login_screen.dart';
import 'package:ja_deu_play/services/auth_service.dart';
import 'package:ja_deu_play/services/firestore_service.dart';
import 'package:ja_deu_play/widgets/botao_carregando.dart';
import 'package:ja_deu_play/widgets/filme_card.dart';

void main() {
  testWidgets('Login não envia com campos inválidos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@exemplo');
    await tester.enterText(find.byType(TextFormField).at(1), '12345');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(
      find.text('A senha precisa ter 6 ou mais caracteres.'),
      findsOneWidget,
    );
  });

  testWidgets('Cadastro exige que a confirmação seja igual à senha',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@exemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '654321');
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('As senhas não são iguais.'), findsOneWidget);
  });

  testWidgets('Botão fica desabilitado enquanto carrega',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BotaoCarregando(
            texto: 'Entrar',
            carregando: true,
            aoPressionar: () {},
          ),
        ),
      ),
    );

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
  });

  testWidgets('Formulário exige título e ano com 4 dígitos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FormularioScreen()));

    await tester.enterText(find.byType(TextFormField).at(1), '199');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o título.'), findsOneWidget);
    expect(find.text('Informe o ano com 4 dígitos.'), findsOneWidget);
  });

  testWidgets('Formulário de edição vem preenchido',
      (WidgetTester tester) async {
    const filme = Filme(id: '1', titulo: 'Duna', ano: 2021, comentario: 'Ótimo');
    await tester.pumpWidget(const MaterialApp(home: FormularioScreen(filme: filme)));

    expect(find.text('Editar título'), findsOneWidget);
    expect(find.text('Duna'), findsOneWidget);
    expect(find.text('2021'), findsOneWidget);
    expect(find.text('Ótimo'), findsOneWidget);
  });

  testWidgets('Cartão mostra os dados e a nota em estrelas',
      (WidgetTester tester) async {
    var excluiu = false;
    var tocou = false;
    const filme = Filme(
      id: '1',
      titulo: 'Dark',
      ano: 2017,
      tipo: 'serie',
      status: 'assistido',
      nota: 3,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilmeCard(
            filme: filme,
            excluindo: false,
            aoTocar: () => tocou = true,
            aoExcluir: () => excluiu = true,
          ),
        ),
      ),
    );

    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('2017 • Série'), findsOneWidget);
    expect(find.text('Assistido'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(excluiu, isTrue);
    expect(tocou, isFalse);

    await tester.tap(find.text('Dark'));
    expect(tocou, isTrue);
  });

  test('Filme converte de e para Map', () {
    final data = DateTime(2026, 1, 2);
    final filme = Filme.fromMap('abc', {
      'userId': 'u1',
      'titulo': 'Duna',
      'ano': 2021,
      'tipo': 'filme',
      'status': 'quero_ver',
      'nota': 4,
      'criadoEm': Timestamp.fromDate(data),
    });

    expect(filme.id, 'abc');
    expect(filme.userId, 'u1');
    expect(filme.nota, 4);
    expect(filme.criadoEm, data);
    expect(filme.comentario, '');
    expect(filme.toMap().containsKey('id'), isFalse);
    expect(filme.toMap()['titulo'], 'Duna');
  });

  test('Erros do Firebase Auth viram mensagens em português', () {
    final mensagens = {
      'wrong-password': 'Senha incorreta.',
      'user-not-found': 'Usuário não encontrado.',
      'invalid-credential': 'E-mail ou senha incorretos.',
      'email-already-in-use': 'Este e-mail já está em uso.',
      'invalid-email': 'E-mail inválido.',
      'weak-password': 'Senha fraca. Use pelo menos 6 caracteres.',
      'network-request-failed':
          'Sem conexão. Verifique sua internet e tente novamente.',
    };

    mensagens.forEach((codigo, mensagem) {
      final erro = FirebaseAuthException(code: codigo);
      expect(AuthService.traduzirErro(erro), mensagem);
    });
  });

  test('Erros do Firestore viram mensagens em português', () {
    expect(
      FirestoreService.traduzirErro(TimeoutException('')),
      'Sem internet. A alteração será enviada quando a conexão voltar, '
      'se o app continuar aberto.',
    );
    expect(FirestoreService.ehErroDeConexao(TimeoutException('')), isTrue);
    expect(
      FirestoreService.ehErroDeConexao(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      ),
      isTrue,
    );
    expect(
      FirestoreService.ehErroDeConexao(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      isFalse,
    );
    expect(
      FirestoreService.traduzirErro(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      'Você não tem permissão para acessar estes dados.',
    );
  });
}
