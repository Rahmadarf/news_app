// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Newsline';

  @override
  String get homeTab => 'Home';

  @override
  String get discoverTab => 'Discover';

  @override
  String get bookmarkTab => 'Bookmark';

  @override
  String get settingsTab => 'Settings';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get greetingReader => 'Reader';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get searchLabel => 'Search news';

  @override
  String get trendingTodayTitle => 'Trending today';

  @override
  String get recentStoriesTitle => 'Recent stories';

  @override
  String get seeAllAction => 'See all';

  @override
  String get loadMoreAction => 'Load more stories';

  @override
  String get homeFooterTagline => 'A fresh perspective, every day.';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get saveArticle => 'Save article';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get articleSaved => 'Article saved';

  @override
  String get articleUnsaved => 'Article removed from saved';

  @override
  String readArticleLabel(String title) {
    return 'Read $title';
  }

  @override
  String get offlineBanner => 'You are offline · showing saved stories';

  @override
  String lastUpdatedLabel(String time) {
    return 'Updated $time';
  }

  @override
  String get retryAction => 'Try again';

  @override
  String get exploreAction => 'Explore news';

  @override
  String get emptyFeedTitle => 'No stories here yet';

  @override
  String get emptyFeedBody => 'Try another topic to find a new perspective.';

  @override
  String get errorNoConnectionTitle => 'You are offline';

  @override
  String get errorNoConnectionBody => 'Check your connection and try again.';

  @override
  String get errorTimeoutTitle => 'That took too long';

  @override
  String get errorTimeoutBody => 'The service did not respond in time.';

  @override
  String get errorUnauthorizedTitle => 'Access denied';

  @override
  String get errorUnauthorizedBody =>
      'The news service rejected this app\'s credentials.';

  @override
  String get errorRateLimitedTitle => 'Too many requests';

  @override
  String get errorRateLimitedBody =>
      'The news service is limiting us. Try again later.';

  @override
  String get errorUpgradeRequiredTitle => 'Not available on this plan';

  @override
  String get errorUpgradeRequiredBody =>
      'The news service does not allow this request.';

  @override
  String get errorServerTitle => 'Service unavailable';

  @override
  String get errorServerBody =>
      'The news service is having trouble. Try again later.';

  @override
  String get errorMalformedTitle => 'Unexpected response';

  @override
  String get errorMalformedBody =>
      'The news service sent something we could not read.';

  @override
  String get errorCacheTitle => 'Storage problem';

  @override
  String get errorCacheBody => 'Saved stories could not be read.';

  @override
  String get errorConfigurationTitle => 'App is not configured';

  @override
  String get errorConfigurationBody =>
      'This build is missing its news configuration.';

  @override
  String get errorUnknownTitle => 'Something went wrong';

  @override
  String get errorUnknownBody => 'Please try again.';

  @override
  String get loadingStories => 'Loading stories';

  @override
  String get sampleDataNotice => 'Sample editorial content for design review.';

  @override
  String get comingSoonTitle => 'Not built yet';

  @override
  String get comingSoonBody =>
      'This screen arrives in a later stage of the design work.';

  @override
  String get unknownSource => 'Unknown source';

  @override
  String get searchHint => 'Search stories, topics, perspectives...';

  @override
  String get clearSearchAction => 'Clear search';

  @override
  String get clearAction => 'Clear';

  @override
  String get recentSearchesTitle => 'Recent searches';

  @override
  String get removeRecentSearch => 'Remove from recent searches';

  @override
  String get exploreTopicsTitle => 'Explore topics';

  @override
  String get searchEmptyTitle => 'Nothing found';

  @override
  String get searchEmptyBody =>
      'Try a different term, such as a city, a topic, or a source.';

  @override
  String get sortRelevancy => 'Most relevant';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPopularity => 'Popular';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
      zero: 'No stories',
    );
    return '$_temp0';
  }

  @override
  String get shareArticle => 'Share article';

  @override
  String get articleOptions => 'Article options';

  @override
  String get copyLink => 'Copy link';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String get readFullArticle => 'Read the full article';

  @override
  String get relatedStoriesTitle => 'Related stories';

  @override
  String get increaseTextSize => 'Increase text size';

  @override
  String get decreaseTextSize => 'Decrease text size';

  @override
  String readMinutes(int minutes) {
    return '$minutes min read';
  }

  @override
  String get truncatedContentNotice =>
      'The news service provides an excerpt only. Open the full article at its source.';

  @override
  String get articleUnavailableTitle => 'Article not loaded';

  @override
  String get articleUnavailableBody =>
      'Open it from the feed, or read it on the web.';

  @override
  String get articleUnavailableNoLink =>
      'This link does not point at an article.';
}
