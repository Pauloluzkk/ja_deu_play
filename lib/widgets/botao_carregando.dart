// Botão principal que fica desabilitado e mostra um indicador de
// carregamento enquanto uma requisição está em andamento.

import 'package:flutter/material.dart';

class BotaoCarregando extends StatelessWidget {
  final String texto;
  final bool carregando;
  final VoidCallback aoPressionar;

  const BotaoCarregando({
    super.key,
    required this.texto,
    required this.carregando,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      // onPressed null é o que desabilita o botão no Flutter
      onPressed: carregando ? null : aoPressionar,
      child: carregando
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : Text(texto),
    );
  }
}
