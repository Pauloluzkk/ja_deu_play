// Cache local com Hive: cópia da lista para usar o app sem internet.
// Caixa filmes_cache: a chave é o id do documento e o valor é um Map.

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/filme.dart';

class CacheService {
  // A caixa é aberta uma única vez no main, antes do runApp.
  static Box get _caixa => Hive.box('filmes_cache');

  /// CREATE e UPDATE: put cria a chave se ela não existe e substitui o valor
  /// se ela já existe. Por isso a mesma operação serve para os dois casos.
  static Future<void> salvar(Filme filme) async {
    await _caixa.put(filme.id, filme.toMap());
  }

  /// CREATE e UPDATE em lote: troca a cópia local pela lista do servidor.
  /// O clear vem antes para sumir o que foi excluído em outro aparelho.
  static Future<void> salvarTodos(List<Filme> filmes) async {
    await _caixa.clear();
    await _caixa.putAll({for (final filme in filmes) filme.id: filme.toMap()});
  }

  /// READ: lê todos os valores da caixa, do mais novo para o mais antigo.
  /// O Hive não guarda o tipo do Map, por isso a conversão para String.
  static List<Filme> listar() {
    final filmes = _caixa.toMap().entries.map((item) {
      final mapa = Map<String, dynamic>.from(item.value as Map);
      return Filme.fromMap(item.key as String, mapa);
    }).toList();
    filmes.sort(Filme.compararMaisNovoPrimeiro);
    return filmes;
  }

  /// DELETE: apaga um item pela chave, que é o id do documento.
  static Future<void> excluir(String id) async {
    await _caixa.delete(id);
  }

  /// DELETE de tudo: esvazia a caixa. É chamado no logout.
  static Future<void> limparTudo() async {
    await _caixa.clear();
  }
}
