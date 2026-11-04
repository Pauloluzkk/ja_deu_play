# Identidade visual — Já deu play?

Copie as pastas `assets/` e `lib/` deste pacote para a raiz do projeto Flutter
(elas se juntam às pastas que já existem). Depois peça ao Claude Code para
aplicar a identidade (prompt da Etapa 1b no plano).

## Arquivos

| Arquivo | Uso |
| --- | --- |
| assets/images/logo.png | Logo completa com fundo creme (relatório, slides) |
| assets/images/logo_transparente.png | Logo sem fundo, para as telas de login e cadastro |
| assets/images/mascote.png | Gato de óculos, para lista vazia e carregamento |
| assets/images/icone.png | Ícone do app (1024x1024) |
| assets/images/icone_foreground.png | Camada da frente do ícone adaptável do Android |
| lib/theme/app_theme.dart | Cores (CoresApp) e temas claro/escuro (AppTheme) |
| lib/widgets/logo_app.dart | Widgets LogoApp e MascoteApp |

## Paleta

| Nome | Hex | Onde aparece na logo |
| --- | --- | --- |
| Creme | #F9E9CD | Fundo |
| Marrom café | #432D16 | Letras e contornos |
| Amarelo pipoca | #F3BE3C | Mancha atrás do "PLAY?" |
| Mostarda | #ECB70B | Moletom e óculos |
| Vinho | #A55952 | Calça |
| Bege cadeira | #CFB18A | Cadeira de diretor |

Fontes: Fredoka (títulos) e Nunito (textos), pelo pacote google_fonts.

## Dependências

```
flutter pub add google_fonts
flutter pub add dev:flutter_launcher_icons
```

## pubspec.yaml (acrescentar)

```yaml
flutter:
  assets:
    - assets/images/

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/icone.png"
  adaptive_icon_background: "#F9E9CD"
  adaptive_icon_foreground: "assets/images/icone_foreground.png"
```

Gerar o ícone: `dart run flutter_launcher_icons`

## main.dart

```dart
MaterialApp(
  title: 'Já deu play?',
  theme: AppTheme.claro,
  darkTheme: AppTheme.escuro,
  themeMode: temaEscuro ? ThemeMode.dark : ThemeMode.light, // vem do SharedPreferences
  ...
)
```

Nome que aparece no celular: em `android/app/src/main/AndroidManifest.xml`,
`android:label="Já deu play?"`.
