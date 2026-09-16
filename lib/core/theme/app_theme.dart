import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primarySeed = Color(0xFF2E63EB);
  static const _secondarySeed = Color(0xFF0F347F);

  static ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
        seedColor: _primarySeed,
        primary: _primarySeed,
        secondary: _secondarySeed,
        surface: Colors.white,
        surfaceContainerLow: const Color(0xFFF8FAFC),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF0F172A),
        onSurfaceVariant: const Color(0xFF64748B),
        outline: const Color(0xFFE2E8F0),
        outlineVariant: const Color(0xFFF1F5F9),
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: GoogleFonts.interTextTheme(
          TextTheme(
            headlineLarge: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            headlineSmall: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
            bodySmall: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2E63EB),
          unselectedItemColor: Color(0xFF94A3B8),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E63EB),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primarySeed,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primarySeed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primarySeed,
          brightness: Brightness.dark,
          primary: _primarySeed,
          secondary: _secondarySeed,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      );
}
