import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final bool elevated;

  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingLarge),
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: borderColor ?? AppTheme.borderLight,
          width: borderWidth,
        ),
        boxShadow: elevated ? AppTheme.shadowSmall : null,
      ),
      child: child,
    );
  }
}
