import 'package:news_app/features/news/domain/entities/article.dart';

/// A saved article together with the collection it is filed under.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
class SavedArticle {
  const SavedArticle({
    required this.article,
    required this.savedAt,
    this.collectionName,
  });

  final Article article;
  final DateTime savedAt;

  /// `null` means saved but not filed into any collection.
  final String? collectionName;
}
