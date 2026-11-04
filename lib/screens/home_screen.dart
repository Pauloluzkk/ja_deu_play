// Tela inicial provisória do app: por enquanto mostra só a logo.

import 'package:flutter/material.dart';

import '../widgets/logo_app.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LogoApp(),
      ),
    );
  }
}
