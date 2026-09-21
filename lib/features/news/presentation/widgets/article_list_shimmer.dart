import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_colors.dart';

/// Placeholder list shown during a first load.
///
/// Only the pieces that actually change are rebuilt each frame; the previous
/// implementation wrapped static containers in `AnimatedBuilder`s that ignored
/// the animation value. See docs/AUDIT.md M-7.
class ArticleListShimmer extends StatefulWidget {
  const ArticleListShimmer({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<ArticleListShimmer> createState() => _ArticleListShimmerState();
}

class _ArticleListShimmerState extends State<ArticleListShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = Tween<double>(
    begin: -1,
    end: 2,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          AppColors.divider,
                          AppColors.divider.withValues(alpha: 0.5),
                          AppColors.divider,
                        ],
                        stops: const <double>[0, 0.5, 1],
                        transform: GradientRotation(_animation.value * 3.14159),
                      ),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ShimmerBar(height: 12, width: 100),
                    SizedBox(height: 12),
                    _ShimmerBar(height: 16),
                    SizedBox(height: 8),
                    _ShimmerBar(height: 16, widthFactor: 0.7),
                    SizedBox(height: 12),
                    _ShimmerBar(height: 14),
                    SizedBox(height: 6),
                    _ShimmerBar(height: 14, widthFactor: 0.5),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.height, this.width, this.widthFactor});

  final double height;
  final double? width;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final Widget bar = Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.divider,
      ),
    );

    if (widthFactor == null) return bar;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: bar,
    );
  }
}
