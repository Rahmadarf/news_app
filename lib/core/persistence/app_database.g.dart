// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedArticlesTable extends CachedArticles
    with TableInfo<$CachedArticlesTable, CachedArticle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    title,
    sourceName,
    sourceId,
    description,
    imageUrl,
    publishedAt,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedArticle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  CachedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedArticle(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
    );
  }

  @override
  $CachedArticlesTable createAlias(String alias) {
    return $CachedArticlesTable(attachedDatabase, alias);
  }
}

class CachedArticle extends DataClass implements Insertable<CachedArticle> {
  final String url;
  final String title;
  final String sourceName;
  final String? sourceId;
  final String? description;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? content;
  const CachedArticle({
    required this.url,
    required this.title,
    required this.sourceName,
    this.sourceId,
    this.description,
    this.imageUrl,
    this.publishedAt,
    this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['source_name'] = Variable<String>(sourceName);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    return map;
  }

  CachedArticlesCompanion toCompanion(bool nullToAbsent) {
    return CachedArticlesCompanion(
      url: Value(url),
      title: Value(title),
      sourceName: Value(sourceName),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
    );
  }

  factory CachedArticle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedArticle(
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      content: serializer.fromJson<String?>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'sourceName': serializer.toJson<String>(sourceName),
      'sourceId': serializer.toJson<String?>(sourceId),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'content': serializer.toJson<String?>(content),
    };
  }

  CachedArticle copyWith({
    String? url,
    String? title,
    String? sourceName,
    Value<String?> sourceId = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<String?> content = const Value.absent(),
  }) => CachedArticle(
    url: url ?? this.url,
    title: title ?? this.title,
    sourceName: sourceName ?? this.sourceName,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    content: content.present ? content.value : this.content,
  );
  CachedArticle copyWithCompanion(CachedArticlesCompanion data) {
    return CachedArticle(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedArticle(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceId: $sourceId, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    title,
    sourceName,
    sourceId,
    description,
    imageUrl,
    publishedAt,
    content,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedArticle &&
          other.url == this.url &&
          other.title == this.title &&
          other.sourceName == this.sourceName &&
          other.sourceId == this.sourceId &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.publishedAt == this.publishedAt &&
          other.content == this.content);
}

class CachedArticlesCompanion extends UpdateCompanion<CachedArticle> {
  final Value<String> url;
  final Value<String> title;
  final Value<String> sourceName;
  final Value<String?> sourceId;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<DateTime?> publishedAt;
  final Value<String?> content;
  final Value<int> rowid;
  const CachedArticlesCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedArticlesCompanion.insert({
    required String url,
    required String title,
    required String sourceName,
    this.sourceId = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       title = Value(title),
       sourceName = Value(sourceName);
  static Insertable<CachedArticle> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? sourceName,
    Expression<String>? sourceId,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<DateTime>? publishedAt,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceId != null) 'source_id': sourceId,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (publishedAt != null) 'published_at': publishedAt,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedArticlesCompanion copyWith({
    Value<String>? url,
    Value<String>? title,
    Value<String>? sourceName,
    Value<String?>? sourceId,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<DateTime?>? publishedAt,
    Value<String?>? content,
    Value<int>? rowid,
  }) {
    return CachedArticlesCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      sourceName: sourceName ?? this.sourceName,
      sourceId: sourceId ?? this.sourceId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedArticlesCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceId: $sourceId, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedEntriesTable extends FeedEntries
    with TableInfo<$FeedEntriesTable, FeedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleUrlMeta = const VerificationMeta(
    'articleUrl',
  );
  @override
  late final GeneratedColumn<String> articleUrl = GeneratedColumn<String>(
    'article_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_articles (url) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, page, position, articleUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('article_url')) {
      context.handle(
        _articleUrlMeta,
        articleUrl.isAcceptableOrUnknown(data['article_url']!, _articleUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_articleUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, page, position};
  @override
  FeedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedEntry(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      articleUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_url'],
      )!,
    );
  }

  @override
  $FeedEntriesTable createAlias(String alias) {
    return $FeedEntriesTable(attachedDatabase, alias);
  }
}

class FeedEntry extends DataClass implements Insertable<FeedEntry> {
  final String feedKey;
  final int page;
  final int position;
  final String articleUrl;
  const FeedEntry({
    required this.feedKey,
    required this.page,
    required this.position,
    required this.articleUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['page'] = Variable<int>(page);
    map['position'] = Variable<int>(position);
    map['article_url'] = Variable<String>(articleUrl);
    return map;
  }

  FeedEntriesCompanion toCompanion(bool nullToAbsent) {
    return FeedEntriesCompanion(
      feedKey: Value(feedKey),
      page: Value(page),
      position: Value(position),
      articleUrl: Value(articleUrl),
    );
  }

  factory FeedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedEntry(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      page: serializer.fromJson<int>(json['page']),
      position: serializer.fromJson<int>(json['position']),
      articleUrl: serializer.fromJson<String>(json['articleUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'page': serializer.toJson<int>(page),
      'position': serializer.toJson<int>(position),
      'articleUrl': serializer.toJson<String>(articleUrl),
    };
  }

  FeedEntry copyWith({
    String? feedKey,
    int? page,
    int? position,
    String? articleUrl,
  }) => FeedEntry(
    feedKey: feedKey ?? this.feedKey,
    page: page ?? this.page,
    position: position ?? this.position,
    articleUrl: articleUrl ?? this.articleUrl,
  );
  FeedEntry copyWithCompanion(FeedEntriesCompanion data) {
    return FeedEntry(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      page: data.page.present ? data.page.value : this.page,
      position: data.position.present ? data.position.value : this.position,
      articleUrl: data.articleUrl.present
          ? data.articleUrl.value
          : this.articleUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedEntry(')
          ..write('feedKey: $feedKey, ')
          ..write('page: $page, ')
          ..write('position: $position, ')
          ..write('articleUrl: $articleUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, page, position, articleUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedEntry &&
          other.feedKey == this.feedKey &&
          other.page == this.page &&
          other.position == this.position &&
          other.articleUrl == this.articleUrl);
}

class FeedEntriesCompanion extends UpdateCompanion<FeedEntry> {
  final Value<String> feedKey;
  final Value<int> page;
  final Value<int> position;
  final Value<String> articleUrl;
  final Value<int> rowid;
  const FeedEntriesCompanion({
    this.feedKey = const Value.absent(),
    this.page = const Value.absent(),
    this.position = const Value.absent(),
    this.articleUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedEntriesCompanion.insert({
    required String feedKey,
    required int page,
    required int position,
    required String articleUrl,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       page = Value(page),
       position = Value(position),
       articleUrl = Value(articleUrl);
  static Insertable<FeedEntry> custom({
    Expression<String>? feedKey,
    Expression<int>? page,
    Expression<int>? position,
    Expression<String>? articleUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (page != null) 'page': page,
      if (position != null) 'position': position,
      if (articleUrl != null) 'article_url': articleUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedEntriesCompanion copyWith({
    Value<String>? feedKey,
    Value<int>? page,
    Value<int>? position,
    Value<String>? articleUrl,
    Value<int>? rowid,
  }) {
    return FeedEntriesCompanion(
      feedKey: feedKey ?? this.feedKey,
      page: page ?? this.page,
      position: position ?? this.position,
      articleUrl: articleUrl ?? this.articleUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (articleUrl.present) {
      map['article_url'] = Variable<String>(articleUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedEntriesCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('page: $page, ')
          ..write('position: $position, ')
          ..write('articleUrl: $articleUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedPageMetadataTable extends FeedPageMetadata
    with TableInfo<$FeedPageMetadataTable, FeedPageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedPageMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalResultsMeta = const VerificationMeta(
    'totalResults',
  );
  @override
  late final GeneratedColumn<int> totalResults = GeneratedColumn<int>(
    'total_results',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasMoreMeta = const VerificationMeta(
    'hasMore',
  );
  @override
  late final GeneratedColumn<bool> hasMore = GeneratedColumn<bool>(
    'has_more',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_more" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    feedKey,
    page,
    fetchedAt,
    totalResults,
    hasMore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_page_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedPageMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('total_results')) {
      context.handle(
        _totalResultsMeta,
        totalResults.isAcceptableOrUnknown(
          data['total_results']!,
          _totalResultsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalResultsMeta);
    }
    if (data.containsKey('has_more')) {
      context.handle(
        _hasMoreMeta,
        hasMore.isAcceptableOrUnknown(data['has_more']!, _hasMoreMeta),
      );
    } else if (isInserting) {
      context.missing(_hasMoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, page};
  @override
  FeedPageMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedPageMetadataData(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      totalResults: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_results'],
      )!,
      hasMore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_more'],
      )!,
    );
  }

  @override
  $FeedPageMetadataTable createAlias(String alias) {
    return $FeedPageMetadataTable(attachedDatabase, alias);
  }
}

class FeedPageMetadataData extends DataClass
    implements Insertable<FeedPageMetadataData> {
  final String feedKey;
  final int page;

  /// When the page was retrieved from the remote source. Drives the TTL.
  final DateTime fetchedAt;
  final int totalResults;
  final bool hasMore;
  const FeedPageMetadataData({
    required this.feedKey,
    required this.page,
    required this.fetchedAt,
    required this.totalResults,
    required this.hasMore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['page'] = Variable<int>(page);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['total_results'] = Variable<int>(totalResults);
    map['has_more'] = Variable<bool>(hasMore);
    return map;
  }

  FeedPageMetadataCompanion toCompanion(bool nullToAbsent) {
    return FeedPageMetadataCompanion(
      feedKey: Value(feedKey),
      page: Value(page),
      fetchedAt: Value(fetchedAt),
      totalResults: Value(totalResults),
      hasMore: Value(hasMore),
    );
  }

  factory FeedPageMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedPageMetadataData(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      page: serializer.fromJson<int>(json['page']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      totalResults: serializer.fromJson<int>(json['totalResults']),
      hasMore: serializer.fromJson<bool>(json['hasMore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'page': serializer.toJson<int>(page),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'totalResults': serializer.toJson<int>(totalResults),
      'hasMore': serializer.toJson<bool>(hasMore),
    };
  }

  FeedPageMetadataData copyWith({
    String? feedKey,
    int? page,
    DateTime? fetchedAt,
    int? totalResults,
    bool? hasMore,
  }) => FeedPageMetadataData(
    feedKey: feedKey ?? this.feedKey,
    page: page ?? this.page,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    totalResults: totalResults ?? this.totalResults,
    hasMore: hasMore ?? this.hasMore,
  );
  FeedPageMetadataData copyWithCompanion(FeedPageMetadataCompanion data) {
    return FeedPageMetadataData(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      page: data.page.present ? data.page.value : this.page,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      totalResults: data.totalResults.present
          ? data.totalResults.value
          : this.totalResults,
      hasMore: data.hasMore.present ? data.hasMore.value : this.hasMore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedPageMetadataData(')
          ..write('feedKey: $feedKey, ')
          ..write('page: $page, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('totalResults: $totalResults, ')
          ..write('hasMore: $hasMore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(feedKey, page, fetchedAt, totalResults, hasMore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedPageMetadataData &&
          other.feedKey == this.feedKey &&
          other.page == this.page &&
          other.fetchedAt == this.fetchedAt &&
          other.totalResults == this.totalResults &&
          other.hasMore == this.hasMore);
}

class FeedPageMetadataCompanion extends UpdateCompanion<FeedPageMetadataData> {
  final Value<String> feedKey;
  final Value<int> page;
  final Value<DateTime> fetchedAt;
  final Value<int> totalResults;
  final Value<bool> hasMore;
  final Value<int> rowid;
  const FeedPageMetadataCompanion({
    this.feedKey = const Value.absent(),
    this.page = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.totalResults = const Value.absent(),
    this.hasMore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedPageMetadataCompanion.insert({
    required String feedKey,
    required int page,
    required DateTime fetchedAt,
    required int totalResults,
    required bool hasMore,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       page = Value(page),
       fetchedAt = Value(fetchedAt),
       totalResults = Value(totalResults),
       hasMore = Value(hasMore);
  static Insertable<FeedPageMetadataData> custom({
    Expression<String>? feedKey,
    Expression<int>? page,
    Expression<DateTime>? fetchedAt,
    Expression<int>? totalResults,
    Expression<bool>? hasMore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (page != null) 'page': page,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (totalResults != null) 'total_results': totalResults,
      if (hasMore != null) 'has_more': hasMore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedPageMetadataCompanion copyWith({
    Value<String>? feedKey,
    Value<int>? page,
    Value<DateTime>? fetchedAt,
    Value<int>? totalResults,
    Value<bool>? hasMore,
    Value<int>? rowid,
  }) {
    return FeedPageMetadataCompanion(
      feedKey: feedKey ?? this.feedKey,
      page: page ?? this.page,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      totalResults: totalResults ?? this.totalResults,
      hasMore: hasMore ?? this.hasMore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (totalResults.present) {
      map['total_results'] = Variable<int>(totalResults.value);
    }
    if (hasMore.present) {
      map['has_more'] = Variable<bool>(hasMore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedPageMetadataCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('page: $page, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('totalResults: $totalResults, ')
          ..write('hasMore: $hasMore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleUrlMeta = const VerificationMeta(
    'articleUrl',
  );
  @override
  late final GeneratedColumn<String> articleUrl = GeneratedColumn<String>(
    'article_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_articles (url) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [articleUrl, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_url')) {
      context.handle(
        _articleUrlMeta,
        articleUrl.isAcceptableOrUnknown(data['article_url']!, _articleUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_articleUrlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleUrl};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      articleUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String articleUrl;
  final DateTime createdAt;
  const Bookmark({required this.articleUrl, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_url'] = Variable<String>(articleUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      articleUrl: Value(articleUrl),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      articleUrl: serializer.fromJson<String>(json['articleUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleUrl': serializer.toJson<String>(articleUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({String? articleUrl, DateTime? createdAt}) => Bookmark(
    articleUrl: articleUrl ?? this.articleUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      articleUrl: data.articleUrl.present
          ? data.articleUrl.value
          : this.articleUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('articleUrl: $articleUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(articleUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.articleUrl == this.articleUrl &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> articleUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.articleUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String articleUrl,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : articleUrl = Value(articleUrl),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<String>? articleUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleUrl != null) 'article_url': articleUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? articleUrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      articleUrl: articleUrl ?? this.articleUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleUrl.present) {
      map['article_url'] = Variable<String>(articleUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('articleUrl: $articleUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingHistoryEntriesTable extends ReadingHistoryEntries
    with TableInfo<$ReadingHistoryEntriesTable, ReadingHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleUrlMeta = const VerificationMeta(
    'articleUrl',
  );
  @override
  late final GeneratedColumn<String> articleUrl = GeneratedColumn<String>(
    'article_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_articles (url) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _viewedAtMeta = const VerificationMeta(
    'viewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> viewedAt = GeneratedColumn<DateTime>(
    'viewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [articleUrl, viewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_url')) {
      context.handle(
        _articleUrlMeta,
        articleUrl.isAcceptableOrUnknown(data['article_url']!, _articleUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_articleUrlMeta);
    }
    if (data.containsKey('viewed_at')) {
      context.handle(
        _viewedAtMeta,
        viewedAt.isAcceptableOrUnknown(data['viewed_at']!, _viewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_viewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleUrl};
  @override
  ReadingHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingHistoryEntry(
      articleUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_url'],
      )!,
      viewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}viewed_at'],
      )!,
    );
  }

  @override
  $ReadingHistoryEntriesTable createAlias(String alias) {
    return $ReadingHistoryEntriesTable(attachedDatabase, alias);
  }
}

class ReadingHistoryEntry extends DataClass
    implements Insertable<ReadingHistoryEntry> {
  final String articleUrl;
  final DateTime viewedAt;
  const ReadingHistoryEntry({required this.articleUrl, required this.viewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_url'] = Variable<String>(articleUrl);
    map['viewed_at'] = Variable<DateTime>(viewedAt);
    return map;
  }

  ReadingHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReadingHistoryEntriesCompanion(
      articleUrl: Value(articleUrl),
      viewedAt: Value(viewedAt),
    );
  }

  factory ReadingHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingHistoryEntry(
      articleUrl: serializer.fromJson<String>(json['articleUrl']),
      viewedAt: serializer.fromJson<DateTime>(json['viewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleUrl': serializer.toJson<String>(articleUrl),
      'viewedAt': serializer.toJson<DateTime>(viewedAt),
    };
  }

  ReadingHistoryEntry copyWith({String? articleUrl, DateTime? viewedAt}) =>
      ReadingHistoryEntry(
        articleUrl: articleUrl ?? this.articleUrl,
        viewedAt: viewedAt ?? this.viewedAt,
      );
  ReadingHistoryEntry copyWithCompanion(ReadingHistoryEntriesCompanion data) {
    return ReadingHistoryEntry(
      articleUrl: data.articleUrl.present
          ? data.articleUrl.value
          : this.articleUrl,
      viewedAt: data.viewedAt.present ? data.viewedAt.value : this.viewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryEntry(')
          ..write('articleUrl: $articleUrl, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(articleUrl, viewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingHistoryEntry &&
          other.articleUrl == this.articleUrl &&
          other.viewedAt == this.viewedAt);
}

class ReadingHistoryEntriesCompanion
    extends UpdateCompanion<ReadingHistoryEntry> {
  final Value<String> articleUrl;
  final Value<DateTime> viewedAt;
  final Value<int> rowid;
  const ReadingHistoryEntriesCompanion({
    this.articleUrl = const Value.absent(),
    this.viewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingHistoryEntriesCompanion.insert({
    required String articleUrl,
    required DateTime viewedAt,
    this.rowid = const Value.absent(),
  }) : articleUrl = Value(articleUrl),
       viewedAt = Value(viewedAt);
  static Insertable<ReadingHistoryEntry> custom({
    Expression<String>? articleUrl,
    Expression<DateTime>? viewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleUrl != null) 'article_url': articleUrl,
      if (viewedAt != null) 'viewed_at': viewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingHistoryEntriesCompanion copyWith({
    Value<String>? articleUrl,
    Value<DateTime>? viewedAt,
    Value<int>? rowid,
  }) {
    return ReadingHistoryEntriesCompanion(
      articleUrl: articleUrl ?? this.articleUrl,
      viewedAt: viewedAt ?? this.viewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleUrl.present) {
      map['article_url'] = Variable<String>(articleUrl.value);
    }
    if (viewedAt.present) {
      map['viewed_at'] = Variable<DateTime>(viewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryEntriesCompanion(')
          ..write('articleUrl: $articleUrl, ')
          ..write('viewedAt: $viewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final String query;
  final DateTime searchedAt;
  const RecentSearche({required this.query, required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearche copyWith({String? query, DateTime? searchedAt}) =>
      RecentSearche(
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<String> query;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String query,
    required DateTime searchedAt,
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearche> custom({
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<String>? query,
    Value<DateTime>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedArticlesTable cachedArticles = $CachedArticlesTable(this);
  late final $FeedEntriesTable feedEntries = $FeedEntriesTable(this);
  late final $FeedPageMetadataTable feedPageMetadata = $FeedPageMetadataTable(
    this,
  );
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ReadingHistoryEntriesTable readingHistoryEntries =
      $ReadingHistoryEntriesTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedArticles,
    feedEntries,
    feedPageMetadata,
    bookmarks,
    readingHistoryEntries,
    recentSearches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feed_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_history_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CachedArticlesTableCreateCompanionBuilder =
    CachedArticlesCompanion Function({
      required String url,
      required String title,
      required String sourceName,
      Value<String?> sourceId,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<DateTime?> publishedAt,
      Value<String?> content,
      Value<int> rowid,
    });
typedef $$CachedArticlesTableUpdateCompanionBuilder =
    CachedArticlesCompanion Function({
      Value<String> url,
      Value<String> title,
      Value<String> sourceName,
      Value<String?> sourceId,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<DateTime?> publishedAt,
      Value<String?> content,
      Value<int> rowid,
    });

final class $$CachedArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $CachedArticlesTable, CachedArticle> {
  $$CachedArticlesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FeedEntriesTable, List<FeedEntry>>
  _feedEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedEntries,
    aliasName: 'cached_articles__url__feed_entries__article_url',
  );

  $$FeedEntriesTableProcessedTableManager get feedEntriesRefs {
    final manager = $$FeedEntriesTableTableManager(
      $_db,
      $_db.feedEntries,
    ).filter((f) => f.articleUrl.url.sqlEquals($_itemColumn<String>('url')!));

    final cache = $_typedResult.readTableOrNull(_feedEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'cached_articles__url__bookmarks__article_url',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.articleUrl.url.sqlEquals($_itemColumn<String>('url')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReadingHistoryEntriesTable,
    List<ReadingHistoryEntry>
  >
  _readingHistoryEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readingHistoryEntries,
        aliasName: 'cached_articles__url__reading_history_entries__article_url',
      );

  $$ReadingHistoryEntriesTableProcessedTableManager
  get readingHistoryEntriesRefs {
    final manager = $$ReadingHistoryEntriesTableTableManager(
      $_db,
      $_db.readingHistoryEntries,
    ).filter((f) => f.articleUrl.url.sqlEquals($_itemColumn<String>('url')!));

    final cache = $_typedResult.readTableOrNull(
      _readingHistoryEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> feedEntriesRefs(
    Expression<bool> Function($$FeedEntriesTableFilterComposer f) f,
  ) {
    final $$FeedEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.feedEntries,
      getReferencedColumn: (t) => t.articleUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedEntriesTableFilterComposer(
            $db: $db,
            $table: $db.feedEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingHistoryEntriesRefs(
    Expression<bool> Function($$ReadingHistoryEntriesTableFilterComposer f) f,
  ) {
    final $$ReadingHistoryEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.url,
          referencedTable: $db.readingHistoryEntries,
          getReferencedColumn: (t) => t.articleUrl,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingHistoryEntriesTableFilterComposer(
                $db: $db,
                $table: $db.readingHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedArticlesTable> {
  $$CachedArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  Expression<T> feedEntriesRefs<T extends Object>(
    Expression<T> Function($$FeedEntriesTableAnnotationComposer a) f,
  ) {
    final $$FeedEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.feedEntries,
      getReferencedColumn: (t) => t.articleUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.feedEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleUrl,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingHistoryEntriesRefs<T extends Object>(
    Expression<T> Function($$ReadingHistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$ReadingHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.url,
          referencedTable: $db.readingHistoryEntries,
          getReferencedColumn: (t) => t.articleUrl,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.readingHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedArticlesTable,
          CachedArticle,
          $$CachedArticlesTableFilterComposer,
          $$CachedArticlesTableOrderingComposer,
          $$CachedArticlesTableAnnotationComposer,
          $$CachedArticlesTableCreateCompanionBuilder,
          $$CachedArticlesTableUpdateCompanionBuilder,
          (CachedArticle, $$CachedArticlesTableReferences),
          CachedArticle,
          PrefetchHooks Function({
            bool feedEntriesRefs,
            bool bookmarksRefs,
            bool readingHistoryEntriesRefs,
          })
        > {
  $$CachedArticlesTableTableManager(
    _$AppDatabase db,
    $CachedArticlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedArticlesCompanion(
                url: url,
                title: title,
                sourceName: sourceName,
                sourceId: sourceId,
                description: description,
                imageUrl: imageUrl,
                publishedAt: publishedAt,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required String title,
                required String sourceName,
                Value<String?> sourceId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedArticlesCompanion.insert(
                url: url,
                title: title,
                sourceName: sourceName,
                sourceId: sourceId,
                description: description,
                imageUrl: imageUrl,
                publishedAt: publishedAt,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedArticlesTable, CachedArticle>(table),
                  $$CachedArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                feedEntriesRefs = false,
                bookmarksRefs = false,
                readingHistoryEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (feedEntriesRefs) db.feedEntries,
                    if (bookmarksRefs) db.bookmarks,
                    if (readingHistoryEntriesRefs) db.readingHistoryEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (feedEntriesRefs)
                        await $_getPrefetchedData<
                          CachedArticle,
                          $CachedArticlesTable,
                          FeedEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CachedArticlesTableReferences
                              ._feedEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).feedEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleUrl == item.url,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          CachedArticle,
                          $CachedArticlesTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$CachedArticlesTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleUrl == item.url,
                              ),
                          typedResults: items,
                        ),
                      if (readingHistoryEntriesRefs)
                        await $_getPrefetchedData<
                          CachedArticle,
                          $CachedArticlesTable,
                          ReadingHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CachedArticlesTableReferences
                              ._readingHistoryEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).readingHistoryEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleUrl == item.url,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CachedArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedArticlesTable,
      CachedArticle,
      $$CachedArticlesTableFilterComposer,
      $$CachedArticlesTableOrderingComposer,
      $$CachedArticlesTableAnnotationComposer,
      $$CachedArticlesTableCreateCompanionBuilder,
      $$CachedArticlesTableUpdateCompanionBuilder,
      (CachedArticle, $$CachedArticlesTableReferences),
      CachedArticle,
      PrefetchHooks Function({
        bool feedEntriesRefs,
        bool bookmarksRefs,
        bool readingHistoryEntriesRefs,
      })
    >;
typedef $$FeedEntriesTableCreateCompanionBuilder =
    FeedEntriesCompanion Function({
      required String feedKey,
      required int page,
      required int position,
      required String articleUrl,
      Value<int> rowid,
    });
typedef $$FeedEntriesTableUpdateCompanionBuilder =
    FeedEntriesCompanion Function({
      Value<String> feedKey,
      Value<int> page,
      Value<int> position,
      Value<String> articleUrl,
      Value<int> rowid,
    });

final class $$FeedEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FeedEntriesTable, FeedEntry> {
  $$FeedEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CachedArticlesTable _articleUrlTable(_$AppDatabase db) => db
      .cachedArticles
      .createAlias('feed_entries__article_url__cached_articles__url');

  $$CachedArticlesTableProcessedTableManager get articleUrl {
    final $_column = $_itemColumn<String>('article_url')!;

    final manager = $$CachedArticlesTableTableManager(
      $_db,
      $_db.cachedArticles,
    ).filter((f) => f.url.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedArticlesTableFilterComposer get articleUrl {
    final $$CachedArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableFilterComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedArticlesTableOrderingComposer get articleUrl {
    final $$CachedArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$CachedArticlesTableAnnotationComposer get articleUrl {
    final $$CachedArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedEntriesTable,
          FeedEntry,
          $$FeedEntriesTableFilterComposer,
          $$FeedEntriesTableOrderingComposer,
          $$FeedEntriesTableAnnotationComposer,
          $$FeedEntriesTableCreateCompanionBuilder,
          $$FeedEntriesTableUpdateCompanionBuilder,
          (FeedEntry, $$FeedEntriesTableReferences),
          FeedEntry,
          PrefetchHooks Function({bool articleUrl})
        > {
  $$FeedEntriesTableTableManager(_$AppDatabase db, $FeedEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> articleUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedEntriesCompanion(
                feedKey: feedKey,
                page: page,
                position: position,
                articleUrl: articleUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required int page,
                required int position,
                required String articleUrl,
                Value<int> rowid = const Value.absent(),
              }) => FeedEntriesCompanion.insert(
                feedKey: feedKey,
                page: page,
                position: position,
                articleUrl: articleUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedEntriesTable, FeedEntry>(table),
                  $$FeedEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleUrl = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleUrl) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleUrl,
                                referencedTable: $$FeedEntriesTableReferences
                                    ._articleUrlTable(db),
                                referencedColumn: $$FeedEntriesTableReferences
                                    ._articleUrlTable(db)
                                    .url,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedEntriesTable,
      FeedEntry,
      $$FeedEntriesTableFilterComposer,
      $$FeedEntriesTableOrderingComposer,
      $$FeedEntriesTableAnnotationComposer,
      $$FeedEntriesTableCreateCompanionBuilder,
      $$FeedEntriesTableUpdateCompanionBuilder,
      (FeedEntry, $$FeedEntriesTableReferences),
      FeedEntry,
      PrefetchHooks Function({bool articleUrl})
    >;
typedef $$FeedPageMetadataTableCreateCompanionBuilder =
    FeedPageMetadataCompanion Function({
      required String feedKey,
      required int page,
      required DateTime fetchedAt,
      required int totalResults,
      required bool hasMore,
      Value<int> rowid,
    });
typedef $$FeedPageMetadataTableUpdateCompanionBuilder =
    FeedPageMetadataCompanion Function({
      Value<String> feedKey,
      Value<int> page,
      Value<DateTime> fetchedAt,
      Value<int> totalResults,
      Value<bool> hasMore,
      Value<int> rowid,
    });

class $$FeedPageMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $FeedPageMetadataTable> {
  $$FeedPageMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalResults => $composableBuilder(
    column: $table.totalResults,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedPageMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedPageMetadataTable> {
  $$FeedPageMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalResults => $composableBuilder(
    column: $table.totalResults,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedPageMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedPageMetadataTable> {
  $$FeedPageMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get totalResults => $composableBuilder(
    column: $table.totalResults,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasMore =>
      $composableBuilder(column: $table.hasMore, builder: (column) => column);
}

class $$FeedPageMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedPageMetadataTable,
          FeedPageMetadataData,
          $$FeedPageMetadataTableFilterComposer,
          $$FeedPageMetadataTableOrderingComposer,
          $$FeedPageMetadataTableAnnotationComposer,
          $$FeedPageMetadataTableCreateCompanionBuilder,
          $$FeedPageMetadataTableUpdateCompanionBuilder,
          (
            FeedPageMetadataData,
            BaseReferences<
              _$AppDatabase,
              $FeedPageMetadataTable,
              FeedPageMetadataData
            >,
          ),
          FeedPageMetadataData,
          PrefetchHooks Function()
        > {
  $$FeedPageMetadataTableTableManager(
    _$AppDatabase db,
    $FeedPageMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedPageMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedPageMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedPageMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> totalResults = const Value.absent(),
                Value<bool> hasMore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedPageMetadataCompanion(
                feedKey: feedKey,
                page: page,
                fetchedAt: fetchedAt,
                totalResults: totalResults,
                hasMore: hasMore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required int page,
                required DateTime fetchedAt,
                required int totalResults,
                required bool hasMore,
                Value<int> rowid = const Value.absent(),
              }) => FeedPageMetadataCompanion.insert(
                feedKey: feedKey,
                page: page,
                fetchedAt: fetchedAt,
                totalResults: totalResults,
                hasMore: hasMore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedPageMetadataTable, FeedPageMetadataData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $FeedPageMetadataTable,
                    FeedPageMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedPageMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedPageMetadataTable,
      FeedPageMetadataData,
      $$FeedPageMetadataTableFilterComposer,
      $$FeedPageMetadataTableOrderingComposer,
      $$FeedPageMetadataTableAnnotationComposer,
      $$FeedPageMetadataTableCreateCompanionBuilder,
      $$FeedPageMetadataTableUpdateCompanionBuilder,
      (
        FeedPageMetadataData,
        BaseReferences<
          _$AppDatabase,
          $FeedPageMetadataTable,
          FeedPageMetadataData
        >,
      ),
      FeedPageMetadataData,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String articleUrl,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> articleUrl,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CachedArticlesTable _articleUrlTable(_$AppDatabase db) => db
      .cachedArticles
      .createAlias('bookmarks__article_url__cached_articles__url');

  $$CachedArticlesTableProcessedTableManager get articleUrl {
    final $_column = $_itemColumn<String>('article_url')!;

    final manager = $$CachedArticlesTableTableManager(
      $_db,
      $_db.cachedArticles,
    ).filter((f) => f.url.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedArticlesTableFilterComposer get articleUrl {
    final $$CachedArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableFilterComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedArticlesTableOrderingComposer get articleUrl {
    final $$CachedArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CachedArticlesTableAnnotationComposer get articleUrl {
    final $$CachedArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool articleUrl})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> articleUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                articleUrl: articleUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String articleUrl,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                articleUrl: articleUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, Bookmark>(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleUrl = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleUrl) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleUrl,
                                referencedTable: $$BookmarksTableReferences
                                    ._articleUrlTable(db),
                                referencedColumn: $$BookmarksTableReferences
                                    ._articleUrlTable(db)
                                    .url,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool articleUrl})
    >;
typedef $$ReadingHistoryEntriesTableCreateCompanionBuilder =
    ReadingHistoryEntriesCompanion Function({
      required String articleUrl,
      required DateTime viewedAt,
      Value<int> rowid,
    });
typedef $$ReadingHistoryEntriesTableUpdateCompanionBuilder =
    ReadingHistoryEntriesCompanion Function({
      Value<String> articleUrl,
      Value<DateTime> viewedAt,
      Value<int> rowid,
    });

final class $$ReadingHistoryEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReadingHistoryEntriesTable,
          ReadingHistoryEntry
        > {
  $$ReadingHistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedArticlesTable _articleUrlTable(_$AppDatabase db) =>
      db.cachedArticles.createAlias(
        'reading_history_entries__article_url__cached_articles__url',
      );

  $$CachedArticlesTableProcessedTableManager get articleUrl {
    final $_column = $_itemColumn<String>('article_url')!;

    final manager = $$CachedArticlesTableTableManager(
      $_db,
      $_db.cachedArticles,
    ).filter((f) => f.url.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingHistoryEntriesTable> {
  $$ReadingHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedArticlesTableFilterComposer get articleUrl {
    final $$CachedArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableFilterComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingHistoryEntriesTable> {
  $$ReadingHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedArticlesTableOrderingComposer get articleUrl {
    final $$CachedArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingHistoryEntriesTable> {
  $$ReadingHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get viewedAt =>
      $composableBuilder(column: $table.viewedAt, builder: (column) => column);

  $$CachedArticlesTableAnnotationComposer get articleUrl {
    final $$CachedArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleUrl,
      referencedTable: $db.cachedArticles,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedArticles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingHistoryEntriesTable,
          ReadingHistoryEntry,
          $$ReadingHistoryEntriesTableFilterComposer,
          $$ReadingHistoryEntriesTableOrderingComposer,
          $$ReadingHistoryEntriesTableAnnotationComposer,
          $$ReadingHistoryEntriesTableCreateCompanionBuilder,
          $$ReadingHistoryEntriesTableUpdateCompanionBuilder,
          (ReadingHistoryEntry, $$ReadingHistoryEntriesTableReferences),
          ReadingHistoryEntry,
          PrefetchHooks Function({bool articleUrl})
        > {
  $$ReadingHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $ReadingHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingHistoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReadingHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> articleUrl = const Value.absent(),
                Value<DateTime> viewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingHistoryEntriesCompanion(
                articleUrl: articleUrl,
                viewedAt: viewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String articleUrl,
                required DateTime viewedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingHistoryEntriesCompanion.insert(
                articleUrl: articleUrl,
                viewedAt: viewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingHistoryEntriesTable, ReadingHistoryEntry>(
                    table,
                  ),
                  $$ReadingHistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleUrl = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleUrl) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleUrl,
                                referencedTable:
                                    $$ReadingHistoryEntriesTableReferences
                                        ._articleUrlTable(db),
                                referencedColumn:
                                    $$ReadingHistoryEntriesTableReferences
                                        ._articleUrlTable(db)
                                        .url,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingHistoryEntriesTable,
      ReadingHistoryEntry,
      $$ReadingHistoryEntriesTableFilterComposer,
      $$ReadingHistoryEntriesTableOrderingComposer,
      $$ReadingHistoryEntriesTableAnnotationComposer,
      $$ReadingHistoryEntriesTableCreateCompanionBuilder,
      $$ReadingHistoryEntriesTableUpdateCompanionBuilder,
      (ReadingHistoryEntry, $$ReadingHistoryEntriesTableReferences),
      ReadingHistoryEntry,
      PrefetchHooks Function({bool articleUrl})
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required String query,
      required DateTime searchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<String> query,
      Value<DateTime> searchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearche,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearche,
            BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
          ),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                query: query,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String query,
                required DateTime searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                query: query,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearche>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearche
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearche,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearche,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
      ),
      RecentSearche,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedArticlesTableTableManager get cachedArticles =>
      $$CachedArticlesTableTableManager(_db, _db.cachedArticles);
  $$FeedEntriesTableTableManager get feedEntries =>
      $$FeedEntriesTableTableManager(_db, _db.feedEntries);
  $$FeedPageMetadataTableTableManager get feedPageMetadata =>
      $$FeedPageMetadataTableTableManager(_db, _db.feedPageMetadata);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ReadingHistoryEntriesTableTableManager get readingHistoryEntries =>
      $$ReadingHistoryEntriesTableTableManager(_db, _db.readingHistoryEntries);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
}
