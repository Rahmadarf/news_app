import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/search/domain/entities/search_sort.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Localized label for a sort option.
String sortLabel(AppLocalizations l10n, SearchSort sort) {
  return switch (sort) {
    SearchSort.relevancy => l10n.sortRelevancy,
    SearchSort.newest => l10n.sortNewest,
    SearchSort.popularity => l10n.sortPopularity,
  };
}

/// Pill row that chooses the result ordering.
///
/// Shares the chip treatment used by the Home category filter, so the two
/// controls read as one family.
class SortSelector extends StatelessWidget {
  const SortSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SearchSort selected;
  final ValueChanged<SearchSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return SizedBox(
      height: Dimens.minTapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
        itemCount: SearchSort.values.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final SearchSort sort = SearchSort.values[index];
          final bool isSelected = sort == selected;

          return Center(
            child: Semantics(
              selected: isSelected,
              button: true,
              child: Material(
                color: isSelected ? tokens.filledControl : Colors.transparent,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? tokens.filledControl : tokens.hairline,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelected(sort),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm,
                    ),
                    child: Text(
                      sortLabel(l10n, sort),
                      style: text.labelSmall?.copyWith(
                        color: isSelected
                            ? tokens.onFilledControl
                            : tokens.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
