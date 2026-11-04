// Identidade visual do "Já deu play?": cores, fontes e tema claro/escuro.
// As cores foram tiradas da logo (fundo creme, contorno marrom,
// mancha amarela, calça vinho e cadeira bege).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta da marca. Use estas constantes em vez de escrever cores soltas.
class CoresApp {
  static const creme = Color(0xFFF9E9CD); // fundo da logo
  static const cremeClaro = Color(0xFFFFF5E4); // cartões e campos
  static const marrom = Color(0xFF432D16); // textos e contornos
  static const amarelo = Color(0xFFF3BE3C); // mancha atrás do "PLAY?"
  static const mostarda = Color(0xFFECB70B); // moletom e óculos do gato
  static const vinho = Color(0xFFA55952); // calça do gato
  static const bege = Color(0xFFCFB18A); // cadeira de diretor

  // Tons para o tema escuro
  static const marromNoite = Color(0xFF1E140A);
  static const marromCartao = Color(0xFF2C1F10);
  static const vinhoClaro = Color(0xFFD98880);

  /// Cor de cada status da watchlist
  static Color corDoStatus(String status) =>
      status == 'assistido' ? vinho : mostarda;
}

class AppTheme {
  // Contorno grosso e cantos arredondados, como nos desenhos da logo
  static const double raio = 16;
  static const double espessuraBorda = 2;

  static ThemeData get claro => _montarTema(
        const ColorScheme(
          brightness: Brightness.light,
          primary: CoresApp.marrom,
          onPrimary: CoresApp.creme,
          secondary: CoresApp.amarelo,
          onSecondary: CoresApp.marrom,
          tertiary: CoresApp.vinho,
          onTertiary: Colors.white,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: CoresApp.creme,
          onSurface: CoresApp.marrom,
          surfaceContainerHighest: CoresApp.cremeClaro,
          outline: CoresApp.marrom,
          outlineVariant: CoresApp.bege,
        ),
        cartao: CoresApp.cremeClaro,
      );

  static ThemeData get escuro => _montarTema(
        const ColorScheme(
          brightness: Brightness.dark,
          primary: CoresApp.amarelo,
          onPrimary: CoresApp.marrom,
          secondary: CoresApp.mostarda,
          onSecondary: CoresApp.marrom,
          tertiary: CoresApp.vinhoClaro,
          onTertiary: CoresApp.marrom,
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          surface: CoresApp.marromNoite,
          onSurface: CoresApp.creme,
          surfaceContainerHighest: CoresApp.marromCartao,
          outline: CoresApp.bege,
          outlineVariant: Color(0xFF6B5233),
        ),
        cartao: CoresApp.marromCartao,
      );

  static ThemeData _montarTema(ColorScheme cores, {required Color cartao}) {
    final base = ThemeData(useMaterial3: true, colorScheme: cores);

    // Fredoka (títulos, parecida com as letras da logo) + Nunito (textos)
    final textos = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
    ).apply(bodyColor: cores.onSurface, displayColor: cores.onSurface);

    final borda = BorderSide(color: cores.outline, width: espessuraBorda);
    final formaArredondada =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio));

    return base.copyWith(
      scaffoldBackgroundColor: cores.surface,
      textTheme: textos,
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: cores.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cartao,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: formaArredondada.copyWith(side: borda),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle:
              GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          side: borda,
          foregroundColor: cores.onSurface,
          textStyle:
              GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cores.onSurface,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CoresApp.amarelo,
        foregroundColor: CoresApp.marrom,
        elevation: 0,
        shape: formaArredondada.copyWith(
          side: const BorderSide(color: CoresApp.marrom, width: espessuraBorda),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cartao,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
          borderSide: borda,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
          borderSide: borda,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
          borderSide: BorderSide(color: cores.secondary, width: 3),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cartao,
        selectedColor: CoresApp.amarelo,
        side: borda,
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: cores.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: CoresApp.marrom,
        ),
        checkmarkColor: CoresApp.marrom,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CoresApp.marrom,
        contentTextStyle: GoogleFonts.nunito(color: CoresApp.creme),
        shape: formaArredondada,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cartao,
        shape: formaArredondada.copyWith(side: borda),
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: cores.secondary),
    );
  }
}
