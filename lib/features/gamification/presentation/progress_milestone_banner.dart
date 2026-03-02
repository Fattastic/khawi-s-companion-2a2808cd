import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Lightweight milestone feedback banner for home surfaces.
///
/// It reacts to XP increases and shows a brief non-blocking message.
class ProgressMilestoneBanner extends ConsumerStatefulWidget {
  const ProgressMilestoneBanner({super.key, required this.isRtl});

  final bool isRtl;

  @override
  ConsumerState<ProgressMilestoneBanner> createState() =>
      _ProgressMilestoneBannerState();
}

class _ProgressMilestoneBannerState
    extends ConsumerState<ProgressMilestoneBanner> {
  int? _lastXp;
  String? _message;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    _hideTimer?.cancel();
    setState(() => _message = message);
    _hideTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.asData?.value;
    final currentXp = profile?.totalXp;

    if (currentXp != null) {
      final previousXp = _lastXp;
      if (previousXp != null && currentXp > previousXp) {
        final delta = currentXp - previousXp;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showMessage(
            widget.isRtl ? '+$delta نقطة XP جديدة' : '+$delta XP gained',
          );
        });
      }
      _lastXp = currentXp;
    }

    return RepaintBoundary(
      child: AnimatedSize(
        duration: duration,
        alignment: Alignment.centerLeft,
        curve: Curves.easeOutCubic,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _message == null
              ? const SizedBox.shrink(key: ValueKey('milestone_empty'))
              : Container(
                  key: ValueKey(_message),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _message!,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
