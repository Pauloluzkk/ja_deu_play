// Formulário usado para criar um título novo (filme == null)
// e para editar um título que já existe.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/filme.dart';
import '../services/firestore_service.dart';
import '../widgets/botao_carregando.dart';
import '../widgets/estrelas_nota.dart';

class FormularioScreen extends StatefulWidget {
  final Filme? filme;

  const FormularioScreen({super.key, this.filme});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _campoTitulo = TextEditingController();
  final _campoAno = TextEditingController();
  final _campoComentario = TextEditingController();
  String _tipo = 'filme';
  String _status = 'quero_ver';
  int _nota = 0;
  bool _salvando = false;

  // Só é gerado no primeiro salvamento de um título novo
  late final String _idNovo = FirestoreService.novoId();

  bool get _editando => widget.filme != null;

  @override
  void initState() {
    super.initState();
    final filme = widget.filme;
    if (filme != null) {
      _campoTitulo.text = filme.titulo;
      _campoAno.text = filme.ano.toString();
      _campoComentario.text = filme.comentario;
      _tipo = filme.tipo;
      _status = filme.status;
      _nota = filme.nota;
    }
  }

  @override
  void dispose() {
    _campoTitulo.dispose();
    _campoAno.dispose();
    _campoComentario.dispose();
    super.dispose();
  }

  String? _validarTitulo(String? titulo) {
    if (titulo == null || titulo.trim().isEmpty) return 'Informe o título.';
    return null;
  }

  String? _validarAno(String? ano) {
    if (ano == null || !RegExp(r'^\d{4}$').hasMatch(ano)) {
      return 'Informe o ano com 4 dígitos.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      // Pôster, imdbId e data de criação não são editados aqui,
      // mas precisam ser mantidos ao salvar uma edição.
      final original = widget.filme;
      final filme = Filme(
        id: original?.id ?? _idNovo,
        titulo: _campoTitulo.text.trim(),
        ano: int.parse(_campoAno.text),
        tipo: _tipo,
        status: _status,
        nota: _nota,
        comentario: _campoComentario.text.trim(),
        posterUrl: original?.posterUrl ?? '',
        imdbId: original?.imdbId ?? '',
        criadoEm: original?.criadoEm,
      );

      if (_editando) {
        await FirestoreService.atualizar(filme);
      } else {
        await FirestoreService.adicionar(filme);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(FirestoreService.traduzirErro(erro))),
          );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _escolha(String texto, bool selecionado, VoidCallback aoEscolher) {
    return ChoiceChip(
      label: Text(texto),
      selected: selecionado,
      onSelected: (_) => aoEscolher(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar título' : 'Novo título')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _campoTitulo,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: _validarTitulo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _campoAno,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(labelText: 'Ano'),
                  validator: _validarAno,
                ),
                const SizedBox(height: 16),
                Text('Tipo', style: textos.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _escolha('Filme', _tipo == 'filme',
                        () => setState(() => _tipo = 'filme')),
                    _escolha('Série', _tipo == 'serie',
                        () => setState(() => _tipo = 'serie')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Status', style: textos.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _escolha('Quero ver', _status == 'quero_ver',
                        () => setState(() => _status = 'quero_ver')),
                    _escolha('Assistido', _status == 'assistido',
                        () => setState(() => _status = 'assistido')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Nota', style: textos.titleMedium),
                EstrelasNota(
                  nota: _nota,
                  tamanho: 32,
                  aoMudar: (nota) => setState(() => _nota = nota),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _campoComentario,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Comentário (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                BotaoCarregando(
                  texto: 'Salvar',
                  carregando: _salvando,
                  aoPressionar: _salvar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
