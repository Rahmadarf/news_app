import 'package:flutter/material.dart';

/// Raw palette from `docs/ARCHITECTURE.md` and the approved Newsline design
/// specification (`design-prototype/dist/DESIGN_SPEC.md`, "Tokens").
///
/// Nothing outside `core/theme` should read these directly. Widgets read
/// `Theme.of(context).colorScheme` for the standard roles and
/// `NewslineTokens.of(context)` for the roles Material does not model.
abstract final class AppPalette {
  // Shared accents. The filled control colour is identical in both themes so a
  // primary button keeps the same identity on either surface.
  static const Color accentLight = Color(0xFF11877F);
  static const Color accentDark = Color(0xFF46C8BD);
  static const Color filledControl = Color(0xFF169D94);

  // Light
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF4F6F7);
  static const Color lightText = Color(0xFF181B21);
  static const Color lightTextSecondary = Color(0xFF697179);
  static const Color lightHairline = Color(0xFFE9EDEF);
  static const Color lightTinted = Color(0xFFEAF7F5);

  // Dark
  static const Color darkBackground = Color(0xFF181A21);
  static const Color darkSurfaceSecondary = Color(0xFF23262E);
  static const Color darkText = Color(0xFFF5F6F7);
  static const Color darkTextSecondary = Color(0xFFACB2BC);
  static const Color darkHairline = Color(0xFF30343E);
  static const Color darkTinted = Color(0xFF173B3B);

  static const Color danger = Color(0xFFB3261E);
  static const Color onFilled = Color(0xFFFFFFFF);
}
