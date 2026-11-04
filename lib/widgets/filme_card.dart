// Cartão de um item da lista: título, ano, tipo, status, nota em estrelas
// e o botão de excluir.

import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../theme/app_theme.dart';
import 'estrelas_nota.dart';

class FilmeCard extends StatelessWidget {
  final Filme filme;
  final bool excluindo;
  final VoidCallback aoTocar;
  final VoidCallback aoExcluir;

  const FilmeCard({
    super.key,
    required this.filme,
    required this.excluindo,
    required this.aoTocar,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(filme.titulo, style: textos.titleMedium),
                    const SizedBox(height: 2),
                    Text('${filme.ano} • ${filme.tipoTexto}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _SeloStatus(filme: filme),
                        EstrelasNota(nota: filme.nota),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: excluindo ? null : aoExcluir,
                icon: excluindo
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeloStatus extends StatelessWidget {
  final Filme filme;

  const _SeloStatus({required this.filme});

  @override
  Widget build(BuildContext context) {
    final assistido = filme.status == 'assistido';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: CoresApp.corDoStatus(filme.status),
        borderRadius: BorderRadius.circular(AppTheme.raio),
      ),
      child: Text(
        filme.statusTexto,
        style: TextStyle(
          color: assistido ? Colors.white : CoresApp.marrom,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
