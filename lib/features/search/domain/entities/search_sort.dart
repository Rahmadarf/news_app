/// Ordering options offered by the search screen.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
/// [apiValue] is the wire spelling NewsAPI's `sortBy` parameter expects.
enum SearchSort {
  relevancy('relevancy'),
  newest('publishedAt'),
  popularity('popularity');

  const SearchSort(this.apiValue);

  final String apiValue;

  static const SearchSort fallback = SearchSort.relevancy;

  /// Returns [fallback] rather than throwing, so a stale persisted value
  /// cannot break the screen.
  static SearchSort fromApiValue(String? value) {
    for (final SearchSort sort in SearchSort.values) {
      if (sort.apiValue == value) return sort;
    }
    return fallback;
  }
}
