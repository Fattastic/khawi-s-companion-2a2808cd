import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/carbon/domain/carbon_summary.dart';
import 'package:khawi_flutter/state/providers.dart';

final _carbonSummaryProvider = FutureProvider.autoDispose<CarbonSummary>((ref) {
  return ref.watch(carbonRepoProvider).fetchMySummary();
});

class CarbonTrackerScreen extends ConsumerWidget {
  const CarbonTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final summaryAsync = ref.watch(_carbonSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'أثر الرحلات البيئي' : 'Carbon Tracker'),
      ),
      body: summaryAsync.when(
        data: (summary) => _buildContent(context, ref, summary, isRtl),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isRtl
                  ? 'تعذر تحميل بيانات الأثر'
                  : 'Could not load impact data',),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => ref.invalidate(_carbonSummaryProvider),
                child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CarbonSummary summary,
    bool isRtl,
  ) {
    final localeName = isRtl ? 'ar' : 'en';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _metricCard(
          context,
          title: isRtl ? 'إجمالي CO₂ الموفّر' : 'Total CO₂ Saved',
          value: '${summary.totalCo2SavedKg.toStringAsFixed(1)} kg',
          icon: Icons.eco_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                title: isRtl ? 'الرحلات المكتملة' : 'Completed Trips',
                value: summary.tripsCount.toString(),
                icon: Icons.route_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                context,
                title: isRtl ? 'متوسط التوفير/رحلة' : 'Avg Saved/Trip',
                value: '${summary.averageCo2PerTripKg.toStringAsFixed(2)} kg',
                icon: Icons.insights_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _metricCard(
          context,
          title: isRtl ? 'مكافئ الأشجار (شهر)' : 'Tree-Absorption Equivalent',
          value: '${summary.equivalentTreeMonths.toStringAsFixed(1)} months',
          icon: Icons.park_outlined,
          subtitle: isRtl
              ? 'تقدير تقريبي مبني على متوسط امتصاص الشجرة السنوي.'
              : 'Approximate estimate based on average yearly tree absorption.',
        ),
        const SizedBox(height: 20),
        Text(
          isRtl ? 'آخر الرحلات ذات الأثر البيئي' : 'Recent Impact Trips',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (summary.recentImpacts.isEmpty)
          Text(
            isRtl
                ? 'لا توجد رحلات مكتملة تحتوي على أثر بيئي بعد.'
                : 'No completed trips with environmental impact yet.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondary),
          )
        else
          ...summary.recentImpacts.map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.eco, color: AppTheme.primaryGreen),
                title: Text('${entry.co2SavedKg.toStringAsFixed(1)} kg CO₂'),
                subtitle: Text(
                  '${entry.originLabel ?? (isRtl ? 'انطلاق' : 'Origin')} → ${entry.destLabel ?? (isRtl ? 'وصول' : 'Destination')}\n${DateFormat.yMMMd(localeName).add_jm().format(entry.departureTime)}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
