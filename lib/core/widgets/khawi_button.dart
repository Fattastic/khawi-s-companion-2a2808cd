import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

enum AppButtonType { primary, secondary, outline, text, destructive }

/// A polished button component that implements the Khawi Motion System.
///
/// Features:
/// - Scale on press (0.98)
/// - Haptic feedback options
/// - Loading morph state
/// - Unified sizing and border radius
class KhawiButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonType type;
  final bool isFullWidth;
  final String? tooltip;
  final String? semanticLabel;

  const KhawiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = AppButtonType.primary,
    this.isFullWidth = true,
    this.tooltip,
    this.semanticLabel,
  });

  const KhawiButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.tooltip,
    this.semanticLabel,
  }) : type = AppButtonType.secondary;

  const KhawiButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.tooltip,
    this.semanticLabel,
  }) : type = AppButtonType.outline;

  const KhawiButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.tooltip,
    this.semanticLabel,
  }) : type = AppButtonType.destructive;

  const KhawiButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : type = AppButtonType.text;

  @override
  State<KhawiButton> createState() => _KhawiButtonState();
}

class _KhawiButtonState extends State<KhawiButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // ... skipping style computation for brevity in chunk but it must match TargetContent ...
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppTheme.radiusMedium);

    // Base styles
    Color? bgColor;
    Color? fgColor;
    BorderSide? side;
    double? elevation;

    switch (widget.type) {
      case AppButtonType.primary:
        bgColor = AppTheme.primaryGreen;
        fgColor = Colors.white;
        elevation = 0;
        break;
      case AppButtonType.secondary:
        bgColor = AppTheme.primaryGreenLight.withValues(alpha: 0.15);
        fgColor = AppTheme.primaryGreenDark;
        elevation = 0;
        break;
      case AppButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = AppTheme.primaryGreen;
        side = const BorderSide(color: AppTheme.primaryGreen, width: 1.5);
        elevation = 0;
        break;
      case AppButtonType.destructive:
        bgColor = AppTheme.error.withValues(alpha: 0.1);
        fgColor = AppTheme.error;
        elevation = 0;
        break;
      case AppButtonType.text:
        bgColor = Colors.transparent;
        fgColor = AppTheme.primaryGreen;
        elevation = 0;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      shadowColor: Colors.transparent,
      side: side,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      minimumSize: widget.isFullWidth
          ? const Size(double.infinity, 52)
          : const Size(0, 48),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: fgColor,
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget button;
    if (widget.type == AppButtonType.text) {
      button = TextButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle:
              theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: buttonStyle,
        child: content,
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      hint: widget.tooltip,
      child: KhawiMotion.pressEffect(
        isPressed: _isPressed,
        child: Listener(
          onPointerDown: (_) {
            if (widget.onPressed != null && !widget.isLoading) {
              KhawiMotion.hapticLight();
            }
            setState(() => _isPressed = true);
          },
          onPointerUp: (_) {
            if (widget.onPressed != null && !widget.isLoading) {
              KhawiMotion.hapticLight();
            }
            setState(() => _isPressed = false);
          },
          onPointerCancel: (_) => setState(() => _isPressed = false),
          child: button,
        ),
      ),
    );
  }
}
