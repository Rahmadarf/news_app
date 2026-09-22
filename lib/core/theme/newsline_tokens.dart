import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

/// Design tokens that Material's [ColorScheme] does not model.
///
/// Source: `design-prototype/dist/DESIGN_SPEC.md` § Tokens and § Spacing.
/// Read through [NewslineTokens.of] so a widget never hardcodes a hex value.
@immutable
class NewslineTokens extends ThemeExtension<NewslineTokens> {
  const NewslineTokens({
    required this.accent,
    required this.filledControl,
    required this.onFilledControl,
    required this.surfaceSecondary,
    required this.tintedSurface,
    required this.hairline,
    required this.textSecondary,
  });

  /// Light theme instance.
  static const NewslineTokens light = NewslineTokens(
    accent: AppPalette.accentLight,
    filledControl: AppPalette.filledControl,
    onFilledControl: AppPalette.onFilled,
    surfaceSecondary: AppPalette.lightSurfaceSecondary,
    tintedSurface: AppPalette.lightTinted,
    hairline: AppPalette.lightHairline,
    textSecondary: AppPalette.lightTextSecondary,
  );

  /// Dark theme instance.
  static const NewslineTokens dark = NewslineTokens(
    accent: AppPalette.accentDark,
    filledControl: AppPalette.filledControl,
    onFilledControl: AppPalette.onFilled,
    surfaceSecondary: AppPalette.darkSurfaceSecondary,
    tintedSurface: AppPalette.darkTinted,
    hairline: AppPalette.darkHairline,
    textSecondary: AppPalette.darkTextSecondary,
  );

  /// Text and icon accent. Brighter in dark mode to hold contrast.
  final Color accent;

  /// Fill for primary buttons and the selected chip. Identical in both themes.
  final Color filledControl;
  final Color onFilledControl;

  /// Raised panels, thumbnails placeholders, search fields.
  final Color surfaceSecondary;

  /// Accent-tinted background for badges, avatars, and the offline banner.
  final Color tintedSurface;

  /// 1px rules between rows and around outlined controls.
  final Color hairline;

  /// Metadata, captions, and inactive navigation labels.
  final Color textSecondary;

  static NewslineTokens of(BuildContext context) =>
      Theme.of(context).extension<NewslineTokens>() ?? light;

  @override
  NewslineTokens copyWith({
    Color? accent,
    Color? filledControl,
    Color? onFilledControl,
    Color? surfaceSecondary,
    Color? tintedSurface,
    Color? hairline,
    Color? textSecondary,
  }) {
    return NewslineTokens(
      accent: accent ?? this.accent,
      filledControl: filledControl ?? this.filledControl,
      onFilledControl: onFilledControl ?? this.onFilledControl,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      tintedSurface: tintedSurface ?? this.tintedSurface,
      hairline: hairline ?? this.hairline,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  NewslineTokens lerp(ThemeExtension<NewslineTokens>? other, double t) {
    if (other is! NewslineTokens) return this;
    return NewslineTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      filledControl: Color.lerp(filledControl, other.filledControl, t)!,
      onFilledControl: Color.lerp(onFilledControl, other.onFilledControl, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      tintedSurface: Color.lerp(tintedSurface, other.tintedSurface, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

/// Spacing scale from the specification: 4, 8, 12, 16, 20, 24, 32.
///
/// Screen gutters are [gutter]; the featured carousel gap is [featuredGap];
/// list rows use [listRow] vertically.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double gutter = 20;
  static const double xl = 24;
  static const double xxl = 32;

  static const double featuredGap = 14;
  static const double listRow = 15;
}

/// Corner radii from the specification.
abstract final class Radii {
  static const double badge = 4;
  static const double thumbnail = 9;
  static const double hero = 13;
  static const double field = 12;
  static const double pill = 24;
  static const double modal = 24;
  static const double button = 30;
}

/// Fixed component dimensions the design calls out explicitly.
abstract final class Dimens {
  /// Minimum interactive size. The prototype uses 32–44px icon buttons; the
  /// specification requires at least 48dp hit targets in Flutter.
  static const double minTapTarget = 48;

  static const double featuredCardWidth = 276;
  static const double featuredPhotoHeight = 177;
  static const double rowThumbWidth = 92;
  static const double rowThumbHeight = 82;
  static const double avatar = 40;
  static const double sourceDot = 18;
}
