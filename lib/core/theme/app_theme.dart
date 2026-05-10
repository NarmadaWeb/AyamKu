import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFb8121e);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFFdc3133);
  static const Color onPrimaryContainer = Color(0xFFfffbff);

  static const Color secondary = Color(0xFF006e2a);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFF5cfd80);
  static const Color onSecondaryContainer = Color(0xFF00732c);

  static const Color error = Color(0xFFba1a1a);
  static const Color onError = Color(0xFFffffff);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);

  static const Color background = Color(0xFFfcf9f8);
  static const Color onBackground = Color(0xFF1b1c1c);
  static const Color surface = Color(0xFFfcf9f8);
  static const Color onSurface = Color(0xFF1b1c1c);

  static const Color surfaceVariant = Color(0xFFe4e2e1);
  static const Color onSurfaceVariant = Color(0xFF5b403d);
  static const Color outline = Color(0xFF906f6c);
  static const Color outlineVariant = Color(0xFFe4bdba);

  static const Color surfaceContainerHighest = Color(0xFFe4e2e1);
  static const Color surfaceContainerHigh = Color(0xFFeae7e7);
  static const Color surfaceContainer = Color(0xFFf0eded);
  static const Color surfaceContainerLow = Color(0xFFf6f3f2);
  static const Color surfaceContainerLowest = Color(0xFFffffff);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64),
        headlineMedium: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
