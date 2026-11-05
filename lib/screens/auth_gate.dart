// Decide a primeira tela: lista para quem está logado, login para os demais.
// Troca de tela sozinha quando o usuário entra ou sai.

// Só o tipo User; todo acesso ao Firebase passa pelo AuthService.
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/logo_app.dart';
import 'lista_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  final VoidCallback aoAlternarTema;

  const AuthGate({super.key, required this.aoAlternarTema});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Criado uma única vez: trocar o tema reconstrói esta tela, e um stream novo
  // voltaria para o carregamento e faria a lista perder o estado.
  final Stream<User?> _usuario = AuthService.usuarioMudou;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _usuario,
      builder: (context, snapshot) {
        // O Firebase ainda está verificando se existe uma sessão salva
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MascoteApp(),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        if (snapshot.data == null) return const LoginScreen();
        return ListaScreen(aoAlternarTema: widget.aoAlternarTema);
      },
    );
  }
}
