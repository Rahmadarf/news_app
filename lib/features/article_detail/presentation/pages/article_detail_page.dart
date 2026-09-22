import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/app/routing/app_routes.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/utils/relative_time.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/article_detail/presentation/article_actions.dart';
import 'package:news_app/features/article_detail/presentation/controllers/cached_article_provider.dart';
import 'package:news_app/features/article_detail/presentation/read_time.dart';
import 'package:news_app/features/article_detail/presentation/widgets/article_body.dart';
import 'package:news_app/features/article_detail/presentation/widgets/reading_controls.dart';
import 'package:news_app/core/widgets/confirm_dialog.dart';
import 'package:news_app/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:news_app/features/bookmarks/presentation/controllers/bookmark_providers.dart';
import 'package:news_app/features/bookmarks/presentation/widgets/bookmark_button.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/controllers/news_feed_controller.dart';
import 'package:news_app/features/news/presentation/state/news_feed_state.dart';
import 'package:news_app/features/news/presentation/widgets/article_photo.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/news/presentation/widgets/section_header.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Article reader.
///
/// [article] is the fast path handed over by the list. It is absent after a
/// deep link, a hot restart, or a browser reload, which is why [articleUrl] is
/// also carried in the route. Nothing here casts a route argument; when no
/// object arrives the screen looks the article up in the local cache, and
/// falls back to an explanatory state rather than crashing. See
/// docs/AUDIT.md H-10.
class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({
    super.key,
    this.article,
    this.articleUrl,
    this.category,
  });

  final Article? article;
  final String? articleUrl;

  /// Category the reader opened the article from, when known. Absent on a deep
  /// link, in which case the eyebrow simply omits it.
  final NewsCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Article? handedOver = article;
    if (handedOver != null) {
      return _Reader(article: handedOver, category: category);
    }

    final String? url = articleUrl;
    if (url == null) {
      return const _Unavailable(canOpenInBrowser: false);
    }

    return ref
        .watch(cachedArticleProvider(url))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (Object error, StackTrace stackTrace) =>
              _Unavailable(articleUrl: url),
          data: (Article? cached) => cached != null
              ? _Reader(article: cached, category: category)
              : _Unavailable(articleUrl: url),
        );
  }
}

class _Reader extends ConsumerStatefulWidget {
  const _Reader({required this.article, this.category});

  final Article article;
  final NewsCategory? category;

  @override
  ConsumerState<_Reader> createState() => _ReaderState();
}

class _ReaderState extends ConsumerState<_Reader> {
  @override
  void initState() {
    super.initState();
    // Opening an article is what puts it at the top of reading history. Done
    // once per screen, not on every rebuild, and best effort: a storage
    // problem must not interrupt reading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(readingHistoryRepositoryProvider)
          .record(widget.article)
          .catchError((Object _) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Article article = widget.article;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);
    final double readerScale = ref.watch(readingTextScaleProvider);
    final bool usingMockData =
        ref.watch(appConfigProvider).dataSourceMode == NewsDataSourceMode.mock;
    final List<String> paragraphs = _bodyParagraphs(article);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _DetailAppBar(article: article),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.lg,
              Spacing.gutter,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _Eyebrow(
                  category: widget.category,
                  readMinutes: estimatedReadMinutes(article),
                ),
                const SizedBox(height: Spacing.md),
                Text(article.title, style: theme.textTheme.displaySmall),
                const SizedBox(height: Spacing.md),
                _SourceLine(article: article),
                ReadingControls(dateLabel: _absoluteDate(context, article)),
                if (article.description != null)
                  Text(article.description!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: Spacing.gutter),
                if (paragraphs.isNotEmpty)
                  ArticleBody(paragraphs: paragraphs, readerScale: readerScale),
                if (usingMockData) ...<Widget>[
                  Text(
                    l10n.sampleDataNotice,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
                Text(
                  l10n.truncatedContentNotice,
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: Spacing.lg),
                ElevatedButton(
                  onPressed: () =>
                      ArticleActions.openInBrowser(context, article.url),
                  child: Text('${l10n.readFullArticle} ↗'),
                ),
              ]),
            ),
          ),
          _RelatedStories(current: article, category: widget.category),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)),
        ],
      ),
    );
  }

  static List<String> _bodyParagraphs(Article article) {
    final String? content = article.content;
    if (content == null) return const <String>[];
    return content
        .split(RegExp(r'\n{2,}'))
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList(growable: false);
  }

  static String? _absoluteDate(BuildContext context, Article article) {
    final DateTime? publishedAt = article.publishedAt;
    if (publishedAt == null) return null;
    return formatAbsoluteDate(
      publishedAt,
      Localizations.localeOf(context).toString(),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.category, required this.readMinutes});

  final NewsCategory? category;
  final int? readMinutes;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    final List<String> parts = <String>[
      if (category != null) category!.label.toUpperCase(),
      if (readMinutes != null) l10n.readMinutes(readMinutes!).toUpperCase(),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  ·  '),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: tokens.accent,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);
    final DateTime? publishedAt = article.publishedAt;

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: tokens.tintedSurface,
            borderRadius: BorderRadius.circular(Radii.badge),
          ),
          child: Text(
            article.source.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tokens.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (publishedAt != null) ...<Widget>[
          const SizedBox(width: Spacing.md),
          Flexible(
            child: Text(
              formatRelativeTime(
                publishedAt,
                Localizations.localeOf(context).languageCode,
              ),
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailAppBar extends ConsumerWidget {
  const _DetailAppBar({required this.article});

  final Article article;

  /// Hero height from the design: taller on a narrow phone layout.
  static const double heroHeight = 237;
  static const double narrowHeroHeight = 260;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final double height = width < 420 ? narrowHeroHeight : heroHeight;

    return SliverAppBar(
      expandedHeight: height,
      pinned: true,
      leading: BackButton(onPressed: () => goBack(context)),
      flexibleSpace: FlexibleSpaceBar(
        background: ArticlePhoto(
          url: article.imageUrl,
          height: height,
          radius: 0,
        ),
      ),
      actions: <Widget>[
        BookmarkButton(article: article),
        IconButton(
          onPressed: () => ArticleActions.share(article),
          tooltip: l10n.shareArticle,
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          onPressed: () => _showOptions(context, ref, article),
          tooltip: l10n.articleOptions,
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }

  /// Returns to wherever the reader came from, falling back to the feed so a
  /// deep link never leaves them on a dead end.
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.feedPath);
    }
  }

  static Future<void> _showOptions(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isSaved =
        ref.read(savedArticleUrlsProvider).value?.contains(article.url) ??
        false;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Filing only makes sense for an article that is already saved.
            if (isSaved)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(l10n.saveToCollection),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _chooseCollection(context, ref, article);
                },
              ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.copyLink),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ArticleActions.copyLink(context, article.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: Text(l10n.openInBrowser),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ArticleActions.openInBrowser(context, article.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.shareArticle),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ArticleActions.share(article);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Files a saved article into one of the reader's collections.
  ///
  /// Offers an escape hatch when there are no collections yet, rather than an
  /// empty sheet.
  static Future<void> _chooseCollection(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BookmarkRepository repository = ref.read(bookmarkRepositoryProvider);
    final List<String> collections =
        ref.read(collectionsProvider).value ?? const <String>[];

    if (collections.isEmpty) {
      final String? name = await promptForName(
        context,
        title: l10n.newCollection,
        hint: l10n.collectionNameHint,
        confirmLabel: l10n.createAction,
      );
      if (name == null) return;
      await repository.createCollection(name);
      await repository.assignToCollection(article.url, name.trim());
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.gutter,
                vertical: Spacing.sm,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.saveToCollection,
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.noCollection),
              onTap: () {
                Navigator.of(sheetContext).pop();
                repository.assignToCollection(article.url, null);
              },
            ),
            for (final String name in collections)
              ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  repository.assignToCollection(article.url, name);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Two more stories from the same feed, excluding the one being read.
///
/// Reads the already-loaded category feed rather than issuing another request.
class _RelatedStories extends ConsumerWidget {
  const _RelatedStories({required this.current, this.category});

  final Article current;
  final NewsCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewsCategory effective = category ?? NewsCategory.fallback;
    final NewsFeedState state = ref.watch(
      newsFeedControllerProvider(effective),
    );

    final List<Article> related = state is NewsFeedReady
        ? state.articles
              .where((Article a) => a.url != current.url)
              .take(2)
              .toList()
        : const <Article>[];

    if (related.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        SectionHeader(title: l10n.relatedStoriesTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < related.length; i++)
                ArticleRow(
                  article: related[i],
                  showDivider: i != related.length - 1,
                  onTap: () => context.push(
                    AppRoutes.article(related[i].url, category: effective),
                    extra: related[i],
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({this.articleUrl, this.canOpenInBrowser = true});

  final String? articleUrl;
  final bool canOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? url = articleUrl;
    final bool offerBrowser = url != null && canOpenInBrowser;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: StatusView(
          icon: Icons.article_outlined,
          title: l10n.articleUnavailableTitle,
          message: url == null
              ? l10n.articleUnavailableNoLink
              : l10n.articleUnavailableBody,
          actionLabel: offerBrowser ? l10n.openInBrowser : null,
          onAction: offerBrowser
              ? () => ArticleActions.openInBrowser(context, url)
              : null,
        ),
      ),
    );
  }
}
