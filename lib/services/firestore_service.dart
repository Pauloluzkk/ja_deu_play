// CRUD da coleção watchlist no Firestore. Todo documento leva o userId
// do usuário logado e toda consulta filtra por ele.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/filme.dart';
import 'auth_service.dart';

class FirestoreService {
  // Sem internet, o Firestore não dá erro: a escrita fica esperando a conexão
  // voltar. O tempo limite evita um carregamento que nunca termina.
  static const _tempoLimite = Duration(seconds: 10);

  static CollectionReference<Map<String, dynamic>> get _colecao =>
      FirebaseFirestore.instance.collection('watchlist');

  static String get _idUsuario {
    final id = AuthService.idUsuario;
    if (id == null) throw StateError('Nenhum usuário logado.');
    return id;
  }

  /// Gera o id de um novo documento antes de salvar. Se o usuário tentar
  /// salvar de novo após uma falha, o mesmo documento é usado e não duplica.
  static String novoId() => _colecao.doc().id;

  /// Lista os títulos do usuário logado, do mais novo para o mais antigo.
  /// Ordenar aqui no app dispensa criar um índice composto no Firestore.
  static Stream<List<Filme>> listar() {
    return _colecao
        .where('userId', isEqualTo: _idUsuario)
        // Avisa também quando a resposta do servidor chega sem mudar os dados
        .snapshots(includeMetadataChanges: true)
        .map((consulta) {
      // Dados da memória do Firestore não foram confirmados pelo servidor:
      // o app está sem conexão. Só dados confirmados podem ir para o Hive.
      if (consulta.metadata.isFromCache) {
        throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
      }

      final filmes = consulta.docs
          .map((documento) => Filme.fromMap(documento.id, documento.data()))
          .toList();
      filmes.sort(Filme.compararMaisNovoPrimeiro);
      return filmes;
    });
  }

  /// Retorna o título como foi salvo, já com userId e datas preenchidos.
  static Future<Filme> adicionar(Filme filme) async {
    final agora = DateTime.now();
    final dados = filme.toMap();
    dados['userId'] = _idUsuario;
    dados['criadoEm'] = agora;
    dados['atualizadoEm'] = agora;

    await _colecao.doc(filme.id).set(dados).timeout(_tempoLimite);
    return Filme.fromMap(filme.id, dados);
  }

  /// Retorna o título como foi salvo, já com userId e datas preenchidos.
  static Future<Filme> atualizar(Filme filme) async {
    final dados = filme.toMap();
    dados['userId'] = _idUsuario;
    dados['atualizadoEm'] = DateTime.now();

    await _colecao.doc(filme.id).update(dados).timeout(_tempoLimite);
    return Filme.fromMap(filme.id, dados);
  }

  static Future<void> excluir(String id) async {
    await _colecao.doc(id).delete().timeout(_tempoLimite);
  }

  /// Diz se o erro foi por falta de conexão, e não por outro motivo.
  static bool ehErroDeConexao(Object? erro) {
    if (erro is TimeoutException) return true;
    return erro is FirebaseException && erro.code == 'unavailable';
  }

  /// Transforma um erro do Firestore em mensagem para o usuário.
  static String traduzirErro(Object? erro) {
    // Após o tempo limite, o Firestore continua com a escrita na fila
    if (erro is TimeoutException) {
      return 'Sem internet. A alteração será enviada quando a conexão voltar, '
          'se o app continuar aberto.';
    }
    if (erro is FirebaseException) {
      switch (erro.code) {
        case 'permission-denied':
          return 'Você não tem permissão para acessar estes dados.';
        case 'unavailable':
          return 'Sem conexão. Verifique sua internet.';
        case 'not-found':
          return 'Este título não existe mais.';
      }
    }
    return 'Algo deu errado. Tente novamente.';
  }
}
