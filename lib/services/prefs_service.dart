// Preferências do usuário guardadas no aparelho com SharedPreferences:
// último e-mail, tema escuro, filtro de status e ordenação da lista.
//
// NUNCA guardar senha ou token aqui: o SharedPreferences é um arquivo de texto
// sem criptografia. Quem cuida da sessão com segurança é o Firebase Auth.

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _chaveUltimoEmail = 'ultimo_email';
  static const _chaveTemaEscuro = 'tema_escuro';
  static const _chaveFiltroStatus = 'filtro_status';
  static const _chaveOrdenacao = 'ordenacao';

  // Valores carregados no main, para as telas lerem sem esperar um Future
  static String ultimoEmail = '';
  static bool temaEscuro = false;
  static String filtroStatus = 'todos'; // todos, quero_ver ou assistido
  static String ordenacao = 'titulo'; // titulo, ano ou nota

  /// Lê as preferências salvas. É chamado no main, antes do runApp.
  static Future<void> carregar() async {
    final preferencias = await SharedPreferences.getInstance();

    ultimoEmail = preferencias.getString(_chaveUltimoEmail) ?? '';
    temaEscuro = preferencias.getBool(_chaveTemaEscuro) ?? false;
    filtroStatus = preferencias.getString(_chaveFiltroStatus) ?? 'todos';
    ordenacao = preferencias.getString(_chaveOrdenacao) ?? 'titulo';
  }

  static Future<void> salvarUltimoEmail(String email) async {
    ultimoEmail = email;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_chaveUltimoEmail, email);
  }

  static Future<void> salvarTemaEscuro(bool escuro) async {
    temaEscuro = escuro;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool(_chaveTemaEscuro, escuro);
  }

  static Future<void> salvarFiltroStatus(String filtro) async {
    filtroStatus = filtro;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_chaveFiltroStatus, filtro);
  }

  static Future<void> salvarOrdenacao(String novaOrdenacao) async {
    ordenacao = novaOrdenacao;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_chaveOrdenacao, novaOrdenacao);
  }
}
