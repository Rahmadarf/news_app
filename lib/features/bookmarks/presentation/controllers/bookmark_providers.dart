import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:news_app/features/bookmarks/domain/entities/saved_article.dart';
import 'package:news_app/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((Ref ref) {
  return BookmarkRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(newsLocalDataSourceProvider),
  );
});

/// Canonical URLs of every saved article.
///
/// A single stream feeds every save control in the app, so the feed, the
/// article screen, and the collections list can never disagree.
final savedArticleUrlsProvider = StreamProvider<Set<String>>((Ref ref) {
  return ref.watch(bookmarkRepositoryProvider).watchSavedUrls();
});

/// Collection names, oldest first.
final collectionsProvider = StreamProvider<List<String>>((Ref ref) {
  return ref.watch(bookmarkRepositoryProvider).watchCollections();
});

/// Which collection the Bookmark screen is filtered to. `null` means "All".
final selectedCollectionProvider =
    NotifierProvider<SelectedCollectionController, String?>(
      SelectedCollectionController.new,
    );

class SelectedCollectionController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? name) => state = name;
}

/// Saved articles for the active filter.
final savedArticlesProvider = StreamProvider<List<SavedArticle>>((Ref ref) {
  final String? collection = ref.watch(selectedCollectionProvider);
  return ref
      .watch(bookmarkRepositoryProvider)
      .watchSaved(collectionName: collection);
});

/// Toggles the saved state of [article]; returns the state afterwards.
Future<bool> toggleBookmark(WidgetRef ref, Article article) async {
  final Set<String> saved =
      ref.read(savedArticleUrlsProvider).value ?? const <String>{};
  final BookmarkRepository repository = ref.read(bookmarkRepositoryProvider);

  if (saved.contains(article.url)) {
    await repository.remove(article.url);
    return false;
  }

  await repository.save(article);
  return true;
}
