// Tela da lista, ainda provisória: mostra o e-mail do usuário logado
// e o botão de sair. Só é aberta pelo AuthGate, com alguém logado.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/botao_carregando.dart';
import '../widgets/logo_app.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _carregando = false;

  Future<void> _sair() async {
    setState(() => _carregando = true);
    try {
      await AuthService.sair();
      // Deu certo: o AuthGate percebe o logout e volta para o login.
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Não foi possível sair. Tente novamente.'),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoApp(),
                const SizedBox(height: 32),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                BotaoCarregando(
                  texto: 'Sair',
                  carregando: _carregando,
                  aoPressionar: _sair,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
