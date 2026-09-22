import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/theme/app_typography.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';

/// Light and dark themes for the approved Newsline design.
///
/// Every colour comes from [AppPalette]; anything Material does not model
/// lives in the [NewslineTokens] extension attached to each theme.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    tokens: NewslineTokens.light,
    background: AppPalette.lightBackground,
    onBackground: AppPalette.lightText,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    tokens: NewslineTokens.dark,
    background: AppPalette.darkBackground,
    onBackground: AppPalette.darkText,
  );

  static ThemeData _build({
    required Brightness brightness,
    required NewslineTokens tokens,
    required Color background,
    required Color onBackground,
  }) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: tokens.accent,
      onPrimary: tokens.onFilledControl,
      primaryContainer: tokens.tintedSurface,
      onPrimaryContainer: tokens.accent,
      secondary: tokens.accent,
      onSecondary: tokens.onFilledControl,
      surface: background,
      onSurface: onBackground,
      surfaceContainerHighest: tokens.surfaceSecondary,
      onSurfaceVariant: tokens.textSecondary,
      outlineVariant: tokens.hairline,
      outline: tokens.hairline,
      error: AppPalette.danger,
      onError: AppPalette.onFilled,
    );

    final TextTheme textTheme = AppTypography.textTheme(
      onBackground,
      tokens.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: AppTypography.sans,
      textTheme: textTheme,
      extensions: <ThemeExtension<Object?>>[tokens],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: tokens.hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(color: onBackground, size: 22),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(Dimens.minTapTarget),
          foregroundColor: onBackground,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.filledControl,
          foregroundColor: tokens.onFilledControl,
          disabledBackgroundColor: tokens.surfaceSecondary,
          elevation: 0,
          minimumSize: const Size.fromHeight(Dimens.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.gutter,
            vertical: Spacing.md,
          ),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.button)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBackground,
          side: BorderSide(color: tokens.hairline),
          minimumSize: const Size.fromHeight(Dimens.minTapTarget),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.pill)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.accent,
          textStyle: textTheme.labelSmall?.copyWith(color: tokens.accent),
          minimumSize: const Size(0, Dimens.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? textTheme.labelSmall?.copyWith(
                  color: tokens.accent,
                  fontWeight: FontWeight.w600,
                )
              : textTheme.labelSmall,
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? tokens.accent
                : tokens.textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onBackground,
        contentTextStyle: textTheme.bodySmall?.copyWith(color: background),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.pill)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.modal),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceSecondary,
        hintStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          borderSide: BorderSide(color: tokens.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          borderSide: BorderSide(color: tokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
      ),
    );
  }
}
