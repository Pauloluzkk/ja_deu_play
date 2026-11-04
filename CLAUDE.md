# Já deu play? — trabalho de Programação Mobile

App Flutter de watchlist de filmes e séries. Trabalho acadêmico:
os alunos precisam EXPLICAR todo o código numa apresentação.

## Regras de código
- Código simples e didático. Gerenciamento de estado com setState
  e StreamBuilder/FutureBuilder. NÃO usar Provider, Riverpod, Bloc,
  GetX nem geração de código (build_runner).
- Nomes de classes em inglês do Flutter, mas variáveis, métodos de
  serviço, textos da interface e comentários em português.
- Um comentário curto no topo de cada arquivo dizendo para que ele serve.
- Organização: lib/models, lib/services, lib/screens, lib/widgets.
  Telas não acessam Firebase/Hive/SharedPreferences diretamente:
  sempre por um serviço.
- Toda operação de rede: indicador de carregamento + try/catch +
  mensagem de erro em português para o usuário (SnackBar).

## Identidade visual
- Nome do app: "Já deu play?". Cores SEMPRE de CoresApp e tema de
  AppTheme (lib/theme/app_theme.dart); não escrever Color(0x...) nas telas.
- Logo: widget LogoApp; mascote: MascoteApp (lib/widgets/logo_app.dart).
- Cartões, campos e botões com contorno marrom de 2px e cantos de 16,
  como os traços da logo. Fontes Fredoka (títulos) e Nunito (textos).

## Tecnologias obrigatórias e o papel de cada uma
- Firebase Authentication: cadastro, login, logout (e-mail/senha).
- Cloud Firestore: coleção `watchlist`, CRUD completo, todo
  documento tem `userId` e toda consulta filtra por ele.
- Hive (pacote hive_ce + hive_ce_flutter): caixa `filmes_cache`,
  cópia local da lista para uso sem internet. Guardar Map, sem
  TypeAdapter gerado. Limpar a caixa no logout.
- SharedPreferences: ultimo_email, tema_escuro, filtro_status,
  ordenacao. NUNCA guardar senha ou token.
- Extra: API OMDb (pacote http) para buscar filmes.

## Comandos
- Rodar: flutter run (emulador Android)
- Verificar: flutter analyze (deve terminar sem erros)
- Dependências: flutter pub add <pacote>

## Cuidados
- Não criar nem commitar chaves de conta de serviço.
- Não alterar firebase_options.dart à mão (é gerado pelo flutterfire).
- Ao terminar uma tarefa, rodar flutter analyze e resumir em
  português o que mudou e em quais arquivos.