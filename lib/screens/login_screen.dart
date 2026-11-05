// Tela de login: valida e-mail e senha, entra com a conta do usuário
// e permite pedir o e-mail de redefinição de senha.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/prefs_service.dart';
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
  // O campo já começa com o último e-mail usado neste aparelho
  final _campoEmail = TextEditingController(text: PrefsService.ultimoEmail);
  final _campoSenha = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _campoEmail.dispose();
    _campoSenha.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _entrar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      final email = _campoEmail.text.trim();
      await AuthService.entrar(email, _campoSenha.text);
      await PrefsService.salvarUltimoEmail(email);
      // Deu certo: o AuthGate percebe o login e troca para a lista.
    } catch (erro) {
      if (mounted) _mostrarMensagem(AuthService.traduzirErro(erro));
    } finally {
      // Após o login esta tela já pode ter saído da árvore de widgets
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Abre o diálogo e, se o usuário confirmar, envia o e-mail de redefinição.
  Future<void> _esqueciSenha() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoEsqueciSenha(
        emailInicial: _campoEmail.text.trim(),
      ),
    );
    if (email == null) return; // o usuário cancelou

    _campoEmail.text = email;
    setState(() => _carregando = true);
    try {
      await AuthService.enviarRedefinicaoSenha(email);
      // O Firebase não revela se o e-mail tem conta, por isso o "se houver"
      if (mounted) {
        _mostrarMensagem(
          'Se houver uma conta com este e-mail, enviaremos um link para '
          'redefinir a senha.',
        );
      }
    } catch (erro) {
      if (mounted) _mostrarMensagem(AuthService.traduzirErro(erro));
    } finally {
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
                    onPressed: _carregando ? null : _esqueciSenha,
                    child: const Text('Esqueci minha senha'),
                  ),
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

/// Pede o e-mail e devolve o valor digitado ao fechar. O envio fica na tela de
/// login, para o SnackBar do resultado não aparecer escurecido atrás do diálogo.
class _DialogoEsqueciSenha extends StatefulWidget {
  final String emailInicial;

  const _DialogoEsqueciSenha({required this.emailInicial});

  @override
  State<_DialogoEsqueciSenha> createState() => _DialogoEsqueciSenhaState();
}

class _DialogoEsqueciSenhaState extends State<_DialogoEsqueciSenha> {
  final _chaveFormulario = GlobalKey<FormState>();
  late final _campoEmail = TextEditingController(text: widget.emailInicial);

  @override
  void dispose() {
    _campoEmail.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_chaveFormulario.currentState!.validate()) return;
    Navigator.of(context).pop(_campoEmail.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Esqueci minha senha'),
      content: Form(
        key: _chaveFormulario,
        child: TextFormField(
          controller: _campoEmail,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'E-mail'),
          validator: AuthService.validarEmail,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _enviar, child: const Text('Enviar')),
      ],
    );
  }
}
