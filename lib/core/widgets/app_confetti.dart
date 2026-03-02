import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// A reusable overlay component that triggers a celebratory confetti animation
/// when successfully claiming a reward, leveling up, or finishing a long trip.
class AppConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final Duration duration;

  const AppConfettiOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AppConfettiOverlay> createState() => _AppConfettiOverlayState();
}

class _AppConfettiOverlayState extends State<AppConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: widget.duration);
    if (widget.isPlaying) {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(AppConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.play();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Addictive golden glow effect
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: widget.isPlaying ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    AppTheme.accentGold.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 40,
            maxBlastForce: 100,
            minBlastForce: 70,
            gravity: 0.25,
            colors: const [
              AppTheme.primaryGreen,
              AppTheme.driverAccent,
              AppTheme.accentGold,
              Colors.red,
              Colors.purple,
              Colors.orange,
              Colors.blue,
            ],
          ),
        ),
      ],
    );
  }
}
