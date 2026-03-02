import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';

/// A premium, highly animated progress bar for the gamification system.
///
/// Features:
/// - Smooth animated value changes with spring physics
/// - Layered glow effects that pulse at milestones
/// - Shimmering "light sweep" across the progress fill
/// - Haptic feedback integration
class LevelProgressBar extends StatefulWidget {
  final double value;
  final int level;
  final String? label;
  final List<double> milestones;
  final double height;
  final Gradient? gradient;
  final Color? glowColor;
  final Color? backgroundColor;

  const LevelProgressBar({
    super.key,
    required this.value,
    this.level = 1,
    this.label,
    this.milestones = const [0.25, 0.5, 0.75, 1.0],
    this.height = 12,
    this.gradient,
    this.glowColor,
    this.backgroundColor,
  });

  @override
  State<LevelProgressBar> createState() => _LevelProgressBarState();
}

class _LevelProgressBarState extends State<LevelProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  double _lastFiredMilestone = -1.0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: MotionTokens.t4,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: MotionTokens.springLite,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController.animateTo(widget.value.clamp(0.0, 1.0));
  }

  @override
  void didUpdateWidget(LevelProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _progressController.animateTo(
        widget.value.clamp(0.0, 1.0),
        curve: MotionTokens.springLite,
      );
      _checkMilestones();
    }
  }

  void _checkMilestones() {
    for (final milestone in widget.milestones) {
      if (widget.value >= milestone && _lastFiredMilestone < milestone) {
        _lastFiredMilestone = milestone;
        HapticFeedback.mediumImpact();
        // trigger a specific glow burst if we had a more complex animation
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeGradient = widget.gradient ?? AppTheme.primaryGradient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  'LVL ${widget.level}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                        letterSpacing: 1.0,
                      ),
                ),
              ],
            ),
          ),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background Track with Inner Shadow (Subtle)
            Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    AppTheme.borderLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),

            // Milestone Marks (Behind Progress)
            ...widget.milestones.map(
              (m) => _MilestoneMarker(
                progress: m,
                height: widget.height,
                isReached: widget.value >= m,
              ),
            ),

            // Progress Fill
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: themeGradient,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color:
                              themeGradient.colors.first.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                        // Dynamic outer glow based on animation
                        BoxShadow(
                          color: (widget.glowColor ?? themeGradient.colors.last)
                              .withValues(alpha: 0.2 * _glowController.value),
                          blurRadius: 20,
                          spreadRadius: 2 * _glowController.value,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: Stack(
                        children: [
                          // Shimmer sweep
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, _) {
                              return FractionallySizedBox(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: const [
                                        Colors.transparent,
                                        Colors.white30,
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment(
                                        (_shimmerController.value * 3) - 1.5,
                                        -0.2,
                                      ),
                                      end: Alignment(
                                        (_shimmerController.value * 3) - 0.5,
                                        0.2,
                                      ),
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Container(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MilestoneMarker extends StatelessWidget {
  final double progress;
  final double height;
  final bool isReached;

  const _MilestoneMarker({
    required this.progress,
    required this.height,
    required this.isReached,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: progress,
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: MotionTokens.t3,
            width: isReached ? 4 : 2,
            height: isReached ? height + 6 : height - 2,
            decoration: BoxDecoration(
              color: isReached
                  ? Colors.white
                  : AppTheme.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isReached
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
