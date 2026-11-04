// Tela de login: valida e-mail e senha e entra com a conta do usuário.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/botao_carregando.dart';
import '../widgets/logo_app.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _campoEmail = TextEditingController();
  final _campoSenha = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _campoEmail.dispose();
    _campoSenha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await AuthService.entrar(_campoEmail.text.trim(), _campoSenha.text);
      // Deu certo: o AuthGate percebe o login e troca para a lista.
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AuthService.traduzirErro(erro))));
      }
    } finally {
      // Após o login esta tela já pode ter saído da árvore de widgets
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirCadastro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Rolagem para o teclado não cobrir os campos
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoApp(),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _campoEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: AuthService.validarEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _campoSenha,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: AuthService.validarSenha,
                  ),
                  const SizedBox(height: 24),
                  BotaoCarregando(
                    texto: 'Entrar',
                    carregando: _carregando,
                    aoPressionar: _entrar,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _carregando ? null : _abrirCadastro,
                    child: const Text('Ainda não tem conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
