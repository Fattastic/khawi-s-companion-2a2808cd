import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';

/// Custom page transitions for a polished, professional feel.
///
/// Usage with GoRouter:
/// ```dart
/// GoRoute(
///   path: '/example',
///   pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
///     context: context,
///     state: state,
///     child: ExampleScreen(),
///   ),
/// )
/// ```
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade through transition - content fades out then fades in
  /// Best for: navigation between unrelated content
  static CustomTransitionPage<T> fadeThrough<T>({
    required BuildContext context,
    required LocalKey key,
    required Widget child,
    Duration duration = MotionTokens.t3,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
          child: child,
        );
      },
    );
  }

  /// Shared axis transition (horizontal) - content slides horizontally
  /// Best for: stepping through a flow (onboarding, wizards)
  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = MotionTokens.t3,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.25, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (vertical) - content slides vertically
  /// Best for: parent-child navigation, drilling into detail views
  static CustomTransitionPage<T> sharedAxisVertical<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = MotionTokens.t3,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition - content scales up while fading in
  /// Best for: dialogs, modals, overlays
  static CustomTransitionPage<T> scale<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = MotionTokens.t3,
    double beginScale = 0.92,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: beginScale,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// No transition - instant switch
  /// Best for: tab switches within the same shell
  static CustomTransitionPage<T> none<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// iOS-style slide transition
  /// Best for: pushing detail views on iOS-like navigation
  static CustomTransitionPage<T> cupertino<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = MotionTokens.t3,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: MotionTokens.standard,
          ),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
