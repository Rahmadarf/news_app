/// Wire representation of a NewsAPI article.
///
/// Every field is nullable because NewsAPI genuinely sends nulls, empty
/// strings, and `"[Removed]"` placeholders. Nothing here is allowed to escape
/// the data layer; the mapper converts DTOs into domain entities and drops
/// records that cannot satisfy the entity invariants.
class ArticleDto {
  const ArticleDto({
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
  });

  factory ArticleDto.fromJson(Map<String, dynamic> json) {
    final Object? rawSource = json['source'];
    return ArticleDto(
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
      source: rawSource is Map<String, dynamic>
          ? SourceDto.fromJson(rawSource)
          : null,
    );
  }

  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final SourceDto? source;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'content': content,
    'source': source?.toJson(),
  };
}

/// Wire representation of a NewsAPI source object.
class SourceDto {
  const SourceDto({this.id, this.name});

  factory SourceDto.fromJson(Map<String, dynamic> json) =>
      SourceDto(id: json['id'] as String?, name: json['name'] as String?);

  final String? id;
  final String? name;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}
