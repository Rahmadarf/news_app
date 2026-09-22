import 'package:flutter/material.dart';
import 'package:news_app/core/errors/failure.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/core/widgets/status_views.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Paginated article list shared by the search results screen and any other
/// flat list of stories.
///
/// Requests the next page when the user nears the end, and renders a trailing
/// footer for the paginating and page-failure conditions so the existing list
/// is never replaced by a spinner.
class ArticleListView extends StatefulWidget {
  const ArticleListView({
    super.key,
    required this.articles,
    required this.onArticleTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.pageFailure,
    this.header,
  });

  final List<Article> articles;
  final ValueChanged<Article> onArticleTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final Failure? pageFailure;

  /// Optional banner pinned above the first row, e.g. the offline notice.
  final Widget? header;

  @override
  State<ArticleListView> createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    if (widget.onLoadMore == null || !widget.hasMore) return;
    if (widget.isLoadingMore || widget.pageFailure != null) return;

    final double remaining =
        _controller.position.maxScrollExtent - _controller.position.pixels;
    if (remaining < 400) widget.onLoadMore!();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHeader = widget.header != null;
    final bool hasFooter =
        widget.isLoadingMore || widget.pageFailure != null || widget.hasMore;

    final int headerCount = hasHeader ? 1 : 0;
    final int footerCount = hasFooter ? 1 : 0;

    return ListView.builder(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      itemCount: widget.articles.length + headerCount + footerCount,
      itemBuilder: (BuildContext context, int index) {
        if (hasHeader && index == 0) return widget.header!;

        final int articleIndex = index - headerCount;
        if (articleIndex < widget.articles.length) {
          final Article article = widget.articles[articleIndex];
          return ArticleRow(
            article: article,
            showDivider: articleIndex != widget.articles.length - 1,
            onTap: () => widget.onArticleTap(article),
          );
        }

        return _Footer(
          isLoadingMore: widget.isLoadingMore,
          pageFailure: widget.pageFailure,
          onRetry: widget.onLoadMore,
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isLoadingMore,
    required this.pageFailure,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final Failure? pageFailure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Failure? failure = pageFailure;

    if (failure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: Column(
          children: <Widget>[
            Text(
              describeFailure(l10n, failure).title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            if (onRetry != null)
              OutlinedButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      );
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.xl),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return const SizedBox(height: Spacing.xl);
  }
}
