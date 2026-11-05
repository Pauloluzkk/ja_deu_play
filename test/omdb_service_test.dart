// Testa a leitura das respostas da OMDb, a tradução dos erros e a tela de
// busca, com textos iguais aos da API. Nenhum teste acessa a internet.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ja_deu_play/models/filme.dart';
import 'package:ja_deu_play/screens/busca_omdb_screen.dart';
import 'package:ja_deu_play/screens/formulario_screen.dart';
import 'package:ja_deu_play/services/omdb_service.dart';

void main() {
  test('Lê filmes e séries e ignora jogos', () {
    final filmes = OmdbService.lerResposta('''
      {"Response":"True","Search":[
        {"Title":"Duna","Year":"2021","imdbID":"tt1","Type":"movie","Poster":"https://img/1.jpg"},
        {"Title":"Dark","Year":"2017–2020","imdbID":"tt2","Type":"series","Poster":"N/A"},
        {"Title":"Dark Souls","Year":"2016","imdbID":"tt3","Type":"game","Poster":"N/A"}
      ]}
    ''');

    expect(filmes, hasLength(2));
    expect(filmes[0].titulo, 'Duna');
    expect(filmes[0].ano, 2021);
    expect(filmes[0].tipo, 'filme');
    expect(filmes[0].posterUrl, 'https://img/1.jpg');
    expect(filmes[0].imdbId, 'tt1');
    expect(filmes[1].ano, 2017);
    expect(filmes[1].tipo, 'serie');
    expect(filmes[1].posterUrl, '');
  });

  test('"Movie not found" vira lista vazia', () {
    final filmes = OmdbService.lerResposta(
      '{"Response":"False","Error":"Movie not found!"}',
    );

    expect(filmes, isEmpty);
  });

  test('Erros da OMDb viram mensagens em português', () {
    String mensagemDe(String erroDaApi) {
      try {
        OmdbService.lerResposta('{"Response":"False","Error":"$erroDaApi"}');
        return '';
      } catch (erro) {
        return OmdbService.traduzirErro(erro);
      }
    }

    expect(
      mensagemDe('Too many results.'),
      'Muitos resultados. Digite mais letras.',
    );
    expect(mensagemDe('Invalid API key!'), 'A chave da OMDb é inválida.');
    expect(
      mensagemDe('Request limit reached!'),
      'A OMDb não conseguiu fazer a busca.',
    );
  });

  test('Falhas de rede viram mensagem de sem conexão', () {
    const semConexao = 'Sem conexão. Verifique sua internet e tente novamente.';

    expect(OmdbService.traduzirErro(TimeoutException('')), semConexao);
    expect(OmdbService.traduzirErro(const SocketException('')), semConexao);
  });

  testWidgets('Busca exige um termo', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuscaOmdbScreen()));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.text('Digite o nome de um filme ou série.'), findsOneWidget);
  });

  testWidgets('Formulário de um resultado é um título novo já preenchido',
      (WidgetTester tester) async {
    const resultado = Filme(id: '', titulo: 'Dark', ano: 2017, tipo: 'serie');

    await tester.pumpWidget(
      const MaterialApp(home: FormularioScreen(preenchimento: resultado)),
    );

    expect(find.text('Novo título'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('2017'), findsOneWidget);
    final serie = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Série'),
    );
    expect(serie.selected, isTrue);
  });

  testWidgets('Resultado sem ano deixa o campo vazio para preencher',
      (WidgetTester tester) async {
    const resultado = Filme(id: '', titulo: 'Sem ano', ano: 0);

    await tester.pumpWidget(
      const MaterialApp(home: FormularioScreen(preenchimento: resultado)),
    );

    final campos = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(campos.elementAt(1).controller!.text, '');
  });
}
