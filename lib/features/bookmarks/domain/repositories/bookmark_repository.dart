import 'package:news_app/features/bookmarks/domain/entities/saved_article.dart';
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
  /// A stream rather than a one-shot read so the feed, the article screen, and
  /// the collections list cannot drift out of sync.
  Stream<Set<String>> watchSavedUrls();

  /// Saved articles, most recently saved first.
  ///
  /// With [collectionName] given, only that collection; otherwise everything.
  Stream<List<SavedArticle>> watchSaved({String? collectionName});

  /// Collection names, oldest first so the list does not reshuffle.
  Stream<List<String>> watchCollections();

  /// Saves [article], storing a copy so it stays readable after the feed cache
  /// is cleared. Keeps the existing collection if it was already saved.
  Future<void> save(Article article, {String? collectionName});

  /// Removes the bookmark for a canonical [url]. The cached article itself is
  /// left in place.
  Future<void> remove(String url);

  /// Files an already-saved article, or clears its filing with `null`.
  Future<void> assignToCollection(String url, String? collectionName);

  /// Creates an empty collection. Returns false when the name is blank or
  /// already taken.
  Future<bool> createCollection(String name);

  /// Deletes a collection. Its articles stay saved but become unfiled.
  Future<void> deleteCollection(String name);
}
