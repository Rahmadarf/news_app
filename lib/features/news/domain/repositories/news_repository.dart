import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_feed.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';

/// The only news contract presentation code depends on.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
///
/// Every method completes with an [ArticleFeed] or throws a
/// `Failure` from `core/errors/failure.dart`. Implementations must not leak
/// transport exceptions, and must not surface API DTOs.
///
/// Headline and search results are separate operations on purpose: refreshing
/// one must never replace the other. See docs/AUDIT.md H-6.
abstract interface class NewsRepository {
  /// One page of headlines for [category].
  ///
  /// [page] is 1-based. [forceRefresh] bypasses any fresh cache entry; it is
  /// the explicit pull-to-refresh semantic.
  Future<ArticleFeed> getTopHeadlines({
    required NewsCategory category,
    int page,
    bool forceRefresh,
  });

  /// One page of search results for [query]. [page] is 1-based.
  ///
  /// Search results are not cached, so this always reaches the active source.
  Future<ArticleFeed> searchArticles({required String query, int page});

  /// The stored article for a canonical [url], or `null` when it was never
  /// cached. Backs screens reached by deep link, where no object was passed.
  Future<Article?> findCachedArticle(String url);

  /// Drops every cached feed. Bookmarked articles are retained.
  ///
  /// Throws `CacheFailure` when local storage cannot be cleared.
  Future<void> clearCache();
}
