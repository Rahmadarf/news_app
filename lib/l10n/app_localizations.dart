import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Working product name, matching the approved design references.
  ///
  /// In en, this message translates to:
  /// **'Newsline'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @discoverTab.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTab;

  /// No description provided for @bookmarkTab.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmarkTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// Placeholder name shown until a local reader identity exists.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get greetingReader;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search news'**
  String get searchLabel;

  /// English section label carried over from the design references.
  ///
  /// In en, this message translates to:
  /// **'Trending today'**
  String get trendingTodayTitle;

  /// No description provided for @recentStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent stories'**
  String get recentStoriesTitle;

  /// No description provided for @seeAllAction.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllAction;

  /// No description provided for @loadMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Load more stories'**
  String get loadMoreAction;

  /// No description provided for @homeFooterTagline.
  ///
  /// In en, this message translates to:
  /// **'A fresh perspective, every day.'**
  String get homeFooterTagline;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get categoryTechnology;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get categoryScience;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @saveArticle.
  ///
  /// In en, this message translates to:
  /// **'Save article'**
  String get saveArticle;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @articleSaved.
  ///
  /// In en, this message translates to:
  /// **'Article saved'**
  String get articleSaved;

  /// No description provided for @articleUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Article removed from saved'**
  String get articleUnsaved;

  /// No description provided for @readArticleLabel.
  ///
  /// In en, this message translates to:
  /// **'Read {title}'**
  String readArticleLabel(String title);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline · showing saved stories'**
  String get offlineBanner;

  /// No description provided for @lastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String lastUpdatedLabel(String time);

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAction;

  /// No description provided for @exploreAction.
  ///
  /// In en, this message translates to:
  /// **'Explore news'**
  String get exploreAction;

  /// No description provided for @emptyFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'No stories here yet'**
  String get emptyFeedTitle;

  /// No description provided for @emptyFeedBody.
  ///
  /// In en, this message translates to:
  /// **'Try another topic to find a new perspective.'**
  String get emptyFeedBody;

  /// No description provided for @errorNoConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get errorNoConnectionTitle;

  /// No description provided for @errorNoConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorNoConnectionBody;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'That took too long'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'The service did not respond in time.'**
  String get errorTimeoutBody;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorizedBody.
  ///
  /// In en, this message translates to:
  /// **'The news service rejected this app\'s credentials.'**
  String get errorUnauthorizedBody;

  /// No description provided for @errorRateLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get errorRateLimitedTitle;

  /// No description provided for @errorRateLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'The news service is limiting us. Try again later.'**
  String get errorRateLimitedBody;

  /// No description provided for @errorUpgradeRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available on this plan'**
  String get errorUpgradeRequiredTitle;

  /// No description provided for @errorUpgradeRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'The news service does not allow this request.'**
  String get errorUpgradeRequiredBody;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get errorServerTitle;

  /// No description provided for @errorServerBody.
  ///
  /// In en, this message translates to:
  /// **'The news service is having trouble. Try again later.'**
  String get errorServerBody;

  /// No description provided for @errorMalformedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response'**
  String get errorMalformedTitle;

  /// No description provided for @errorMalformedBody.
  ///
  /// In en, this message translates to:
  /// **'The news service sent something we could not read.'**
  String get errorMalformedBody;

  /// No description provided for @errorCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage problem'**
  String get errorCacheTitle;

  /// No description provided for @errorCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Saved stories could not be read.'**
  String get errorCacheBody;

  /// No description provided for @errorConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'App is not configured'**
  String get errorConfigurationTitle;

  /// No description provided for @errorConfigurationBody.
  ///
  /// In en, this message translates to:
  /// **'This build is missing its news configuration.'**
  String get errorConfigurationBody;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get errorUnknownBody;

  /// No description provided for @loadingStories.
  ///
  /// In en, this message translates to:
  /// **'Loading stories'**
  String get loadingStories;

  /// Shown while the app runs on bundled mock fixtures.
  ///
  /// In en, this message translates to:
  /// **'Sample editorial content for design review.'**
  String get sampleDataNotice;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Not built yet'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later stage of the design work.'**
  String get comingSoonBody;

  /// No description provided for @unknownSource.
  ///
  /// In en, this message translates to:
  /// **'Unknown source'**
  String get unknownSource;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search stories, topics, perspectives...'**
  String get searchHint;

  /// No description provided for @clearSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchAction;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @recentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearchesTitle;

  /// No description provided for @removeRecentSearch.
  ///
  /// In en, this message translates to:
  /// **'Remove from recent searches'**
  String get removeRecentSearch;

  /// No description provided for @exploreTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore topics'**
  String get exploreTopicsTitle;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different term, such as a city, a topic, or a source.'**
  String get searchEmptyBody;

  /// No description provided for @sortRelevancy.
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get sortRelevancy;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopularity;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stories} =1{1 story} other{{count} stories}}'**
  String searchResultCount(int count);

  /// No description provided for @shareArticle.
  ///
  /// In en, this message translates to:
  /// **'Share article'**
  String get shareArticle;

  /// No description provided for @articleOptions.
  ///
  /// In en, this message translates to:
  /// **'Article options'**
  String get articleOptions;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @readFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Read the full article'**
  String get readFullArticle;

  /// No description provided for @relatedStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Related stories'**
  String get relatedStoriesTitle;

  /// No description provided for @increaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Increase text size'**
  String get increaseTextSize;

  /// No description provided for @decreaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Decrease text size'**
  String get decreaseTextSize;

  /// No description provided for @readMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String readMinutes(int minutes);

  /// No description provided for @truncatedContentNotice.
  ///
  /// In en, this message translates to:
  /// **'The news service provides an excerpt only. Open the full article at its source.'**
  String get truncatedContentNotice;

  /// No description provided for @articleUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Article not loaded'**
  String get articleUnavailableTitle;

  /// No description provided for @articleUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Open it from the feed, or read it on the web.'**
  String get articleUnavailableBody;

  /// No description provided for @articleUnavailableNoLink.
  ///
  /// In en, this message translates to:
  /// **'This link does not point at an article.'**
  String get articleUnavailableNoLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
