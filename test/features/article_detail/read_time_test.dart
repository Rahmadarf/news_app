import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_detail/presentation/read_time.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/article_source.dart';

Article articleWith({String? description, String? content}) => Article(
  url: 'https://example.com/a',
  title: 'Headline',
  source: const ArticleSource(name: 'Source'),
  description: description,
  content: content,
);

String words(int count) => List<String>.filled(count, 'kata').join(' ');

void main() {
  test('returns null when there is too little text to estimate from', () {
    expect(estimatedReadMinutes(articleWith(content: words(10))), isNull);
    expect(estimatedReadMinutes(articleWith()), isNull);
  });

  test('counts description and content together', () {
    final int? minutes = estimatedReadMinutes(
      articleWith(description: words(20), content: words(20)),
    );

    expect(minutes, 1);
  });

  test('rounds up to the next whole minute', () {
    expect(estimatedReadMinutes(articleWith(content: words(201))), 2);
    expect(estimatedReadMinutes(articleWith(content: words(400))), 2);
    expect(estimatedReadMinutes(articleWith(content: words(401))), 3);
  });

  test('caps the estimate so a malformed body cannot claim hours', () {
    expect(estimatedReadMinutes(articleWith(content: words(500000))), 60);
  });

  test('never returns zero for text above the threshold', () {
    final int? minutes = estimatedReadMinutes(
      articleWith(content: words(40)),
      wordsPerMinute: 10000,
    );

    expect(minutes, 1);
  });
}
