import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Locales for which relative-time messages are registered at start-up.
///
/// `timeago` throws for an unregistered locale, so anything else falls back to
/// English rather than crashing a list row.
const Set<String> kRelativeTimeLocales = <String>{'en', 'id'};

/// "28 menit lalu" / "28 minutes ago".
String formatRelativeTime(DateTime moment, String languageCode) {
  return timeago.format(
    moment,
    locale: kRelativeTimeLocales.contains(languageCode) ? languageCode : 'en',
  );
}

/// "22 September 2026" in the active locale.
///
/// Used where an exact publication date matters more than "2 hours ago".
String formatAbsoluteDate(DateTime moment, String locale) {
  return DateFormat.yMMMMd(locale).format(moment.toLocal());
}
