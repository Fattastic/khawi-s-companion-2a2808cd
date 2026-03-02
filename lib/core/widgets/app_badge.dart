import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

/// Semantic badge types for different statuses
enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
  premium,
}

/// A polished status badge component for consistent status displays.
///
/// Features:
/// - Semantic color coding (success, warning, error, info)
/// - Optional icon support
/// - Pill and dot variants
/// - Pulse animation for live statuses
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool showPulse;
  final bool isSmall;

  const AppBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
    this.showPulse = false,
    this.isSmall = false,
  });

  /// Success badge (green) - for completed, verified, active states
  const AppBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.showPulse = false,
    this.isSmall = false,
  }) : type = BadgeType.success;

  /// Warning badge (amber) - for pending, attention states
  const AppBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.showPulse = false,
    this.isSmall = false,
  }) : type = BadgeType.warning;

  /// Error badge (red) - for failed, cancelled states
  const AppBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.showPulse = false,
    this.isSmall = false,
  }) : type = BadgeType.error;

  /// Info badge (blue) - for informational states
  const AppBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.showPulse = false,
    this.isSmall = false,
  }) : type = BadgeType.info;

  /// Premium badge (gold) - for Khawi+ features
  const AppBadge.premium({
    super.key,
    required this.label,
    this.icon = Icons.star_rounded,
    this.showPulse = false,
    this.isSmall = false,
  }) : type = BadgeType.premium;

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.success:
        return AppTheme.success.withValues(alpha: 0.12);
      case BadgeType.warning:
        return AppTheme.warning.withValues(alpha: 0.12);
      case BadgeType.error:
        return AppTheme.error.withValues(alpha: 0.12);
      case BadgeType.info:
        return AppTheme.info.withValues(alpha: 0.12);
      case BadgeType.premium:
        return AppTheme.accentGold.withValues(alpha: 0.15);
      case BadgeType.neutral:
        return AppTheme.borderLight;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case BadgeType.success:
        return AppTheme.success;
      case BadgeType.warning:
        return AppTheme.warning;
      case BadgeType.error:
        return AppTheme.error;
      case BadgeType.info:
        return AppTheme.info;
      case BadgeType.premium:
        return AppTheme.accentGoldDark;
      case BadgeType.neutral:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final fgColor = _getForegroundColor();
    final verticalPadding = isSmall ? 2.0 : 4.0;
    final horizontalPadding = isSmall ? 6.0 : 10.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    final iconSize = isSmall ? 12.0 : 14.0;

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: fgColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fgColor, size: iconSize),
            SizedBox(width: isSmall ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (showPulse) {
      badge = _PulsingBadge(color: fgColor, child: badge);
    }

    if (type == BadgeType.premium) {
      badge = ShimmerEffect(
        repeatCount: 1, // Periodic attention
        duration: const Duration(milliseconds: 2000),
        shimmerColor: fgColor.withValues(alpha: 0.5),
        child: badge,
      );
    }

    return badge;
  }
}

/// A simple dot indicator badge
class AppDotBadge extends StatelessWidget {
  final BadgeType type;
  final double size;
  final bool showPulse;

  const AppDotBadge({
    super.key,
    this.type = BadgeType.success,
    this.size = 8,
    this.showPulse = false,
  });

  Color _getColor() {
    switch (type) {
      case BadgeType.success:
        return AppTheme.success;
      case BadgeType.warning:
        return AppTheme.warning;
      case BadgeType.error:
        return AppTheme.error;
      case BadgeType.info:
        return AppTheme.info;
      case BadgeType.premium:
        return AppTheme.accentGold;
      case BadgeType.neutral:
        return AppTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    final Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    if (showPulse) {
      return _PulsingDot(color: color, size: size);
    }

    return dot;
  }
}

/// A notification count badge
class AppCountBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;
  final bool showZero;

  const AppCountBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 20,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return const SizedBox.shrink();
    }

    final displayCount = count > 99 ? '99+' : '$count';
    final bgColor = color ?? AppTheme.error;
    final minWidth = displayCount.length > 2 ? size * 1.5 : size;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.55,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ANIMATED HELPERS
// ─────────────────────────────────────────────────────────────────

class _PulsingBadge extends StatefulWidget {
  final Widget child;
  final Color color;

  const _PulsingBadge({required this.child, required this.color});

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: widget.size * _scaleAnimation.value,
                height: widget.size * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        widget.color.withValues(alpha: _opacityAnimation.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // Main dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
