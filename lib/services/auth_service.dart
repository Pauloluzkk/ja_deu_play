// Autenticação com Firebase (e-mail e senha): cadastro, login, logout,
// aviso de mudança de usuário, validação dos campos e tradução dos erros.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Avisa sempre que alguém entra ou sai. O valor é null quando não há
  /// usuário logado.
  static Stream<User?> get usuarioMudou => _auth.authStateChanges();

  /// Cria a conta. O Firebase já deixa o novo usuário logado.
  static Future<void> cadastrar(String email, String senha) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  static Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  /// Apaga a cópia local da lista e encerra a sessão. Assim o próximo
  /// usuário do aparelho não vê os filmes de quem saiu.
  static Future<void> sair() async {
    await Hive.box('filmes_cache').clear();
    await _auth.signOut();
  }

  /// Transforma um erro do login ou do cadastro em mensagem para o usuário.
  static String traduzirErro(Object erro) {
    if (erro is! FirebaseAuthException) {
      return 'Algo deu errado. Tente novamente.';
    }

    switch (erro.code) {
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      // Projetos novos do Firebase usam este código nos dois casos acima,
      // para não revelar quais e-mails têm conta.
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique sua internet e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      default:
        return 'Não foi possível concluir. Tente novamente.';
    }
  }

  /// Validação do campo de e-mail. Retorna null quando está tudo certo.
  static String? validarEmail(String? email) {
    final texto = email?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail.';

    final formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formatoEmail.hasMatch(texto)) return 'Informe um e-mail válido.';
    return null;
  }

  /// Validação do campo de senha. Retorna null quando está tudo certo.
  static String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) return 'Informe a senha.';
    if (senha.length < 6) return 'A senha precisa ter 6 ou mais caracteres.';
    return null;
  }
}
