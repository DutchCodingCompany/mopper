import 'package:flutter/material.dart';

/// The mopper design system theme, derived from the "QA Feedback Hub" Stitch
/// design system (Precision Feedback System).
///
/// This theme is applied as a scoped override inside the feedback overlay,
/// ensuring visual consistency regardless of the host app's theme.
class MopperTheme {
  MopperTheme._();

  // ─── Color Tokens ─────────────────────────────────────────────────────

  static const _primary = Color(0xFF004CCD);
  static const _onPrimary = Color(0xFFFFFFFF);
  static const _primaryContainer = Color(0xFF0F62FE);
  static const _onPrimaryContainer = Color(0xFFF3F3FF);

  static const _secondary = Color(0xFF5E5E5E);
  static const _onSecondary = Color(0xFFFFFFFF);
  static const _secondaryContainer = Color(0xFFE1DFDF);
  static const _onSecondaryContainer = Color(0xFF626263);

  static const _tertiary = Color(0xFF304DB9);
  static const _onTertiary = Color(0xFFFFFFFF);
  static const _tertiaryContainer = Color(0xFF4B67D3);
  static const _onTertiaryContainer = Color(0xFFF3F3FF);

  static const _error = Color(0xFFBA1A1A);
  static const _onError = Color(0xFFFFFFFF);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);

  static const _surface = Color(0xFFF9F9F9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF424656);
  static const _outline = Color(0xFF737687);
  static const _outlineVariant = Color(0xFFC3C6D8);

  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerLow = Color(0xFFF3F3F3);
  static const _surfaceContainer = Color(0xFFEEEEEE);
  static const _surfaceContainerHigh = Color(0xFFE8E8E8);
  static const _surfaceContainerHighest = Color(0xFFE2E2E2);

  static const _inverseSurface = Color(0xFF2F3131);
  static const _onInverseSurface = Color(0xFFF1F1F1);
  static const _inversePrimary = Color(0xFFB4C5FF);

  // ─── Annotation Colors ───────────────────────────────────────────────

  /// Red color for screenshot annotations.
  static const annotationRed = Color(0xFFBA1A1A);

  /// Yellow color for screenshot annotations.
  static const annotationYellow = Color(0xFFFFD700);

  /// Blue color for screenshot annotations.
  static const annotationBlue = Color(0xFF0F62FE);

  // ─── Color Scheme ───────────────────────────────────────────────────

  /// The color scheme for the mopper theme.
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: _onPrimary,
    primaryContainer: _primaryContainer,
    onPrimaryContainer: _onPrimaryContainer,
    secondary: _secondary,
    onSecondary: _onSecondary,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onSecondaryContainer,
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: _onTertiaryContainer,
    error: _error,
    onError: _onError,
    errorContainer: _errorContainer,
    onErrorContainer: _onErrorContainer,
    surface: _surface,
    onSurface: _onSurface,
    onSurfaceVariant: _onSurfaceVariant,
    outline: _outline,
    outlineVariant: _outlineVariant,
    surfaceContainerLowest: _surfaceContainerLowest,
    surfaceContainerLow: _surfaceContainerLow,
    surfaceContainer: _surfaceContainer,
    surfaceContainerHigh: _surfaceContainerHigh,
    surfaceContainerHighest: _surfaceContainerHighest,
    inverseSurface: _inverseSurface,
    onInverseSurface: _onInverseSurface,
    inversePrimary: _inversePrimary,
  );

  // ─── Text Theme ──────────────────────────────────────────────────────

  static const _textTheme = TextTheme(
    // display-lg: 48px / 56px / 700
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 56 / 48,
      letterSpacing: -0.96, // -0.02em
    ),
    // headline-lg: 32px / 40px / 600
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
      letterSpacing: -0.32, // -0.01em
    ),
    // headline-md: 24px / 32px / 600
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
    ),
    // body-lg: 18px / 28px / 400
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
    ),
    // body-md: 16px / 24px / 400
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),
    // body-sm: 14px / 20px / 400
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),
    // label-md: 12px / 16px / 600
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
    ),
    // label-sm used for code: 13px / 20px / 400
    labelSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 20 / 13,
    ),
  );

  // ─── ThemeData ───────────────────────────────────────────────────────

  /// The light [ThemeData] for the mopper feedback overlay.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: _textTheme,
    scaffoldBackgroundColor: _surface,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryContainer,
        foregroundColor: _onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryContainer,
        foregroundColor: _onPrimaryContainer,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _onSurfaceVariant,
        side: const BorderSide(color: _outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _onSurfaceVariant,
        shape: const StadiumBorder(),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: _surfaceContainerHigh,
      selectedColor: _primary,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: WidgetStateColor.fromMap({
          WidgetState.selected: _onPrimary,
          WidgetState.any: _onSurfaceVariant,
        }),
      ),
      side: BorderSide(color: _outlineVariant),
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceContainerLowest,
      hintStyle: const TextStyle(color: _outline),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC6C6C6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC6C6C6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryContainer, width: 2),
      ),
    ),
  );
}
