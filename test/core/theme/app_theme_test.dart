import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/core/theme/app_typography.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';

void main() {
  group('design tokens', () {
    test('light theme carries the approved light palette', () {
      final ThemeData theme = AppTheme.light;
      final NewslineTokens tokens = theme.extension<NewslineTokens>()!;

      expect(theme.scaffoldBackgroundColor, AppPalette.lightBackground);
      expect(tokens.accent, AppPalette.accentLight);
      expect(tokens.surfaceSecondary, AppPalette.lightSurfaceSecondary);
      expect(tokens.hairline, AppPalette.lightHairline);
      expect(tokens.tintedSurface, AppPalette.lightTinted);
      expect(tokens.textSecondary, AppPalette.lightTextSecondary);
    });

    test('dark theme carries the approved dark palette', () {
      final ThemeData theme = AppTheme.dark;
      final NewslineTokens tokens = theme.extension<NewslineTokens>()!;

      expect(theme.scaffoldBackgroundColor, AppPalette.darkBackground);
      expect(tokens.accent, AppPalette.accentDark);
      expect(tokens.surfaceSecondary, AppPalette.darkSurfaceSecondary);
      expect(tokens.hairline, AppPalette.darkHairline);
      expect(tokens.tintedSurface, AppPalette.darkTinted);
      expect(tokens.textSecondary, AppPalette.darkTextSecondary);
    });

    test('the filled control colour is identical in both themes', () {
      expect(
        AppTheme.light.extension<NewslineTokens>()!.filledControl,
        AppTheme.dark.extension<NewslineTokens>()!.filledControl,
      );
    });
  });

  group('typography', () {
    test('editorial styles use the bundled serif', () {
      final TextTheme text = AppTheme.light.textTheme;

      for (final TextStyle? style in <TextStyle?>[
        text.displaySmall,
        text.headlineMedium,
        text.headlineSmall,
        text.titleMedium,
        text.bodyLarge,
      ]) {
        expect(style?.fontFamily, AppTypography.serif);
      }
    });

    test('UI styles use the bundled sans', () {
      final TextTheme text = AppTheme.light.textTheme;

      for (final TextStyle? style in <TextStyle?>[
        text.bodyMedium,
        text.bodySmall,
        text.labelLarge,
        text.labelSmall,
        text.titleSmall,
      ]) {
        expect(style?.fontFamily, AppTypography.sans);
      }
    });

    test('no metadata style drops below the 12sp floor', () {
      final TextTheme text = AppTheme.light.textTheme;

      for (final TextStyle? style in <TextStyle?>[
        text.labelSmall,
        text.labelMedium,
        text.bodySmall,
      ]) {
        expect(
          style!.fontSize,
          greaterThanOrEqualTo(AppTypography.minimumMetadataSize),
        );
      }
    });
  });

  group('controls', () {
    test('primary and outlined buttons meet the 48dp minimum height', () {
      final ThemeData theme = AppTheme.light;

      expect(
        theme.elevatedButtonTheme.style?.minimumSize
            ?.resolve(<WidgetState>{})
            ?.height,
        Dimens.minTapTarget,
      );
      expect(
        theme.outlinedButtonTheme.style?.minimumSize
            ?.resolve(<WidgetState>{})
            ?.height,
        Dimens.minTapTarget,
      );
    });
  });
}
