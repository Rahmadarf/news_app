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

  group('ArticleMapper removed-article filtering', () {
    test('drops a record whose title is the [Removed] placeholder', () {
      expect(
        ArticleMapper.toEntity(
          const ArticleDto(
            title: '[Removed]',
            url: 'https://example.com/a',
            content: '[Removed]',
          ),
        ),
        isNull,
      );
    });

    test('drops a record pointing at removed.com', () {
      expect(
        ArticleMapper.toEntity(
          const ArticleDto(title: 'Looks fine', url: 'https://removed.com'),
        ),
        isNull,
      );
    });

    test('keeps a record that merely mentions the word removed', () {
      expect(
        ArticleMapper.toEntity(
          const ArticleDto(
            title: 'Statue removed from the square',
            url: 'https://example.com/statue',
          ),
        ),
        isNotNull,
      );
    });
  });

  group('ArticleMapper.canonicalizeUrl', () {
    test('lowercases scheme and host and drops the fragment', () {
      expect(
        ArticleMapper.canonicalizeUrl('HTTPS://Example.COM/News/1#top'),
        'https://example.com/News/1',
      );
    });

    test('strips tracking parameters but keeps meaningful ones', () {
      expect(
        ArticleMapper.canonicalizeUrl(
          'https://example.com/a?id=7&utm_source=news&fbclid=abc',
        ),
        'https://example.com/a?id=7',
      );
    });

    test('strips a trailing slash', () {
      expect(
        ArticleMapper.canonicalizeUrl('https://example.com/a/'),
        'https://example.com/a',
      );
    });

    test('rejects a relative or non-http URL', () {
      expect(ArticleMapper.canonicalizeUrl('/relative/path'), isNull);
      expect(ArticleMapper.canonicalizeUrl('ftp://example.com/a'), isNull);
      expect(ArticleMapper.canonicalizeUrl('not a url at all'), isNull);
    });
  });

  group('ArticleMapper deduplication', () {
    test('collapses records that share a canonical URL, first wins', () {
      final List<Article> articles =
          ArticleMapper.toEntities(const <ArticleDto>[
            ArticleDto(title: 'Original', url: 'https://example.com/a'),
            ArticleDto(
              title: 'Syndicated copy',
              url: 'https://EXAMPLE.com/a/?utm_campaign=x#top',
            ),
            ArticleDto(title: 'Different', url: 'https://example.com/b'),
          ]);

      expect(articles.map((Article a) => a.title), <String>[
        'Original',
        'Different',
      ]);
    });
  });
}
