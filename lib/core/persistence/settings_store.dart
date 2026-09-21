import 'package:shared_preferences/shared_preferences.dart';

/// Small scalar preferences.
///
/// Deliberately separate from the Drift database: a toggle should not require
/// a schema migration, and these values have no relational shape.
///
/// Only the selected category is stored today. Theme, locale, and country join
/// it when the settings feature lands.
class SettingsStore {
  const SettingsStore(this._prefs);

  static const String selectedCategoryKey = 'settings.selected_category';

  final SharedPreferences _prefs;

  static Future<SettingsStore> open() async =>
      SettingsStore(await SharedPreferences.getInstance());

  /// Raw stored value, or `null` when nothing was ever written. Validation
  /// belongs to the caller, so an unknown value degrades to a default rather
  /// than throwing.
  String? readSelectedCategory() => _prefs.getString(selectedCategoryKey);

  Future<void> writeSelectedCategory(String apiValue) =>
      _prefs.setString(selectedCategoryKey, apiValue);
}
