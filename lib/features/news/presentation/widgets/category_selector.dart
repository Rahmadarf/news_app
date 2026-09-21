import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';

/// Horizontal category strip.
///
/// Presentational only: it receives the selection and reports taps, so the
/// whole strip rebuilds once per change instead of holding one subscription
/// per chip.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: NewsCategory.values.length,
        itemBuilder: (BuildContext context, int index) {
          final NewsCategory category = NewsCategory.values[index];
          return _CategoryChip(
            label: category.label,
            isSelected: category == selected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
