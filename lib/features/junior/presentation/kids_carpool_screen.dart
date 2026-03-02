import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

/// 1:1 counterpart to the TS "KidsCarpoolScreen".
///
/// The main junior experience is implemented in the hub; this screen provides
/// a dedicated entry point for the "Kids Carpool" concept.
class KidsCarpoolScreen extends StatelessWidget {
  const KidsCarpoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'توصيل الأطفال' : 'Kids Carpool'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRtl ? 'مركز توصيل الأطفال' : 'Kids Carpool Hub',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRtl
                        ? 'إدارة السائقين المعيّنين، تتبع الرحلات، وكسب المكافآت.'
                        : 'Manage appointed drivers, track runs, and earn rewards.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => context.go(Routes.juniorHub),
                icon: const Icon(Icons.dashboard_outlined),
                label: Text(isRtl ? 'افتح مركز الولي' : 'Open Guardian Hub'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.juniorAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => context.push(Routes.juniorAddDriver),
                icon: const Icon(Icons.family_restroom),
                label: Text(isRtl ? 'إضافة سائق عائلي' : 'Add Family Driver'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => context.push(Routes.juniorRewards),
                icon: const Icon(Icons.emoji_events_outlined),
                label: Text(isRtl ? 'مكافآت الأطفال' : 'Kids Rewards'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              isRtl
                  ? 'ملاحظة: هذا الشاشة تضيف مدخلًا مخصصًا لتوصيل الأطفال؛ التجربة الأساسية موجودة داخل مركز الولي.'
                  : 'Note: this screen is a dedicated entry point; the full experience lives in the Guardian Hub.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textTertiary),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
