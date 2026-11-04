// Logo e mascote do "Já deu play?".
// No tema escuro a logo fica dentro de um cartão creme,
// porque as letras marrons não aparecem em fundo escuro.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LogoApp extends StatelessWidget {
  final double largura;

  const LogoApp({super.key, this.largura = 280});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final imagem = Image.asset(
      'assets/images/logo_transparente.png',
      width: largura,
      semanticLabel: 'Já deu play?',
    );
    if (!escuro) return imagem;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CoresApp.creme,
        borderRadius: BorderRadius.circular(AppTheme.raio),
      ),
      child: imagem,
    );
  }
}

/// Gato de óculos, para telas vazias e de carregamento.
class MascoteApp extends StatelessWidget {
  final double tamanho;

  const MascoteApp({super.key, this.tamanho = 160});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mascote.png',
      width: tamanho,
      semanticLabel: 'Mascote do Já deu play?',
    );
  }
}
