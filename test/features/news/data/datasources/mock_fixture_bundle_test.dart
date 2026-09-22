import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';
import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Covers the production loader, which every other test bypasses.
///
/// Elsewhere the fixture is injected as a string, because real asset I/O does
/// not complete reliably inside `testWidgets`. That left the path the shipped
/// app actually uses — `rootBundle` against the declared asset directory —
/// without any coverage at all.
void main() {
  test('loads the committed fixtures through the real asset bundle', () async {
    // Required before rootBundle is usable.
    TestWidgetsFlutterBinding.ensureInitialized();

    final MockNewsDataSource source = MockNewsDataSource();

    final NewsResponseDto headlines = await source.fetchTopHeadlines(
      country: 'id',
      category: 'general',
      page: 1,
      pageSize: 20,
    );

    expect(
      headlines.articles,
      isNotEmpty,
      reason: 'assets/fixtures/top_headlines.json must be bundled',
    );
    expect(headlines.totalResults, greaterThan(20));

    final NewsResponseDto search = await source.searchEverything(
      query: 'search',
      page: 1,
      pageSize: 20,
    );

    expect(search.articles, isNotEmpty);
  });
}
