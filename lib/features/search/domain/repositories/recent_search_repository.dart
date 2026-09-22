/// Recently submitted search terms.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
abstract interface class RecentSearchRepository {
  /// Most recent first, capped at [maxEntries].
  ///
  /// A stream so the list updates the moment a term is recorded or cleared.
  Stream<List<String>> watchRecent();

  /// Records [query], moving it to the top if it was already present.
  ///
  /// Only submitted queries are recorded; keystrokes are not.
  Future<void> record(String query);

  Future<void> remove(String query);

  Future<void> clear();

  /// How many terms are retained. Matches the approved prototype.
  static const int maxEntries = 6;
}
