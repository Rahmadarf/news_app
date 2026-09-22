/// Countries the headline feed can be requested for.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
/// [apiValue] is the ISO 3166-1 alpha-2 code NewsAPI's `country` parameter
/// expects. The list is deliberately short — these are the editions the
/// product offers, not every code the API accepts.
enum NewsCountry {
  indonesia('id', 'Indonesia'),
  unitedStates('us', 'United States'),
  unitedKingdom('gb', 'United Kingdom'),
  singapore('sg', 'Singapore'),
  malaysia('my', 'Malaysia'),
  australia('au', 'Australia'),
  japan('jp', 'Japan');

  const NewsCountry(this.apiValue, this.label);

  final String apiValue;

  /// Endonym-free English label. Country names are proper nouns, so they are
  /// not part of the translated catalogue.
  final String label;

  /// Default edition.
  ///
  /// Deliberately not Indonesia, even though the product is Indonesian:
  /// NewsAPI's `/top-headlines` coverage for `country=id` is thin to empty, so
  /// defaulting to it hands a new reader a blank feed. Indonesia stays
  /// selectable in Settings, and search over `/everything` is unaffected.
  static const NewsCountry fallback = NewsCountry.unitedStates;

  /// Returns [fallback] rather than throwing, so a stale persisted value
  /// cannot break start-up.
  static NewsCountry fromApiValue(String? value) {
    for (final NewsCountry country in NewsCountry.values) {
      if (country.apiValue == value) return country;
    }
    return fallback;
  }
}
