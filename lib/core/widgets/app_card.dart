import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// A polished card component with consistent styling.
///
/// Features:
/// - Press effect animation
/// - Gradient header support
/// - Status indicator
/// - Consistent border radius and shadows
class AppCard extends StatefulWidget {
  final Widget child;
  final String? headerTitle;
  final Widget? headerAction;
  final String? semanticLabel;
  final Color? color;
  final bool hasShadow;
  final bool hasBorder;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final Color? borderColor;
  final double? borderWidth;
  final double? width;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.headerTitle,
    this.headerAction,
    this.semanticLabel,
    this.color,
    this.hasShadow = true,
    this.hasBorder = true,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.borderColor,
    this.borderWidth,
    this.width,
    this.gradient,
  });

  /// A card with a gradient header
  const AppCard.withHeader({
    super.key,
    required this.child,
    required String this.headerTitle,
    this.headerAction,
    this.semanticLabel,
    this.color,
    this.hasShadow = true,
    this.hasBorder = false,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.borderColor,
    this.borderWidth,
    this.width,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGreen.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.headerTitle!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
          if (widget.headerAction != null) widget.headerAction!,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedContainer(
      duration: AppTheme.normalAnimation,
      curve: AppTheme.defaultCurve,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.color ?? Colors.white) : null,
        gradient: widget.gradient,
        borderRadius:
            BorderRadius.circular(widget.borderRadius ?? AppTheme.radiusLarge),
        border: widget.hasBorder
            ? Border.all(
                color: _isPressed
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : (widget.borderColor ??
                        AppTheme.borderLight.withValues(alpha: 0.5)),
                width: 1.0,
              )
            : null,
        boxShadow: widget.hasShadow
            ? (_isPressed ? AppTheme.shadowSmall : AppTheme.shadowMedium)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        children: [
          if (widget.headerTitle != null) _buildHeader(),
          if (widget.mainAxisSize == MainAxisSize.max)
            Expanded(
              child: Padding(
                padding: widget.padding ??
                    const EdgeInsets.all(AppTheme.spacingMedium),
                child: widget.child,
              ),
            )
          else
            Padding(
              padding: widget.padding ??
                  const EdgeInsets.all(AppTheme.spacingMedium),
              child: widget.child,
            ),
        ],
      ),
    );

    if (widget.onTap != null) {
      cardContent = KhawiMotion.pressEffect(
        isPressed: _isPressed,
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onTap != null) {
              KhawiMotion.hapticLight();
            }
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: cardContent,
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.headerTitle,
      container: true,
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      child: cardContent,
    );
  }
}

/// A list tile card with consistent styling.
class AppListTile extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isDense;
  final Color? backgroundColor;
  final bool isDestructive;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.isDense = false,
    this.backgroundColor,
    this.isDestructive = false,
  });

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile> {
  @override
  Widget build(BuildContext context) {
    final titleColor =
        widget.isDestructive ? AppTheme.error : AppTheme.textPrimary;

    return Semantics(
      label: widget.semanticLabel ?? widget.title,
      hint: widget.semanticHint,
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      child: Material(
        color: widget.backgroundColor ?? Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: widget.isDense
                  ? AppTheme.spacingSmall
                  : AppTheme.spacingMedium,
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: AppTheme.spacingMedium),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: AppTheme.spacingSmall),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An info card for displaying key stats or metrics.
class AppInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final String? semanticLabel;
  final String? trend;
  final bool trendPositive;

  const AppInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.semanticLabel,
    this.trend,
    this.trendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primaryGreen;

    return Semantics(
      label: semanticLabel ?? '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendPositive ? AppTheme.success : AppTheme.error)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 14,
                          color:
                              trendPositive ? AppTheme.success : AppTheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: trendPositive
                                        ? AppTheme.success
                                        : AppTheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
