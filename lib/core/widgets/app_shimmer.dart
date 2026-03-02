import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// A professional shimmer loading effect for skeleton screens.
///
/// Use this to show loading states for cards, lists, and other content.
/// Provides a polished, professional feel during data fetching.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  /// Creates a shimmer placeholder box
  const factory AppShimmer.box({
    Key? key,
    double? width,
    double? height,
    double borderRadius,
  }) = _ShimmerBox;

  /// Creates a shimmer placeholder for text lines
  const factory AppShimmer.text({
    Key? key,
    double width,
    double height,
    int lines,
    double spacing,
  }) = _ShimmerText;

  /// Creates a shimmer placeholder for a card
  const factory AppShimmer.card({
    Key? key,
    double? height,
    EdgeInsetsGeometry? padding,
  }) = _ShimmerCard;

  /// Creates a shimmer placeholder for a list tile
  const factory AppShimmer.listTile({
    Key? key,
    bool hasLeading,
    bool hasSubtitle,
    bool hasTrailing,
  }) = _ShimmerListTile;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppTheme.borderLight;
    final highlightColor =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

// ─────────────────────────────────────────────────────────────────
// SHIMMER VARIANTS
// ─────────────────────────────────────────────────────────────────

class _ShimmerBox extends AppShimmer {
  final double? width;
  final double? height;
  final double borderRadius;

  const _ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusMedium,
  }) : super(child: const SizedBox());

  @override
  State<AppShimmer> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends _AppShimmerState {
  @override
  Widget build(BuildContext context) {
    final shimmerBox = widget as _ShimmerBox;
    final baseColor = widget.baseColor ?? AppTheme.borderLight;
    final highlightColor =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: Container(
            width: shimmerBox.width,
            height: shimmerBox.height ?? 16,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(shimmerBox.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerText extends AppShimmer {
  final double width;
  final double height;
  final int lines;
  final double spacing;

  const _ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.lines = 3,
    this.spacing = 8,
  }) : super(child: const SizedBox());

  @override
  State<AppShimmer> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends _AppShimmerState {
  @override
  Widget build(BuildContext context) {
    final shimmerText = widget as _ShimmerText;
    final baseColor = widget.baseColor ?? AppTheme.borderLight;
    final highlightColor =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(shimmerText.lines, (index) {
              // Last line is shorter for a natural look
              final isLast = index == shimmerText.lines - 1;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : shimmerText.spacing,
                ),
                child: Container(
                  width: isLast ? shimmerText.width * 0.6 : shimmerText.width,
                  height: shimmerText.height,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends AppShimmer {
  final double? height;
  final EdgeInsetsGeometry? padding;

  const _ShimmerCard({
    super.key,
    this.height,
    this.padding,
  }) : super(child: const SizedBox());

  @override
  State<AppShimmer> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends _AppShimmerState {
  @override
  Widget build(BuildContext context) {
    final shimmerCard = widget as _ShimmerCard;
    final baseColor = widget.baseColor ?? AppTheme.borderLight;
    final highlightColor =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: Container(
            height: shimmerCard.height ?? 120,
            padding: shimmerCard.padding ??
                const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerListTile extends AppShimmer {
  final bool hasLeading;
  final bool hasSubtitle;
  final bool hasTrailing;

  const _ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  }) : super(child: const SizedBox());

  @override
  State<AppShimmer> createState() => _ShimmerListTileState();
}

class _ShimmerListTileState extends _AppShimmerState {
  @override
  Widget build(BuildContext context) {
    final shimmerTile = widget as _ShimmerListTile;
    final baseColor = widget.baseColor ?? AppTheme.borderLight;
    final highlightColor =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                if (shimmerTile.hasLeading) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (shimmerTile.hasSubtitle) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.borderLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (shimmerTile.hasTrailing)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
