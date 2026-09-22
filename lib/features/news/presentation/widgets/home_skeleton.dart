import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Loading placeholder that keeps the app shell and replaces only the content,
/// matching the prototype's skeleton behaviour.
///
/// The pulse is disabled when the platform reports a reduced-motion
/// preference.
class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1400),
    vsync: this,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.loadingStories,
      liveRegion: true,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.45).animate(_controller),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Block(height: 210, radius: Radii.hero),
              SizedBox(height: Spacing.gutter),
              _Block(height: 85),
              SizedBox(height: Spacing.lg),
              _Block(height: 85),
              SizedBox(height: Spacing.lg),
              _Block(height: 85),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, this.radius = Radii.thumbnail});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: NewslineTokens.of(context).surfaceSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
