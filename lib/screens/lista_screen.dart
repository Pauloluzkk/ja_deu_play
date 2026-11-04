// Tela principal: mostra a watchlist do usuário logado e leva para
// adicionar, editar, excluir e sair. Sem resposta do Firestore, mostra
// os dados salvos no aparelho pelo Hive.

import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
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
    // Toda lista confirmada pelo servidor é copiada para o Hive
    _filmes = FirestoreService.listar().asyncMap((filmes) async {
      await CacheService.salvarTodos(filmes);
      return filmes;
    });
  }

  /// Dados do aparelho, só do usuário logado.
  List<Filme> _filmesSalvos() {
    return CacheService.listar()
        .where((filme) => filme.userId == AuthService.idUsuario)
        .toList();
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
      // O Firestore confirmou: apaga também a cópia local
      await CacheService.excluir(filme.id);
    } catch (erro) {
      if (mounted) _mostrarMensagem(FirestoreService.traduzirErro(erro));
    } finally {
      if (mounted) setState(() => _idExcluindo = null);
    }
  }

  Widget _montarLista(BuildContext context, AsyncSnapshot<List<Filme>> dados) {
    if (dados.hasError) return _montarListaComErro(dados.error);

    // O Firestore ainda não respondeu: mostra primeiro o que está no Hive
    if (!dados.hasData) {
      final salvos = _filmesSalvos();
      if (salvos.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          const LinearProgressIndicator(),
          Expanded(child: _montarCartoes(salvos)),
        ],
      );
    }

    final filmes = dados.data!;
    if (filmes.isEmpty) {
      return const _Aviso(
        texto: 'Sua lista está vazia.\nToque em + para adicionar um título.',
      );
    }
    return _montarCartoes(filmes);
  }

  /// O Firestore não respondeu ou deu erro: usa os dados do Hive.
  Widget _montarListaComErro(Object? erro) {
    final semConexao = FirestoreService.ehErroDeConexao(erro);
    final salvos = _filmesSalvos();

    if (salvos.isEmpty) {
      return _Aviso(
        texto: semConexao
            ? 'Sem conexão.\nNada salvo neste aparelho ainda.'
            : FirestoreService.traduzirErro(erro),
      );
    }

    return Column(
      children: [
        _FaixaAviso(
          texto: semConexao
              ? 'Modo offline: mostrando dados salvos no aparelho'
              : FirestoreService.traduzirErro(erro),
        ),
        Expanded(child: _montarCartoes(salvos)),
      ],
    );
  }

  Widget _montarCartoes(List<Filme> filmes) {
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

/// Faixa no topo da lista avisando de onde vêm os dados.
class _FaixaAviso extends StatelessWidget {
  final String texto;

  const _FaixaAviso({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CoresApp.amarelo,
        border: Border.all(
          color: CoresApp.marrom,
          width: AppTheme.espessuraBorda,
        ),
        borderRadius: BorderRadius.circular(AppTheme.raio),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: CoresApp.marrom),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: CoresApp.marrom,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
