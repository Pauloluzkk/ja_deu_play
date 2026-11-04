// Modelo de um item da watchlist (filme ou série) e sua conversão
// de e para o Map guardado no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Filme {
  final String id;
  final String userId;
  final String titulo;
  final int ano;
  final String tipo; // 'filme' ou 'serie'
  final String status; // 'quero_ver' ou 'assistido'
  final int nota; // de 0 a 5
  final String comentario;
  final String posterUrl;
  final String imdbId;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Filme({
    required this.id,
    this.userId = '',
    required this.titulo,
    required this.ano,
    this.tipo = 'filme',
    this.status = 'quero_ver',
    this.nota = 0,
    this.comentario = '',
    this.posterUrl = '',
    this.imdbId = '',
    this.criadoEm,
    this.atualizadoEm,
  });

  /// O id não entra no Map porque ele é o próprio nome do documento.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'titulo': titulo,
      'ano': ano,
      'tipo': tipo,
      'status': status,
      'nota': nota,
      'comentario': comentario,
      'posterUrl': posterUrl,
      'imdbId': imdbId,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
    };
  }

  factory Filme.fromMap(String id, Map<String, dynamic> mapa) {
    return Filme(
      id: id,
      userId: mapa['userId'] ?? '',
      titulo: mapa['titulo'] ?? '',
      ano: (mapa['ano'] as num?)?.toInt() ?? 0,
      tipo: mapa['tipo'] ?? 'filme',
      status: mapa['status'] ?? 'quero_ver',
      nota: ((mapa['nota'] as num?)?.toInt() ?? 0).clamp(0, 5),
      comentario: mapa['comentario'] ?? '',
      posterUrl: mapa['posterUrl'] ?? '',
      imdbId: mapa['imdbId'] ?? '',
      criadoEm: _lerData(mapa['criadoEm']),
      atualizadoEm: _lerData(mapa['atualizadoEm']),
    );
  }

  /// O Firestore devolve as datas como Timestamp, não como DateTime.
  static DateTime? _lerData(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }

  /// Usado para ordenar a lista: o título criado por último vem primeiro.
  static int compararMaisNovoPrimeiro(Filme a, Filme b) {
    final dataA = a.criadoEm ?? DateTime(0);
    final dataB = b.criadoEm ?? DateTime(0);
    return dataB.compareTo(dataA);
  }

  String get tipoTexto => tipo == 'serie' ? 'Série' : 'Filme';

  String get statusTexto => status == 'assistido' ? 'Assistido' : 'Quero ver';
}
