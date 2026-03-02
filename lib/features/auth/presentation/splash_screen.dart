import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// Passive splash screen - shows branding while router decides destination.
/// The router's redirect logic handles all navigation decisions based on:
/// - Auth session state
/// - Onboarding completion
/// - Profile existence
/// - User role
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Logo: fade + scale in [0.0 – 0.45]
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // Tagline: fade + slide up in [0.35 – 0.65]
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutQuart),
      ),
    );

    // Loader: fade in at [0.55 – 0.80]
    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundGreen,
              Color(0xFFECFDF5),
              Color(0xFFCCFBF1),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with shimmer and float
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: ShimmerEffect(
                        duration: MotionTokens.t6 * 2,
                        repeatCount: 2,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 3),
                          curve: Curves.easeInOutSine,
                          builder: (context, val, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                10 * (0.5 - (0.5 - val).abs()),
                              ), // Smooth up and down
                              child: child,
                            );
                          },
                          onEnd: () {
                            // Can't loop easily without custom controller here,
                            // but splash screen is short-lived. A 3-second float covers the duration well.
                          },
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline stagger
                  Transform.translate(
                    offset: _taglineSlide.value,
                    child: Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        isRtl
                            ? 'تنقل ذكي. مجتمعي.'
                            : 'Smart. Community. Rides.',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryGreenDark,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Delayed loader
                  Opacity(
                    opacity: _loaderFade.value,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.primaryGreen.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
