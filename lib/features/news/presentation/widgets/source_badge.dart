import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

/// Small circular initials badge that stands in for a publisher logo.
///
/// The colour is derived from the source name, so the same publisher keeps the
/// same colour across the app without shipping per-source assets.
class SourceBadge extends StatelessWidget {
  const SourceBadge({
    super.key,
    required this.source,
    this.size = Dimens.sourceDot,
  });

  final ArticleSource source;
  final double size;

  /// Muted editorial hues, checked against white text.
  static const List<Color> _palette = <Color>[
    Color(0xFFE94340),
    Color(0xFF376FC5),
    Color(0xFF566F47),
    Color(0xFF8A5A2B),
    Color(0xFF6B4E9B),
    Color(0xFF167C86),
  ];

  static Color colorFor(String name) =>
      _palette[name.hashCode.abs() % _palette.length];

  /// Up to two initials taken from the first two words of the source name.
  static String initialsFor(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Excluded from semantics: the source name is already read out next to it.
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorFor(source.name),
          shape: BoxShape.circle,
        ),
        child: Text(
          initialsFor(source.name),
          textAlign: TextAlign.center,
          // Fixed scale: this glyph is decorative and must stay inside the dot.
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.42,
            height: 1,
          ),
        ),
      ),
    );
  }
}
