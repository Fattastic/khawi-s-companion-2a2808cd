import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/driver/presentation/controllers/driver_dashboard_controller.dart';

class OnlineStatusSection extends ConsumerWidget {
  const OnlineStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(
      driverDashboardControllerProvider
          .select((DriverDashboardState s) => s.isOnline),
    );
    final controller = ref.read(driverDashboardControllerProvider.notifier);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.success : AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isOnline
                ? (isRtl ? "أنت متصل" : "You are Online")
                : (isRtl ? "أنت غير متصل" : "You are Offline"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Switch(
            value: isOnline,
            onChanged: (_) => controller.toggleOnline(),
            // ignore: deprecated_member_use
            // ignore: deprecated_member_use
            activeColor: AppTheme.driverAccent,
          ),
        ],
      ),
    );
  }
}
