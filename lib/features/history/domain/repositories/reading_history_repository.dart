import 'package:news_app/features/news/domain/entities/article.dart';

/// Articles the reader has opened, most recent first.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
abstract interface class ReadingHistoryRepository {
  /// Most recently opened first, capped at [maxEntries].
  Stream<List<Article>> watchRecent();

  /// Records that [article] was opened, moving it to the top if it was already
  /// present.
  Future<void> record(Article article);

  /// Clears the history. Bookmarks are not affected.
  Future<void> clear();

  /// How many entries are retained.
  static const int maxEntries = 50;
}
