// Busca filmes e séries na API OMDb e transforma a resposta em objetos Filme,
// prontos para preencher o formulário.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/filme.dart';

/// Erro informado pela própria OMDb, já com a mensagem em português.
class ErroOmdb implements Exception {
  final String mensagem;

  const ErroOmdb(this.mensagem);
}

class OmdbService {
  static const _tempoLimite = Duration(seconds: 10);

  /// Busca pelo termo e devolve os resultados. A lista vazia significa que a
  /// busca funcionou, mas nada foi encontrado.
  static Future<List<Filme>> buscar(String termo) async {
    // O Uri.https cuida de espaços e acentos do termo digitado
    final endereco = Uri.https('www.omdbapi.com', '/', {
      's': termo,
      'apikey': chaveOmdb,
    });

    final resposta = await http.get(endereco).timeout(_tempoLimite);
    return lerResposta(resposta.body);
  }

  /// Lê o JSON da OMDb, que traz os resultados na lista "Search" ou
  /// o motivo da falha em "Error" (mesmo em erros como chave inválida).
  static List<Filme> lerResposta(String corpo) {
    final dados = jsonDecode(corpo) as Map<String, dynamic>;

    if (dados['Response'] != 'True') {
      switch (dados['Error']) {
        case 'Movie not found!':
          return [];
        case 'Too many results.':
          throw const ErroOmdb('Muitos resultados. Digite mais letras.');
        case 'Invalid API key!':
          throw const ErroOmdb('A chave da OMDb é inválida.');
        default:
          throw const ErroOmdb('A OMDb não conseguiu fazer a busca.');
      }
    }

    final resultados = dados['Search'] as List<dynamic>;
    return resultados
        .map((item) => item as Map<String, dynamic>)
        // A OMDb também devolve jogos, que não fazem parte da watchlist
        .where((item) => item['Type'] == 'movie' || item['Type'] == 'series')
        .map(_converter)
        .toList();
  }

  static Filme _converter(Map<String, dynamic> item) {
    // Séries podem vir com o ano como "2017–2020": usa os 4 primeiros dígitos
    final ano = RegExp(r'\d{4}').stringMatch(item['Year'] ?? '');
    final poster = item['Poster'] ?? '';

    return Filme(
      id: '',
      titulo: item['Title'] ?? '',
      ano: int.tryParse(ano ?? '') ?? 0,
      tipo: item['Type'] == 'series' ? 'serie' : 'filme',
      // Sem pôster, a OMDb manda o texto "N/A"
      posterUrl: poster == 'N/A' ? '' : poster,
      imdbId: item['imdbID'] ?? '',
    );
  }

  /// Transforma um erro da busca em mensagem para o usuário.
  static String traduzirErro(Object erro) {
    if (erro is ErroOmdb) return erro.mensagem;
    if (erro is TimeoutException ||
        erro is SocketException ||
        erro is http.ClientException) {
      return 'Sem conexão. Verifique sua internet e tente novamente.';
    }
    return 'Não foi possível fazer a busca. Tente novamente.';
  }
}
