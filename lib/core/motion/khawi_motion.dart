import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';

/// Utility methods to apply the Khawi Motion System.
class KhawiMotion {
  KhawiMotion._();

  /// Applies a subtle scale press effect.
  static Widget pressEffect({
    required Widget child,
    required bool isPressed,
    double scale = 0.96,
  }) {
    return Builder(
      builder: (context) {
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }
        return AnimatedScale(
          scale: isPressed ? scale : 1.0,
          duration: isPressed
              ? const Duration(milliseconds: 100)
              : const Duration(milliseconds: 350),
          curve: isPressed ? Curves.easeOutCubic : SpringCurve.bouncy,
          child: child,
        );
      },
    );
  }

  /// Standard fade in transition.
  static Widget fadeIn(
    Widget child, {
    Duration duration = MotionTokens.t2,
    Curve curve = MotionTokens.standard,
  }) {
    return Builder(
      builder: (context) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: disabled ? Duration.zero : duration,
          curve: curve,
          builder: (context, value, child) {
            return Opacity(opacity: value.clamp(0.0, 1.0), child: child!);
          },
          child: child,
        );
      },
    );
  }

  /// Fade in with slide up animation - great for list items and cards
  static Widget fadeInSlideUp(
    Widget child, {
    Duration duration = MotionTokens.t3,
    Curve curve = MotionTokens.standard,
    double slideOffset = 16.0,
  }) {
    return Builder(
      builder: (context) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: disabled ? Duration.zero : duration,
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, slideOffset * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  /// Scale in animation - great for icons and badges appearing
  static Widget scaleIn(
    Widget child, {
    Duration duration = MotionTokens.t2,
    Curve curve = MotionTokens.standard,
    double startScale = 0.8,
  }) {
    return Builder(
      builder: (context) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: startScale, end: 1.0),
          duration: disabled ? Duration.zero : duration,
          curve: curve,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  /// Staggered list item entry.
  static Widget staggeredEntry({
    required Widget child,
    required int index,
    Duration duration = MotionTokens.t3,
    double slideOffset = 20.0,
  }) {
    return Builder(
      builder: (context) {
        final bool disabled = MediaQuery.of(context).disableAnimations;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: disabled ? Duration.zero : duration,
          curve: MotionTokens.standard,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, slideOffset * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  /// Combined slide-up + fade-in with optional index-based stagger delay.
  ///
  /// Unlike [fadeInSlideUp], this variant accepts an [index] parameter so that
  /// items in a group can cascade automatically without a wrapping
  /// [StaggeredAnimationList].  Items beyond [MotionTokens.maxStaggerItems]
  /// will appear with the maximum stagger delay.
  static Widget slideUpFadeIn(
    Widget child, {
    int index = 0,
    Duration duration = MotionTokens.t3,
    Curve curve = MotionTokens.standard,
    double slideOffset = 16.0,
  }) {
    final delay = MotionTokens.staggerDelayFor(index);
    return _DelayedFadeSlide(
      delay: delay,
      duration: duration,
      curve: curve,
      slideOffset: slideOffset,
      child: child,
    );
  }

  /// Trigger haptic feedback - light impact
  static void hapticLight() {
    HapticFeedback.lightImpact();
  }

  /// Trigger haptic feedback - medium impact
  static void hapticMedium() {
    HapticFeedback.mediumImpact();
  }

  /// Trigger haptic feedback - selection click
  static void hapticSelection() {
    HapticFeedback.selectionClick();
  }

  /// Trigger haptic feedback - success vibration
  static void hapticSuccess() {
    HapticFeedback.heavyImpact();
  }
}

/// Internal widget that delays then animates fade + slide.
class _DelayedFadeSlide extends StatefulWidget {
  const _DelayedFadeSlide({
    required this.child,
    required this.delay,
    required this.duration,
    required this.curve,
    required this.slideOffset,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double slideOffset;

  @override
  State<_DelayedFadeSlide> createState() => _DelayedFadeSlideState();
}

class _DelayedFadeSlideState extends State<_DelayedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _started = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (MediaQuery.of(context).disableAnimations) {
        _controller.value = 1.0;
      } else {
        _delayTimer = Timer(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: _slide.value,
        child: Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
      ),
      child: widget.child,
    );
  }
}

/// A single-pass shimmer sweep.  Runs [repeatCount] times then stops.
///
/// Use sparingly on CTA buttons, branding logos, or rank badges to draw
/// attention without being distracting.
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.repeatCount = 2,
    this.shimmerColor,
  });

  final Widget child;
  final Duration duration;
  final int repeatCount;
  final Color? shimmerColor;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _completedReps = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completedReps++;
        if (_completedReps < widget.repeatCount) {
          _controller.forward(from: 0);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating &&
        _completedReps < widget.repeatCount) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final color =
                widget.shimmerColor ?? Colors.white.withValues(alpha: 0.3);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                color,
                Colors.transparent,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0, 1),
                _controller.value,
                (_controller.value + 0.3).clamp(0, 1),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

/// A widget that applies staggered fade-in animation to its children.
/// Useful for lists where items should appear one after another.
class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final double slideOffset;
  final Axis direction;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.itemDuration = MotionTokens.t3,
    this.staggerDelay = MotionTokens.staggerDelay,
    this.slideOffset = 16.0,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildren(),
          )
        : Row(
            children: _buildChildren(),
          );
  }

  List<Widget> _buildChildren() {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      final effectiveIndex = index > MotionTokens.maxStaggerItems
          ? MotionTokens.maxStaggerItems
          : index;

      return _StaggeredItem(
        delay: Duration(
          milliseconds: staggerDelay.inMilliseconds * effectiveIndex,
        ),
        duration: itemDuration,
        slideOffset: slideOffset,
        direction: direction,
        child: child,
      );
    }).toList();
  }
}

class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Axis direction;

  const _StaggeredItem({
    required this.child,
    required this.delay,
    required this.duration,
    required this.slideOffset,
    required this.direction,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _started = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.standard),
    );

    final slideBegin = widget.direction == Axis.vertical
        ? Offset(0, widget.slideOffset)
        : Offset(widget.slideOffset, 0);

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.standard),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (MediaQuery.of(context).disableAnimations) {
        _controller.value = 1.0;
      } else {
        _delayTimer = Timer(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A wrapper widget that provides a subtle bounce animation on tap.
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final bool enableHaptic;

  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.enableHaptic = true,
  });

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionTokens.t1,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (MediaQuery.of(context).disableAnimations) {
      return; // skip scale when motion reduced
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.enableHaptic) {
      KhawiMotion.hapticLight();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A widget that pulses to draw attention - use sparingly
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.minScale = 0.97,
    this.maxScale = 1.03,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start or stop pulsing based on current reduce-motion preference.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 0.0; // reset to rest scale
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
