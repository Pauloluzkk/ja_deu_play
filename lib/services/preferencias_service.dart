// Carrega as preferências do usuário guardadas no SharedPreferences.
// Nunca guardar senha ou token aqui.

import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  static bool temaEscuro = false;
  static String? ultimoEmail;
  static String? filtroStatus;
  static String? ordenacao;

  /// Lê as preferências salvas. É chamado no main, antes do runApp.
  static Future<void> carregar() async {
    final preferencias = await SharedPreferences.getInstance();

    temaEscuro = preferencias.getBool('tema_escuro') ?? false;
    ultimoEmail = preferencias.getString('ultimo_email');
    filtroStatus = preferencias.getString('filtro_status');
    ordenacao = preferencias.getString('ordenacao');
  }
}
