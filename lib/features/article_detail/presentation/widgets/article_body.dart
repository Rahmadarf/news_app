import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';

/// Editorial body copy at the reader's chosen text size.
///
/// The reader's preference *multiplies* the platform text scale rather than
/// replacing it, and the product is clamped. That keeps the control useful
/// without letting it undo an accessibility setting: a reader who has already
/// enlarged text system-wide still gets larger copy here.
class ArticleBody extends StatelessWidget {
  const ArticleBody({
    super.key,
    required this.paragraphs,
    required this.readerScale,
    this.maxEffectiveScale = 3,
  });

  final List<String> paragraphs;
  final double readerScale;

  /// Upper bound on the combined scale. Beyond this the serif body stops being
  /// readable inside a phone-width column.
  final double maxEffectiveScale;

  @override
  Widget build(BuildContext context) {
    final TextScaler platform = MediaQuery.textScalerOf(context);

    // Sample the platform scaler at the body size to learn its effective
    // factor, then fold the reader's preference in on top of it.
    const double bodySize = 17;
    final double platformFactor = platform.scale(bodySize) / bodySize;
    final double combined = (platformFactor * readerScale).clamp(
      0.8,
      maxEffectiveScale,
    );

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: combined,
      maxScaleFactor: combined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String paragraph in paragraphs) ...<Widget>[
            Text(paragraph, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: Spacing.lg),
          ],
        ],
      ),
    );
  }
}

/// Accent-ruled pull quote.
class ArticleQuote extends StatelessWidget {
  const ArticleQuote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final NewslineTokens tokens = NewslineTokens.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.lg),
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, 0, Spacing.sm),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: tokens.accent, width: 3)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontSize: 20, height: 1.45),
      ),
    );
  }
}
