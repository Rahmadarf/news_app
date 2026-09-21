/// The headline categories the app offers.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
/// [apiValue] is the wire spelling; [label] is an English display default that
/// localization replaces later.
enum NewsCategory {
  general('general', 'General'),
  technology('technology', 'Technology'),
  business('business', 'Business'),
  sports('sports', 'Sports'),
  health('health', 'Health'),
  science('science', 'Science'),
  entertainment('entertainment', 'Entertainment');

  const NewsCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static const NewsCategory fallback = NewsCategory.general;

  /// Returns [fallback] rather than throwing, so a stale persisted value or a
  /// hand-edited deep link cannot crash startup.
  static NewsCategory fromApiValue(String? value) {
    if (value == null) return fallback;
    for (final NewsCategory category in NewsCategory.values) {
      if (category.apiValue == value) return category;
    }
    return fallback;
  }
}
