// Ponto de entrada do app: prepara Firebase, Hive e preferências
// antes de abrir a primeira tela.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/preferencias_service.dart';
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

  await PreferenciasService.carregar();

  runApp(const JaDeuPlayApp());
}

class JaDeuPlayApp extends StatelessWidget {
  const JaDeuPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Já deu play?',
      theme: AppTheme.claro,
      darkTheme: AppTheme.escuro,
      // Por enquanto fixo; na etapa 5 virá do SharedPreferences
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
