import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// SPACING & RADIUS
// =============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 28.0;

  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get buttonRadius => BorderRadius.circular(xl);
  static BorderRadius get chipRadius => BorderRadius.circular(sm);
}

// =============================================================================
// TEXT EXTENSIONS
// =============================================================================

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle withColor(Color color) => copyWith(color: color);
}

// =============================================================================
// GOOGLE-STYLE COLORS
// =============================================================================

class LightColors {
  static const primary = Color(0xFF1A73E8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD3E3FD);
  static const onPrimaryContainer = Color(0xFF001D36);
  
  static const secondary = Color(0xFF00796B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFB2DFDB);
  
  static const tertiary = Color(0xFFE8710A);
  static const onTertiary = Color(0xFFFFFFFF);
  
  static const error = Color(0xFFD93025);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFCE8E6);
  
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF202124);
  static const background = Color(0xFFF8F9FA);
  static const surfaceVariant = Color(0xFFF1F3F4);
  static const onSurfaceVariant = Color(0xFF5F6368);
  
  static const outline = Color(0xFFDADCE0);
  static const outlineVariant = Color(0xFFE8EAED);
}

class DarkColors {
  static const primary = Color(0xFF8AB4F8);
  static const onPrimary = Color(0xFF003063);
  static const primaryContainer = Color(0xFF004A8F);
  static const onPrimaryContainer = Color(0xFFD3E3FD);
  
  static const secondary = Color(0xFF80CBC4);
  static const onSecondary = Color(0xFF003735);
  static const secondaryContainer = Color(0xFF005048);
  
  static const tertiary = Color(0xFFFFB74D);
  static const onTertiary = Color(0xFF4A2800);
  
  static const error = Color(0xFFF28B82);
  static const onError = Color(0xFF601410);
  static const errorContainer = Color(0xFF8C1D18);
  
  static const surface = Color(0xFF202124);
  static const onSurface = Color(0xFFE8EAED);
  static const surfaceVariant = Color(0xFF303134);
  static const onSurfaceVariant = Color(0xFFC4C7C5);
  
  static const outline = Color(0xFF5F6368);
  static const outlineVariant = Color(0xFF3C4043);
}

// =============================================================================
// THEMES
// =============================================================================

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: LightColors.primary,
    onPrimary: LightColors.onPrimary,
    primaryContainer: LightColors.primaryContainer,
    onPrimaryContainer: LightColors.onPrimaryContainer,
    secondary: LightColors.secondary,
    onSecondary: LightColors.onSecondary,
    secondaryContainer: LightColors.secondaryContainer,
    tertiary: LightColors.tertiary,
    onTertiary: LightColors.onTertiary,
    error: LightColors.error,
    onError: LightColors.onError,
    errorContainer: LightColors.errorContainer,
    surface: LightColors.surface,
    onSurface: LightColors.onSurface,
    surfaceContainerHighest: LightColors.surfaceVariant,
    onSurfaceVariant: LightColors.onSurfaceVariant,
    outline: LightColors.outline,
    outlineVariant: LightColors.outlineVariant,
  ),
  scaffoldBackgroundColor: LightColors.background,
  
  appBarTheme: AppBarTheme(
    backgroundColor: LightColors.surface,
    foregroundColor: LightColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: LightColors.onSurface,
    ),
  ),
  
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: BorderSide(color: LightColors.outline.withOpacity(0.5)),
    ),
    color: LightColors.surface,
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: LightColors.primary,
      foregroundColor: LightColors.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      side: const BorderSide(color: LightColors.outline),
    ),
  ),
  
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: const BorderSide(color: LightColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  
  chipTheme: ChipThemeData(
    backgroundColor: LightColors.surfaceVariant,
    selectedColor: LightColors.primaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
    side: BorderSide.none,
  ),
  
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: LightColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    showDragHandle: true,
  ),
  
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: LightColors.surface,
    indicatorColor: LightColors.primaryContainer,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.all(
      GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
  
  tabBarTheme: TabBarTheme(
    indicatorColor: LightColors.primary,
    labelColor: LightColors.primary,
    unselectedLabelColor: LightColors.onSurfaceVariant,
    labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
    splashFactory: InkSparkle.splashFactory,
  ),
  
  textTheme: _buildTextTheme(),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: DarkColors.primary,
    onPrimary: DarkColors.onPrimary,
    primaryContainer: DarkColors.primaryContainer,
    onPrimaryContainer: DarkColors.onPrimaryContainer,
    secondary: DarkColors.secondary,
    onSecondary: DarkColors.onSecondary,
    secondaryContainer: DarkColors.secondaryContainer,
    tertiary: DarkColors.tertiary,
    onTertiary: DarkColors.onTertiary,
    error: DarkColors.error,
    onError: DarkColors.onError,
    errorContainer: DarkColors.errorContainer,
    surface: DarkColors.surface,
    onSurface: DarkColors.onSurface,
    surfaceContainerHighest: DarkColors.surfaceVariant,
    onSurfaceVariant: DarkColors.onSurfaceVariant,
    outline: DarkColors.outline,
    outlineVariant: DarkColors.outlineVariant,
  ),
  scaffoldBackgroundColor: DarkColors.surface,
  
  appBarTheme: AppBarTheme(
    backgroundColor: DarkColors.surface,
    foregroundColor: DarkColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: DarkColors.onSurface,
    ),
  ),
  
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: BorderSide(color: DarkColors.outlineVariant),
    ),
    color: DarkColors.surfaceVariant,
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: DarkColors.primary,
      foregroundColor: DarkColors.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      side: const BorderSide(color: DarkColors.outline),
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.buttonRadius,
      borderSide: const BorderSide(color: DarkColors.primary, width: 2),
    ),
  ),
  
  chipTheme: ChipThemeData(
    backgroundColor: DarkColors.surfaceVariant,
    selectedColor: DarkColors.primaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
    side: BorderSide.none,
  ),
  
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: DarkColors.surfaceVariant,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    showDragHandle: true,
  ),
  
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: DarkColors.surface,
    indicatorColor: DarkColors.primaryContainer,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.all(
      GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
  
  tabBarTheme: TabBarTheme(
    indicatorColor: DarkColors.primary,
    labelColor: DarkColors.primary,
    unselectedLabelColor: DarkColors.onSurfaceVariant,
    labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
    splashFactory: InkSparkle.splashFactory,
  ),
  
  textTheme: _buildTextTheme(),
);

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w500),
    headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w500),
    headlineSmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400),
  );
}
