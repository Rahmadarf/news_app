import 'package:news_app/features/news/domain/entities/article.dart';

/// Rough reading time over the text the API actually provided.
///
/// NewsAPI truncates `content`, so this is an estimate of what is on the
/// screen, not of the full article — which is why the screen also carries a
/// notice saying the excerpt is partial.
///
/// Returns `null` when there is too little text for a number to mean anything,
/// rather than claiming "1 min read" for two sentences.
int? estimatedReadMinutes(Article article, {int wordsPerMinute = 200}) {
  const int minimumWords = 40;

  final String text = <String?>[
    article.description,
    article.content,
  ].whereType<String>().join(' ');

  final int words = text
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .length;

  if (words < minimumWords) return null;
  return (words / wordsPerMinute).ceil().clamp(1, 60);
}
