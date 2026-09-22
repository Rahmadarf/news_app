import 'package:shared_preferences/shared_preferences.dart';

/// Small scalar preferences.
///
/// Deliberately separate from the Drift database: a toggle should not require
/// a schema migration, and these values have no relational shape.
///
/// Holds the selected category, theme, reading text size, edition, and
/// language.
class SettingsStore {
  const SettingsStore(this._prefs);

  static const String selectedCategoryKey = 'settings.selected_category';
  static const String themeModeKey = 'settings.theme_mode';
  static const String readingTextScaleKey = 'settings.reading_text_scale';
  static const String countryKey = 'settings.country';
  static const String localeKey = 'settings.locale';

  final SharedPreferences _prefs;

  static Future<SettingsStore> open() async =>
      SettingsStore(await SharedPreferences.getInstance());

  /// Raw stored value, or `null` when nothing was ever written. Validation
  /// belongs to the caller, so an unknown value degrades to a default rather
  /// than throwing.
  String? readSelectedCategory() => _prefs.getString(selectedCategoryKey);

  Future<void> writeSelectedCategory(String apiValue) =>
      _prefs.setString(selectedCategoryKey, apiValue);

  /// Raw stored theme preference: `system`, `light`, or `dark`. `null` until
  /// the reader chooses one.
  String? readThemeMode() => _prefs.getString(themeModeKey);

  Future<void> writeThemeMode(String value) =>
      _prefs.setString(themeModeKey, value);

  /// Reader's own text-size multiplier for article body copy. `null` until
  /// they change it.
  double? readReadingTextScale() => _prefs.getDouble(readingTextScaleKey);

  Future<void> writeReadingTextScale(double value) =>
      _prefs.setDouble(readingTextScaleKey, value);

  /// Raw stored edition, as an ISO country code. `null` until chosen.
  String? readCountry() => _prefs.getString(countryKey);

  Future<void> writeCountry(String apiValue) =>
      _prefs.setString(countryKey, apiValue);

  /// Raw stored language tag, or `null` to follow the device.
  String? readLocale() => _prefs.getString(localeKey);

  Future<void> writeLocale(String? languageCode) => languageCode == null
      ? _prefs.remove(localeKey)
      : _prefs.setString(localeKey, languageCode);
}
