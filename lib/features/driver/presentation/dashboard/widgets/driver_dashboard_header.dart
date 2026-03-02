import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/profile/presentation/trust_badge.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

class DriverDashboardHeader extends ConsumerWidget {
  const DriverDashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.driverAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.driverGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: KhawiMotion.fadeIn(
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAsync.when(
                    data: (p) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl
                              ? 'كابتن ${p.fullName.split(' ')[0]}'
                              : 'Captain ${p.fullName.split(' ')[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (p.trustBadge != null)
                          TrustBadge(
                            score: (p.trustScore ?? 50).toInt(),
                            badge: p.trustBadge!,
                            isJuniorTrusted: p.isVerified,
                          )
                        else
                          Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRtl ? 'سائق جديد' : 'New Driver',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                      ],
                    ),
                    loading: () => const SizedBox(),
                    error: (err, stack) => Text(
                      isRtl ? 'كابتن' : 'Captain',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  profileAsync.when(
                    data: (p) => Text(
                      '${p.totalXp} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const SizedBox(height: 40),
                    error: (_, __) => const Text(
                      '0 XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'Community XP',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
