// Nota de 0 a 5 em estrelas. Só mostra a nota ou, quando recebe aoMudar,
// deixa o usuário escolher. Tocar na nota atual volta para zero.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EstrelasNota extends StatelessWidget {
  final int nota;
  final double tamanho;
  final ValueChanged<int>? aoMudar;

  const EstrelasNota({
    super.key,
    required this.nota,
    this.tamanho = 20,
    this.aoMudar,
  });

  Widget _estrela(BuildContext context, int posicao) {
    return Icon(
      posicao <= nota ? Icons.star : Icons.star_border,
      size: tamanho,
      color: posicao <= nota
          ? CoresApp.mostarda
          : Theme.of(context).colorScheme.outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mudar = aoMudar;

    return Semantics(
      label: 'Nota $nota de 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var posicao = 1; posicao <= 5; posicao++)
            if (mudar == null)
              _estrela(context, posicao)
            else
              IconButton(
                tooltip: 'Nota $posicao',
                onPressed: () => mudar(posicao == nota ? 0 : posicao),
                icon: _estrela(context, posicao),
              ),
        ],
      ),
    );
  }
}
