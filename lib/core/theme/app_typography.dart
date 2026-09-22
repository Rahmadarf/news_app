import 'package:flutter/material.dart';

/// Type scale from `design-prototype/dist/DESIGN_SPEC.md` § Tokens.
///
/// Playfair Display 600 carries editorial titles; DM Sans carries UI. Both are
/// bundled under `assets/fonts/` (SIL Open Font License; see the OFL files
/// alongside them), so typography does not depend on network access.
///
/// Sizes are logical pixels at a text scale of 1.0 and scale with the system
/// setting. The prototype's 10–11px metadata is raised to 12px, as the
/// specification requires for Flutter.
abstract final class AppTypography {
  static const String serif = 'PlayfairDisplay';
  static const String sans = 'DMSans';

  /// Smallest size any metadata or tab label may use.
  static const double minimumMetadataSize = 12;

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      // Editorial — Playfair Display.
      displaySmall: _serif(29, 1.3, primary, letterSpacing: -0.6),
      headlineMedium: _serif(23, 1.3, primary, letterSpacing: -0.5),
      headlineSmall: _serif(21, 1.3, primary, letterSpacing: -0.3),
      titleLarge: _serif(22, 1.25, primary),
      titleMedium: _serif(16, 1.4, primary),

      // Reading body — serif, generous leading.
      bodyLarge: TextStyle(
        fontFamily: serif,
        fontSize: 17,
        height: 1.9,
        color: primary,
      ),

      // UI — DM Sans.
      bodyMedium: _sans(16, 1.7, secondary),
      bodySmall: _sans(14, 1.5, secondary),
      labelLarge: _sans(14, 1.45, primary, weight: FontWeight.w600),
      labelMedium: _sans(13, 1.4, secondary, weight: FontWeight.w500),
      labelSmall: _sans(
        minimumMetadataSize,
        1.5,
        secondary,
        weight: FontWeight.w500,
      ),
      titleSmall: _sans(14, 1.4, primary, weight: FontWeight.w600),
    );
  }

  static TextStyle _serif(
    double size,
    double height,
    Color color, {
    double? letterSpacing,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _sans(
    double size,
    double height,
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      height: height,
      fontWeight: weight,
      color: color,
    );
  }
}
