import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Centralized tokens for Khawi's "Balanced" motion system.
///
/// Philosophy:
/// - Swift and responsive
/// - Calm, premium, and reassuring
/// - A little friendly
/// - Never arcade-like or exaggerated
class MotionTokens {
  MotionTokens._();

  // ─────────────────────────────────────────────────────────────────
  // DURATIONS
  // ─────────────────────────────────────────────────────────────────

  /// Tap feedback, tiny UI changes (90-120ms)
  static const Duration t1 = Duration(milliseconds: 100);

  /// Small transitions, chip selection, checkbox toggle (140-180ms)
  static const Duration t2 = Duration(milliseconds: 160);

  /// Route transitions, sheets, dialogs (200-260ms)
  static const Duration t3 = Duration(milliseconds: 240);

  /// Celebratory, success states (280-360ms) - Use sparingly
  static const Duration t4 = Duration(milliseconds: 320);

  /// Long transitions, complex animations (400-500ms)
  static const Duration t5 = Duration(milliseconds: 450);

  /// Entrance choreography, splash sequences (550-650ms)
  static const Duration t6 = Duration(milliseconds: 600);

  // ─────────────────────────────────────────────────────────────────
  // CURVES
  // ─────────────────────────────────────────────────────────────────

  /// Standard smooth ease-out (Primary)
  /// Used for most incoming elements.
  static const Curve standard = Curves.easeOutQuart;

  /// Emphasized ease-in-out
  /// Used for major navigation transitions or functional state changes.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Subtle spring (Low bounce)
  /// Used for small interactions like button presses or toggle switches.
  /// Not bouncy, just responsive.
  static const Curve springLite = SpringCurve.force;

  /// Linear for things like opacity fades that happen alongside other motion
  static const Curve linear = Curves.linear;

  /// Decelerate - for elements leaving the screen
  static const Curve decelerate = Curves.decelerate;

  /// Anticipate - subtle ease-in before the main motion
  static const Curve anticipate = Curves.easeInQuart;

  /// Playful entrance - slight overshoot for scale-in effects
  static const Curve entrance = Curves.easeOutBack;

  // ─────────────────────────────────────────────────────────────────
  // STAGGER DELAYS
  // ─────────────────────────────────────────────────────────────────

  /// Delay between staggered list items (subtle)
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Max stagger delay (caps at 5 items to avoid long waits)
  static const int maxStaggerItems = 5;

  /// Calculate stagger delay for an item at index
  static Duration staggerDelayFor(int index) {
    final effectiveIndex = index > maxStaggerItems ? maxStaggerItems : index;
    return Duration(milliseconds: staggerDelay.inMilliseconds * effectiveIndex);
  }
}

/// A custom spring curve that provides a premium, subtle bounce.
/// This avoids the excessive bounciness of `Curves.elasticOut`.
class SpringCurve extends Curve {
  const SpringCurve._({
    this.a = 0.15,
    this.w = 19.4,
  });

  final double a;
  final double w;

  static const Curve force = SpringCurve._(a: 0.15, w: 19.4);
  static const Curve bouncy = SpringCurve._(a: 0.25, w: 16.0);

  @override
  double transformInternal(double t) {
    // Standard dampened sine wave representing a spring landing at 1.0.
    return -(math.pow(math.e, -t / a) * math.cos(t * w)) + 1;
  }
}
