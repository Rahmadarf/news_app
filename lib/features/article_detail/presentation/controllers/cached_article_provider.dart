import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

/// Looks an article up in the local cache by canonical URL.
///
/// Used when the article screen is reached without an object in hand — a deep
/// link, a hot restart, or a browser reload. Resolves to `null` when the
/// article was never cached, which the screen renders as an explanatory state
/// rather than an error.
final cachedArticleProvider = FutureProvider.autoDispose
    .family<Article?, String>((Ref ref, String url) {
      return ref.watch(newsRepositoryProvider).findCachedArticle(url);
    });
