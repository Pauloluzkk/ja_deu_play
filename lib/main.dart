// Ponto de entrada do app: prepara Firebase, Hive e preferências
// antes de abrir a primeira tela, e guarda o tema claro ou escuro.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';

void main() async {
  // Necessário para usar plugins antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // O cache offline do app é feito pelo Hive, não pelo Firestore
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);

  await Hive.initFlutter();
  await Hive.openBox('filmes_cache');

  await PrefsService.carregar();
  await AppTheme.carregarFontes();

  runApp(const JaDeuPlayApp());
}

class JaDeuPlayApp extends StatefulWidget {
  const JaDeuPlayApp({super.key});

  @override
  State<JaDeuPlayApp> createState() => _JaDeuPlayAppState();
}

class _JaDeuPlayAppState extends State<JaDeuPlayApp> {
  bool _temaEscuro = PrefsService.temaEscuro;

  /// O setState aqui reconstrói o MaterialApp, e o tema muda na hora.
  /// A função desce até a lista pelo AuthGate.
  void _alternarTema() {
    setState(() => _temaEscuro = !_temaEscuro);
    PrefsService.salvarTemaEscuro(_temaEscuro);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Já deu play?',
      theme: AppTheme.claro,
      darkTheme: AppTheme.escuro,
      themeMode: _temaEscuro ? ThemeMode.dark : ThemeMode.light,
      home: AuthGate(aoAlternarTema: _alternarTema),
    );
  }
}
