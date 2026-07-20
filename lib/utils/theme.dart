import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The six moods the theme moves through over a day.
enum TimeOfDayTheme { night, dawn, morning, afternoon, evening, dusk }

class AppTheme {
  /// Which mood a given hour belongs to. Pure and total, so it can be tested at
  /// every boundary without waiting for the clock.
  static TimeOfDayTheme bucketForHour(int hour) {
    if (hour >= 22 || hour < 5) return TimeOfDayTheme.night; // 22h–5h
    if (hour < 7) return TimeOfDayTheme.dawn; // 5h–7h
    if (hour < 12) return TimeOfDayTheme.morning; // 7h–12h
    if (hour < 17) return TimeOfDayTheme.afternoon; // 12h–17h
    if (hour < 19) return TimeOfDayTheme.evening; // 17h–19h
    return TimeOfDayTheme.dusk; // 19h–22h
  }

  static ThemeData themeFor(TimeOfDayTheme bucket) => switch (bucket) {
    TimeOfDayTheme.night => _getNightTheme(),
    TimeOfDayTheme.dawn => _getDawnTheme(),
    TimeOfDayTheme.morning => _getMorningTheme(),
    TimeOfDayTheme.afternoon => _getAfternoonTheme(),
    TimeOfDayTheme.evening => _getEveningTheme(),
    TimeOfDayTheme.dusk => _getDuskTheme(),
  };

  // Nuit : Bleu très foncé avec étoiles
  static ThemeData _getNightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF64B5F6),
        secondary: const Color(0xFF4FC3F7),
        surface: const Color(0xFF1A237E),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      cardTheme: CardThemeData(
        color: const Color(0xFF1B263B).withValues(alpha: 0.8),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
      ),
    );
  }

  // Aube : Rose et orange doux
  static ThemeData _getDawnTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFF6B9D),
        secondary: const Color(0xFFFFAB91),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF0F5),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 2,
        shadowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: const Color(0xFF5D4E6D),
        displayColor: const Color(0xFF4A3F5C),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFFFF0F5),
        foregroundColor: Color(0xFF5D4E6D),
      ),
    );
  }

  // Matin : Bleu clair et frais
  static ThemeData _getMorningTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF42A5F5),
        secondary: const Color(0xFF81D4FA),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF42A5F5).withValues(alpha: 0.15),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: const Color(0xFF1565C0),
        displayColor: const Color(0xFF0D47A1),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF1565C0),
      ),
    );
  }

  // Après-midi : Bleu vif et lumineux
  static ThemeData _getAfternoonTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1E88E5),
        secondary: const Color(0xFF4FC3F7),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF87CEEB),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: const Color(0xFF1E88E5).withValues(alpha: 0.2),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: const Color(0xFF01579B),
        displayColor: const Color(0xFF004D7A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF87CEEB),
        foregroundColor: Color(0xFF01579B),
      ),
    );
  }

  // Soir : Orange et doré
  static ThemeData _getEveningTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFF6F00),
        secondary: const Color(0xFFFFAB40),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.95),
        elevation: 2,
        shadowColor: const Color(0xFFFF6F00).withValues(alpha: 0.2),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: const Color(0xFFBF360C),
        displayColor: const Color(0xFF8D2A00),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFFFF3E0),
        foregroundColor: Color(0xFFBF360C),
      ),
    );
  }

  // Crépuscule : Bleu foncé/violet
  static ThemeData _getDuskTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF7E57C2),
        secondary: const Color(0xFF9575CD),
        surface: const Color(0xFF311B92),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A237E),
      cardTheme: CardThemeData(
        color: const Color(0xFF4527A0).withValues(alpha: 0.7),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: Colors.white.withValues(alpha: 0.95),
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
    );
  }
}
