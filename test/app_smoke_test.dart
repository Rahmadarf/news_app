import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/app.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/features/news/domain/entities/news_category.dart';
import 'package:news_app/features/news/presentation/widgets/article_row.dart';
import 'package:news_app/features/news/presentation/widgets/featured_article_card.dart';

import 'support/pump_app.dart';

void main() {
  late Map<String, String> fixtures;

  setUpAll(() async {
    fixtures = await loadFixtureStrings();
  });

  testWidgets('app boots into the Newsline home feed', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(ArticleRow));

    // Section headings come from the approved design references.
    expect(find.text('Trending today'), findsOneWidget);
    expect(find.text('Recent stories'), findsOneWidget);

    expect(find.byType(FeaturedArticleCard), findsWidgets);
    expect(find.byType(ArticleRow), findsWidgets);

    // The fixture's "[Removed]" tombstone must never reach the UI.
    expect(find.textContaining('[Removed]'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('the bottom navigation exposes the four approved tabs', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, fixtures: fixtures);
    await pumpUntil(tester, find.byType(NavigationBar));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Bookmark'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a stored category preference is restored at start-up', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      fixtures: fixtures,
      preferences: <String, Object>{
        SettingsStore.selectedCategoryKey: NewsCategory.sports.apiValue,
      },
    );
    await pumpUntil(tester, find.byType(ArticleRow));

    // The Sports chip reports itself as selected to assistive technology.
    final Iterable<Semantics> selected = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((Semantics s) => s.properties.selected ?? false);

    expect(selected, isNotEmpty);

    await disposeApp(tester);
  });

  testWidgets('an unusable configuration shows the error screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ConfigurationErrorApp(
        error: ConfigurationError(summary: 'missing key', remedy: 'pass one'),
      ),
    );
    await tester.pump();

    expect(find.text('Configuration error'), findsOneWidget);
    expect(find.text('missing key'), findsOneWidget);
    expect(find.text('pass one'), findsOneWidget);

    await disposeApp(tester);
  });
}
