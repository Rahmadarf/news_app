import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_app/main.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/widgets/news_card.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('app boots into the home feed backed by the mock data source', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(newsService: MockNewsService()));

    // First frame: bindings ran, the initial fetch is in flight.
    await tester.pump();
    // Second pump settles the already-completed mock future.
    await tester.pump();

    expect(find.text('News App'), findsOneWidget);
    expect(find.byType(NewsCard), findsWidgets);
    expect(find.text('Mock general headline 1'), findsOneWidget);
  });
}
