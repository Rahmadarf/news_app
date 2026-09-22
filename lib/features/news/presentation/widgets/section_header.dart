import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';

/// Serif section heading with an optional trailing action.
///
/// Used by "Trending today" and "Recent stories".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.lg,
        Spacing.sm,
        Spacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
