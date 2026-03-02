import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// A styled progress indicator for XP, levels, goals, etc.
///
/// Features:
/// - Animated progress fill
/// - Optional label and percentage display
/// - Gradient support
/// - Milestone markers
class AppProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final bool showPercentage;
  final String? label;
  final String? trailingLabel;
  final bool animate;
  final List<double>? milestones;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.showPercentage = false,
    this.label,
    this.trailingLabel,
    this.animate = true,
    this.milestones,
  });

  /// XP progress bar with gold accent
  const AppProgressBar.xp({
    super.key,
    required this.value,
    this.label,
    this.trailingLabel,
    this.showPercentage = true,
    this.milestones,
  })  : height = 10,
        backgroundColor = AppTheme.borderLight,
        foregroundColor = null,
        gradient = AppTheme.goldGradient,
        animate = true;

  /// Level progress bar with green accent
  const AppProgressBar.level({
    super.key,
    required this.value,
    this.label,
    this.trailingLabel,
    this.showPercentage = false,
    this.milestones,
  })  : height = 6,
        backgroundColor = AppTheme.borderLight,
        foregroundColor = AppTheme.primaryGreen,
        gradient = null,
        animate = true;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final bgColor = backgroundColor ?? AppTheme.borderLight;
    final fgColor = foregroundColor ?? AppTheme.primaryGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailingLabel != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                else
                  const SizedBox.shrink(),
                if (showPercentage || trailingLabel != null)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: clampedValue),
                    duration: animate ? AppTheme.slowAnimation : Duration.zero,
                    curve: AppTheme.defaultCurve,
                    builder: (context, animValue, _) {
                      return Text(
                        trailingLabel ?? '${(animValue * 100).toInt()}%',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      );
                    },
                  ),
              ],
            ),
          ),
        Stack(
          children: [
            // Background track
            Container(
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progress fill
            AnimatedContainer(
              duration: animate ? AppTheme.slowAnimation : Duration.zero,
              curve: AppTheme.defaultCurve,
              height: height,
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: clampedValue,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: gradient == null ? fgColor : null,
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: clampedValue > 0
                            ? [
                                BoxShadow(
                                  color: (gradient != null
                                          ? AppTheme.accentGold
                                          : fgColor)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: (gradient != null
                                          ? AppTheme.accentGold
                                          : fgColor)
                                      .withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (gradient != null && clampedValue > 0)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(height / 2),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: -1.0, end: 2.0),
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.linear,
                          builder: (context, anim, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.6),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment(anim - 1.0, 0),
                                  end: Alignment(anim + 1.0, 0),
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Container(color: Colors.white),
                            );
                          },
                          onEnd: () {
                            // Can't natively loop TweenAnimationBuilder without rebuilding its key,
                            // but we can let it play once per build/expansion or use a custom controller.
                            // To keep it simple we'll just let it shine once on appear/update.
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Milestone markers
            if (milestones != null)
              ...milestones!.map((milestone) {
                final clampedMilestone = milestone.clamp(0.0, 1.0);
                return Positioned(
                  left: 0,
                  right: 0,
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: clampedMilestone,
                    child: Semantics(
                      label: 'Milestone at ${(milestone * 100).toInt()}%',
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 4,
                          height: height + 6,
                          decoration: BoxDecoration(
                            color: clampedValue >= clampedMilestone
                                ? Colors.white
                                : AppTheme.textTertiary.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2.0),
                            boxShadow: clampedValue >= clampedMilestone
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }
}

/// A circular progress indicator with optional center content.
class AppCircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? center;
  final bool animate;

  const AppCircularProgress({
    super.key,
    required this.value,
    this.size = 80,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.foregroundColor,
    this.center,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final bgColor = backgroundColor ?? AppTheme.borderLight;
    final fgColor = foregroundColor ?? AppTheme.primaryGreen;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation(bgColor),
            ),
          ),
          // Progress arc
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clampedValue),
            duration: animate ? AppTheme.slowAnimation : Duration.zero,
            curve: AppTheme.defaultCurve,
            builder: (context, animatedValue, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(fgColor),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // Center content
          if (center != null) center!,
        ],
      ),
    );
  }
}

/// A step indicator for multi-step flows (onboarding, wizards).
class AppStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;

  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppTheme.primaryGreen;
    final inactive = inactiveColor ?? AppTheme.borderColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;

        return Padding(
          padding: EdgeInsets.only(right: index < totalSteps - 1 ? spacing : 0),
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            curve: AppTheme.defaultCurve,
            width: isCurrent ? dotSize * 2.5 : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(dotSize / 2),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: active.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
