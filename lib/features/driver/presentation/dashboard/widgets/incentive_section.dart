import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/driver/presentation/controllers/driver_dashboard_controller.dart';
import 'package:khawi_flutter/features/trips/presentation/incentive_chip.dart';

class IncentiveSection extends ConsumerWidget {
  const IncentiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incentives = ref
        .watch(driverDashboardControllerProvider.select((s) => s.incentives));
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (incentives.isEmpty) return const SizedBox.shrink();

    final main = incentives.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                isRtl ? "مكافأة ساعة الذروة!" : "Peak Hour Bonus!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IncentiveChip(
                multiplier: main.multiplier,
                reason: main.reasonTag,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? "مفعل في ${main.areaKey}: مضاعف XP ${main.multiplier}x."
                : "Active in ${main.areaKey}: ${main.multiplier}x XP Multiplier.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          if (incentives.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                isRtl
                    ? "+${incentives.length - 1} مناطق أخرى نشطة"
                    : "+${incentives.length - 1} other active zones",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
