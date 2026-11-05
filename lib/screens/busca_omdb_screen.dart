// Tela de busca na OMDb: mostra os resultados com pôster, título e ano.
// Tocar em um resultado abre o formulário já preenchido.

import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/omdb_service.dart';
import '../widgets/logo_app.dart';
import 'formulario_screen.dart';

class BuscaOmdbScreen extends StatefulWidget {
  const BuscaOmdbScreen({super.key});

  @override
  State<BuscaOmdbScreen> createState() => _BuscaOmdbScreenState();
}

class _BuscaOmdbScreenState extends State<BuscaOmdbScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _campoBusca = TextEditingController();
  bool _carregando = false;
  String? _erro;
  List<Filme>? _resultados; // null significa que ainda não houve busca

  @override
  void dispose() {
    _campoBusca.dispose();
    super.dispose();
  }

  String? _validarBusca(String? termo) {
    if (termo == null || termo.trim().isEmpty) {
      return 'Digite o nome de um filme ou série.';
    }
    return null;
  }

  Future<void> _buscar() async {
    if (_carregando || !_chaveFormulario.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // fecha o teclado
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await OmdbService.buscar(_campoBusca.text.trim());
      if (mounted) setState(() => _resultados = resultados);
    } catch (erro) {
      if (mounted) {
        final mensagem = OmdbService.traduzirErro(erro);
        setState(() => _erro = mensagem);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(mensagem)));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirFormulario(Filme filme) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormularioScreen(preenchimento: filme),
      ),
    );
  }

  Widget _montarConteudo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    final erro = _erro;
    if (erro != null) return _Aviso(texto: erro);

    final resultados = _resultados;
    if (resultados == null) {
      return const _Aviso(texto: 'Busque um filme ou série pelo nome.');
    }
    if (resultados.isEmpty) {
      return const _Aviso(texto: 'Nenhum resultado encontrado.');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: resultados.length,
      itemBuilder: (context, indice) {
        final filme = resultados[indice];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _abrirFormulario(filme),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _Poster(endereco: filme.posterUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filme.titulo,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text('${filme.ano} • ${filme.tipoTexto}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar na OMDb')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Form(
              key: _chaveFormulario,
              child: TextFormField(
                controller: _campoBusca,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                onFieldSubmitted: (_) => _buscar(),
                validator: _validarBusca,
                decoration: InputDecoration(
                  labelText: 'Nome do filme ou série',
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
                    onPressed: _carregando ? null : _buscar,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _montarConteudo()),
        ],
      ),
    );
  }
}

/// Pôster do resultado. Sem imagem ou sem internet, mostra um ícone.
class _Poster extends StatelessWidget {
  final String endereco;

  const _Poster({required this.endereco});

  @override
  Widget build(BuildContext context) {
    const icone = SizedBox(
      width: 60,
      height: 90,
      child: Icon(Icons.movie_outlined, size: 32),
    );
    if (endereco.isEmpty) return icone;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        endereco,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        semanticLabel: 'Pôster',
        errorBuilder: (context, erro, pilha) => icone,
      ),
    );
  }
}

/// Mascote com um texto, para o início da busca, sem resultados e erros.
class _Aviso extends StatelessWidget {
  final String texto;

  const _Aviso({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascoteApp(),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
