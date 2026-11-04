// Testa o CRUD do cache local com uma caixa do Hive em pasta temporária.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:ja_deu_play/models/filme.dart';
import 'package:ja_deu_play/services/cache_service.dart';

void main() {
  late Directory pasta;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('cache_teste');
    Hive.init(pasta.path);
    await Hive.openBox('filmes_cache');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await pasta.delete(recursive: true);
  });

  Filme criarFilme(String id, {String titulo = 'Duna', DateTime? criadoEm}) {
    return Filme(
      id: id,
      userId: 'u1',
      titulo: titulo,
      ano: 2021,
      nota: 4,
      criadoEm: criadoEm,
    );
  }

  test('salvar e listar mantêm todos os campos, inclusive as datas', () async {
    final data = DateTime(2026, 1, 2, 3, 4);
    await CacheService.salvar(criarFilme('a', criadoEm: data));

    final lista = CacheService.listar();
    expect(lista, hasLength(1));
    expect(lista.first.id, 'a');
    expect(lista.first.userId, 'u1');
    expect(lista.first.titulo, 'Duna');
    expect(lista.first.ano, 2021);
    expect(lista.first.nota, 4);
    expect(lista.first.criadoEm, data);
  });

  test('salvar com o mesmo id substitui o item', () async {
    await CacheService.salvar(criarFilme('a'));
    await CacheService.salvar(criarFilme('a', titulo: 'Dark'));

    final lista = CacheService.listar();
    expect(lista, hasLength(1));
    expect(lista.first.titulo, 'Dark');
  });

  test('salvarTodos substitui a cópia e tira o que não veio', () async {
    await CacheService.salvar(criarFilme('antigo'));

    await CacheService.salvarTodos([criarFilme('a'), criarFilme('b')]);

    final ids = CacheService.listar().map((filme) => filme.id);
    expect(ids, unorderedEquals(['a', 'b']));
  });

  test('salvarTodos com lista vazia esvazia o cache', () async {
    await CacheService.salvar(criarFilme('a'));

    await CacheService.salvarTodos([]);

    expect(CacheService.listar(), isEmpty);
  });

  test('listar ordena do mais novo para o mais antigo', () async {
    await CacheService.salvarTodos([
      criarFilme('velho', criadoEm: DateTime(2020)),
      criarFilme('novo', criadoEm: DateTime(2026)),
    ]);

    expect(CacheService.listar().first.id, 'novo');
  });

  test('excluir apaga só o item escolhido', () async {
    await CacheService.salvarTodos([criarFilme('a'), criarFilme('b')]);

    await CacheService.excluir('a');

    expect(CacheService.listar().map((filme) => filme.id), ['b']);
  });

  test('limparTudo esvazia a caixa', () async {
    await CacheService.salvarTodos([criarFilme('a'), criarFilme('b')]);

    await CacheService.limparTudo();

    expect(CacheService.listar(), isEmpty);
  });
}
