import 'package:news_app/features/news/domain/entities/article.dart';

/// Saved-article contract.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
///
/// Bookmarks are identified by the article's canonical URL, the same stable key
/// the feed cache uses, so a saved state is consistent wherever the article
/// appears.
abstract interface class BookmarkRepository {
  /// Emits the full set of saved canonical URLs, and re-emits on every change.
  ///
  /// A stream rather than a one-shot read so the feed, the detail screen, and
  /// the collections list cannot drift out of sync.
  Stream<Set<String>> watchSavedUrls();

  /// Saves [article], storing a copy so it stays readable after the feed cache
  /// is cleared.
  Future<void> save(Article article);

  /// Removes the bookmark for a canonical [url]. The cached article itself is
  /// left in place.
  Future<void> remove(String url);
}
