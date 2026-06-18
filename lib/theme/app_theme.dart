import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Primary Palette ─────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF021738);
  static const Color primaryContainer = Color(0xFF1A2C4E);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF8394BC);

  // ─── Secondary / Accent (Action Orange) ──────────────────────────────────
  static const Color secondaryColor = Color(0xFF934B00);
  static const Color secondaryContainer = Color(0xFFFE8A18);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF623000);

  // ─── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiaryColor = Color(0xFF08192C);
  static const Color tertiaryContainer = Color(0xFF1E2E42);
  static const Color onTertiary = Colors.white;
  static const Color onTertiaryContainer = Color(0xFF8595AE);

  // ─── Surface / Background ─────────────────────────────────────────────────
  static const Color surfaceColor = Color(0xFFF9F9F9);
  static const Color surfaceDim = Color(0xFFDADADA);
  static const Color surfaceBright = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color backgroundColor = Color(0xFFF9F9F9);

  // ─── On-Surface ──────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF44474E);
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);

  // ─── Outline ─────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF75777F);
  static const Color outlineVariant = Color(0xFFC5C6CF);

  // ─── Error ───────────────────────────────────────────────────────────────
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Colors.white;
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Semantic Status Colors ───────────────────────────────────────────────
  static const Color statusGreen = Color(0xFF2E7D32);
  static const Color statusGreenContainer = Color(0xFFE8F5E9);
  static const Color statusAmber = Color(0xFFF57C00);
  static const Color statusAmberContainer = Color(0xFFFFF3E0);
  static const Color statusRed = Color(0xFFC62828);
  static const Color statusRedContainer = Color(0xFFFFEBEE);
  static const Color statusBlue = Color(0xFF1565C0);
  static const Color statusBlueContainer = Color(0xFFE3F2FD);

  // ─── Gradient Helpers ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryContainer],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, Color(0xFF0D2040)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryContainer, secondaryColor],
  );

  // ─── Shape / Spacing Constants ────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 40.0;

  // ─── Elevation Shadows ────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floatShadow => [
    BoxShadow(
      color: onSurface.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Theme ────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.64,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.24,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0.14,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        letterSpacing: 0.24,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiaryColor,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        surface: surfaceColor,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: errorColor,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryContainer,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryContainer,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: outlineVariant),
        prefixIconColor: outline,
        suffixIconColor: outline,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        indicatorColor: secondaryContainer.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondaryContainer,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: secondaryContainer, size: 24);
          }
          return const IconThemeData(color: onSurfaceVariant, size: 24);
        }),
        elevation: 8,
        shadowColor: Colors.black12,
      ),
    );
  }
}
