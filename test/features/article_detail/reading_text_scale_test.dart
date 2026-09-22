import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/persistence/settings_store.dart';
import 'package:news_app/features/article_detail/presentation/widgets/article_body.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> containerWith(
    Map<String, Object> preferences,
  ) async {
    SharedPreferences.setMockInitialValues(preferences);
    final SettingsStore settings = await SettingsStore.open();

    final ProviderContainer container = ProviderContainer.test(
      overrides: <Override>[settingsStoreProvider.overrideWithValue(settings)],
    );
    container.listen<double>(
      readingTextScaleProvider,
      (double? previous, double next) {},
      fireImmediately: true,
    );
    return container;
  }

  group('ReadingTextScaleController', () {
    test('defaults to 1 when nothing is stored', () async {
      final ProviderContainer container = await containerWith(
        <String, Object>{},
      );

      expect(
        container.read(readingTextScaleProvider),
        ReadingTextScaleController.defaultScale,
      );
    });

    test('restores a stored preference', () async {
      final ProviderContainer container = await containerWith(<String, Object>{
        SettingsStore.readingTextScaleKey: 1.3,
      });

      expect(container.read(readingTextScaleProvider), 1.3);
    });

    test('snaps an unknown stored value to the nearest allowed step', () async {
      final ProviderContainer container = await containerWith(<String, Object>{
        SettingsStore.readingTextScaleKey: 7.5,
      });

      expect(
        container.read(readingTextScaleProvider),
        ReadingTextScaleController.steps.last,
      );
    });

    test('steps up and down through the allowed values', () async {
      final ProviderContainer container = await containerWith(
        <String, Object>{},
      );
      final ReadingTextScaleController controller = container.read(
        readingTextScaleProvider.notifier,
      );

      controller.increase();
      expect(container.read(readingTextScaleProvider), 1.15);

      controller.decrease();
      expect(container.read(readingTextScaleProvider), 1);
    });

    test('stops at the ends instead of running past them', () async {
      final ProviderContainer container = await containerWith(
        <String, Object>{},
      );
      final ReadingTextScaleController controller = container.read(
        readingTextScaleProvider.notifier,
      );

      for (int i = 0; i < 10; i++) {
        controller.increase();
      }
      expect(
        container.read(readingTextScaleProvider),
        ReadingTextScaleController.steps.last,
      );
      expect(controller.canIncrease, isFalse);

      for (int i = 0; i < 10; i++) {
        controller.decrease();
      }
      expect(
        container.read(readingTextScaleProvider),
        ReadingTextScaleController.steps.first,
      );
      expect(controller.canDecrease, isFalse);
    });

    test('persists the chosen step', () async {
      final ProviderContainer container = await containerWith(
        <String, Object>{},
      );
      container.read(readingTextScaleProvider.notifier).increase();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble(SettingsStore.readingTextScaleKey), 1.15);
    });
  });

  group('ArticleBody scaling', () {
    /// Measures the rendered font size of the body paragraph.
    Future<double> renderedFontSize(
      WidgetTester tester, {
      required double platformScale,
      required double readerScale,
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(platformScale)),
          child: MaterialApp(
            home: Scaffold(
              body: ArticleBody(
                paragraphs: const <String>['Satu paragraf.'],
                readerScale: readerScale,
              ),
            ),
          ),
        ),
      );

      final RichText rendered = tester.widget<RichText>(
        find.descendant(
          of: find.text('Satu paragraf.'),
          matching: find.byType(RichText),
        ),
      );
      final TextStyle style = (rendered.text as TextSpan).style!;
      return rendered.textScaler.scale(style.fontSize!);
    }

    testWidgets('the reader preference multiplies the platform scale', (
      WidgetTester tester,
    ) async {
      final double atOne = await renderedFontSize(
        tester,
        platformScale: 1,
        readerScale: 1,
      );
      final double readerLarger = await renderedFontSize(
        tester,
        platformScale: 1,
        readerScale: 1.5,
      );
      final double platformLarger = await renderedFontSize(
        tester,
        platformScale: 1.5,
        readerScale: 1,
      );
      final double both = await renderedFontSize(
        tester,
        platformScale: 1.5,
        readerScale: 1.5,
      );

      expect(readerLarger, greaterThan(atOne));
      expect(platformLarger, greaterThan(atOne));
      expect(
        both,
        greaterThan(platformLarger),
        reason: 'the preference must add to the system setting, not replace it',
      );
    });

    testWidgets('a system setting alone still enlarges body copy', (
      WidgetTester tester,
    ) async {
      // A reader who has already enlarged text system-wide must not be reset
      // to the app default.
      final double smallest = await renderedFontSize(
        tester,
        platformScale: 2,
        readerScale: 0.9,
      );
      final double unscaled = await renderedFontSize(
        tester,
        platformScale: 1,
        readerScale: 1,
      );

      expect(smallest, greaterThan(unscaled));
    });

    testWidgets('the combined scale is clamped', (WidgetTester tester) async {
      final double extreme = await renderedFontSize(
        tester,
        platformScale: 6,
        readerScale: 1.5,
      );

      // 17 logical pixels times the documented maximum of 3.
      expect(extreme, lessThanOrEqualTo(17 * 3 + 0.01));
    });
  });
}
