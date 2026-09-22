import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/app/di/providers.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Publication date on the left, text-size controls on the right, between two
/// hairlines — the strip from the article design.
class ReadingControls extends ConsumerWidget {
  const ReadingControls({super.key, required this.dateLabel});

  final String? dateLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);
    final ReadingTextScaleController controller = ref.read(
      readingTextScaleProvider.notifier,
    );
    ref.watch(readingTextScaleProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tokens.hairline),
          bottom: BorderSide(color: tokens.hairline),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              dateLabel ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          IconButton(
            onPressed: controller.canDecrease ? controller.decrease : null,
            tooltip: l10n.decreaseTextSize,
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            onPressed: controller.canIncrease ? controller.increase : null,
            tooltip: l10n.increaseTextSize,
            icon: const Icon(Icons.text_increase),
          ),
        ],
      ),
    );
  }
}
