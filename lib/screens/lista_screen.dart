// Tela principal: mostra a watchlist do usuário logado e leva para
// adicionar, editar, excluir e sair.

import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/filme_card.dart';
import '../widgets/logo_app.dart';
import 'formulario_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  // Criado uma única vez: se fosse criado no build, cada setState
  // refaria a consulta e a lista piscaria.
  late final Stream<List<Filme>> _filmes;
  bool _saindo = false;
  String? _idExcluindo;

  @override
  void initState() {
    super.initState();
    _filmes = FirestoreService.listar();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Sem filme abre o formulário vazio; com filme abre para editar.
  void _abrirFormulario([Filme? filme]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FormularioScreen(filme: filme)),
    );
  }

  Future<void> _sair() async {
    setState(() => _saindo = true);
    try {
      await AuthService.sair();
      // Deu certo: o AuthGate percebe o logout e volta para o login.
    } catch (erro) {
      if (mounted) _mostrarMensagem('Não foi possível sair. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saindo = false);
    }
  }

  Future<void> _confirmarExclusao(Filme filme) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir título'),
        content: Text('Deseja mesmo excluir "${filme.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    setState(() => _idExcluindo = filme.id);
    try {
      await FirestoreService.excluir(filme.id);
    } catch (erro) {
      if (mounted) _mostrarMensagem(FirestoreService.traduzirErro(erro));
    } finally {
      if (mounted) setState(() => _idExcluindo = null);
    }
  }

  Widget _montarLista(BuildContext context, AsyncSnapshot<List<Filme>> dados) {
    if (dados.hasError) {
      return _Aviso(texto: FirestoreService.traduzirErro(dados.error));
    }
    if (!dados.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final filmes = dados.data!;
    if (filmes.isEmpty) {
      return const _Aviso(
        texto: 'Sua lista está vazia.\nToque em + para adicionar um título.',
      );
    }

    return ListView.builder(
      // Espaço no fim para o botão + não cobrir o último cartão
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: filmes.length,
      itemBuilder: (context, indice) {
        final filme = filmes[indice];
        return FilmeCard(
          filme: filme,
          excluindo: filme.id == _idExcluindo,
          aoTocar: () => _abrirFormulario(filme),
          aoExcluir: () => _confirmarExclusao(filme),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Já deu play?'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _saindo ? null : _sair,
            icon: _saindo
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Filme>>(
        stream: _filmes,
        builder: _montarLista,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar título',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Mascote com um texto, para lista vazia e mensagens de erro.
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
