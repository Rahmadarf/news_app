import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/data/dto/article_dto.dart';
import 'package:news_app/features/news/data/mappers/article_mapper.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

void main() {
  group('ArticleMapper.toEntity', () {
    test('maps a complete record', () {
      final Article? article = ArticleMapper.toEntity(
        const ArticleDto(
          title: 'Headline',
          description: 'Description',
          url: 'https://example.com/a',
          urlToImage: 'https://example.com/a.jpg',
          publishedAt: '2026-09-20T08:30:00Z',
          content: 'Body',
          source: SourceDto(id: 'src', name: 'Source'),
        ),
      );

      expect(article, isNotNull);
      expect(article!.url, 'https://example.com/a');
      expect(article.title, 'Headline');
      expect(article.source.name, 'Source');
      expect(article.publishedAt, DateTime.utc(2026, 9, 20, 8, 30));
    });

    test('drops a record without a URL', () {
      expect(
        ArticleMapper.toEntity(const ArticleDto(title: 'Headline')),
        isNull,
      );
    });

    test('drops a record without a title', () {
      expect(
        ArticleMapper.toEntity(const ArticleDto(url: 'https://example.com/a')),
        isNull,
      );
    });

    test('treats whitespace-only fields as missing', () {
      expect(
        ArticleMapper.toEntity(
          const ArticleDto(title: '   ', url: 'https://example.com/a'),
        ),
        isNull,
      );
    });

    test('substitutes a source name when the API omits it', () {
      final Article? article = ArticleMapper.toEntity(
        const ArticleDto(title: 'Headline', url: 'https://example.com/a'),
      );

      expect(article!.source.name, ArticleMapper.unknownSourceName);
    });

    test('keeps a null image without failing', () {
      final Article? article = ArticleMapper.toEntity(
        const ArticleDto(title: 'Headline', url: 'https://example.com/a'),
      );

      expect(article!.imageUrl, isNull);
    });
  });

  group('ArticleMapper.parseDate', () {
    test('parses a valid ISO-8601 timestamp', () {
      expect(
        ArticleMapper.parseDate('2026-09-20T08:30:00Z'),
        DateTime.utc(2026, 9, 20, 8, 30),
      );
    });

    test('returns null for a malformed timestamp instead of throwing', () {
      expect(ArticleMapper.parseDate('not-a-date'), isNull);
    });

    test('returns null for null and empty input', () {
      expect(ArticleMapper.parseDate(null), isNull);
      expect(ArticleMapper.parseDate(''), isNull);
    });
  });

  group('ArticleMapper.toEntities', () {
    test('filters invalid records out of a page', () {
      final List<Article> articles =
          ArticleMapper.toEntities(const <ArticleDto>[
            ArticleDto(title: 'Good', url: 'https://example.com/a'),
            ArticleDto(title: 'No URL'),
            ArticleDto(url: 'https://example.com/c'),
            ArticleDto(title: 'Also good', url: 'https://example.com/d'),
          ]);

      expect(articles.map((Article a) => a.title), <String>[
        'Good',
        'Also good',
      ]);
    });
  });
}
