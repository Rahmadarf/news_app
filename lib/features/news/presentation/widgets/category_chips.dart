import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Localized display label for a category.
String categoryLabel(AppLocalizations l10n, NewsCategory category) {
  return switch (category) {
    NewsCategory.general => l10n.categoryGeneral,
    NewsCategory.technology => l10n.categoryTechnology,
    NewsCategory.business => l10n.categoryBusiness,
    NewsCategory.sports => l10n.categorySports,
    NewsCategory.health => l10n.categoryHealth,
    NewsCategory.science => l10n.categoryScience,
    NewsCategory.entertainment => l10n.categoryEntertainment,
  };
}

/// Horizontally scrolling pill filter above "Recent stories".
///
/// The selected pill is filled with the accent; the rest are outlined with the
/// hairline. Each pill is at least 48dp tall so it is comfortably tappable.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

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
        itemCount: NewsCategory.values.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final NewsCategory category = NewsCategory.values[index];
          final bool isSelected = category == selected;

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
                  onTap: () => onSelected(category),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm,
                    ),
                    child: Text(
                      categoryLabel(l10n, category),
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
