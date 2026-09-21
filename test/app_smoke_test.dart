import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/app.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/features/news/presentation/widgets/article_card.dart';

void main() {
  testWidgets('app boots into the headline feed backed by the mock source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(
            AppConfig.from(rawMode: 'mock', rawApiKey: ''),
          ),
        ],
        child: const NewsApp(),
      ),
    );

    // First frame shows the shimmer; the mock future resolves on the next turn.
    await tester.pump();
    await tester.pump();

    expect(find.text('News App'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.byType(ArticleCard), findsWidgets);
    expect(find.text('Mock general headline 1'), findsOneWidget);
  });
}
