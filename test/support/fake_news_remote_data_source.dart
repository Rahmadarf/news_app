import 'package:news_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Hand-written fake remote source.
///
/// Performs no I/O and awaits no timer, so repository tests stay deterministic
/// and never touch the network.
class FakeNewsRemoteDataSource implements NewsRemoteDataSource {
  FakeNewsRemoteDataSource({
    this.totalResults = 0,
    this.articlesPerPage = 0,
    this.includeInvalidRecord = false,
    this.throwOnCall,
  });

  /// Total reported by the fake envelope, used to derive `hasMore`.
  final int totalResults;

  /// How many *valid* articles each page returns.
  final int articlesPerPage;

  /// When true, each page also carries one record that the mapper must drop.
  final bool includeInvalidRecord;

  /// Thrown instead of returning, to exercise failure mapping. Mutable so a
  /// test can make a source start failing partway through.
  Object? throwOnCall;

  int headlineCallCount = 0;
  int searchCallCount = 0;
  String? lastCategory;
  String? lastQuery;
  int? lastPage;

  @override
  Future<NewsResponseDto> fetchTopHeadlines({
    required String country,
    required String category,
    required int page,
    required int pageSize,
  }) async {
    headlineCallCount++;
    lastCategory = category;
    lastPage = page;
    return _respond();
  }

  @override
  Future<NewsResponseDto> searchEverything({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    searchCallCount++;
    lastQuery = query;
    lastPage = page;
    return _respond();
  }

  NewsResponseDto _respond() {
    final Object? error = throwOnCall;
    if (error != null) throw error;

    final List<ArticleDto> articles = <ArticleDto>[
      for (int i = 0; i < articlesPerPage; i++)
        ArticleDto(
          title: 'Fake headline ${i + 1}',
          url: 'https://example.com/fake/${i + 1}',
          publishedAt: '2026-09-20T08:30:00Z',
          source: const SourceDto(id: 'fake', name: 'Fake Source'),
        ),
      // Missing both title and URL: the mapper must discard it.
      if (includeInvalidRecord) const ArticleDto(description: 'orphan'),
    ];

    return NewsResponseDto(
      status: 'ok',
      totalResults: totalResults,
      articles: articles,
    );
  }
}
