// Tela de cadastro: valida os campos, confirma a senha e cria a conta.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../widgets/botao_carregando.dart';
import '../widgets/logo_app.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _campoEmail = TextEditingController();
  final _campoSenha = TextEditingController();
  final _campoConfirmacao = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _campoEmail.dispose();
    _campoSenha.dispose();
    _campoConfirmacao.dispose();
    super.dispose();
  }

  String? _validarConfirmacao(String? confirmacao) {
    if (confirmacao == null || confirmacao.isEmpty) return 'Confirme a senha.';
    if (confirmacao != _campoSenha.text) return 'As senhas não são iguais.';
    return null;
  }

  Future<void> _cadastrar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      final email = _campoEmail.text.trim();
      await AuthService.cadastrar(email, _campoSenha.text);
      await PrefsService.salvarUltimoEmail(email);
      // O AuthGate já trocou para a lista por baixo desta tela, que foi
      // aberta com push. Sem este pop, o cadastro ficaria na frente da lista.
      if (mounted) Navigator.of(context).pop();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(AuthService.traduzirErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _chaveFormulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoApp(largura: 180),
                  const SizedBox(height: 24),
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
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: AuthService.validarSenha,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _campoConfirmacao,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration:
                        const InputDecoration(labelText: 'Confirmar senha'),
                    validator: _validarConfirmacao,
                  ),
                  const SizedBox(height: 24),
                  BotaoCarregando(
                    texto: 'Cadastrar',
                    carregando: _carregando,
                    aoPressionar: _cadastrar,
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
