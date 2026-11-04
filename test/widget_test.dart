// Testa a tela provisória da lista, os formulários de login e cadastro
// e a tradução dos erros. Nenhum teste aqui acessa o Firebase de verdade.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ja_deu_play/screens/cadastro_screen.dart';
import 'package:ja_deu_play/screens/home_screen.dart';
import 'package:ja_deu_play/screens/login_screen.dart';
import 'package:ja_deu_play/services/auth_service.dart';
import 'package:ja_deu_play/widgets/botao_carregando.dart';
import 'package:ja_deu_play/widgets/logo_app.dart';

void main() {
  testWidgets('Tela da lista mostra a logo, o e-mail e o botão de sair',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(email: 'ana@exemplo.com')),
    );

    expect(find.byType(LogoApp), findsOneWidget);
    expect(find.text('ana@exemplo.com'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
  });

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

  test('Erros do Firebase viram mensagens em português', () {
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
}
