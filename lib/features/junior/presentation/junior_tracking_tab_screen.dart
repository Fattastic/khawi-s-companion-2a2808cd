import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_providers.dart';

class JuniorTrackingTabScreen extends ConsumerWidget {
  const JuniorTrackingTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(myJuniorRunsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(title: Text(l10n?.juniorTrackRuns ?? 'Track runs')),
      body: runsAsync.when(
        data: (runs) {
          final active = runs
              .where(
                (r) => r.status != 'completed' && r.status != 'cancelled',
              )
              .toList();

          if (active.isEmpty) {
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.gps_off,
                      size: 80,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n?.juniorNoActiveRuns ??
                          (isRtl ? 'لا توجد رحلات نشطة' : 'No active runs'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.juniorCreateRunWithHub ??
                          (isRtl
                              ? 'أنشئ رحلة من المركز وشارك كود الدعوة مع السائق'
                              : 'Create one from the Hub, then share an invite code with your Family Driver.'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => context.go(Routes.juniorHub),
                      icon: const Icon(Icons.add_circle),
                      label: Text(
                        l10n?.juniorGoToHub ??
                            (isRtl ? 'انتقل للمركز' : 'Go to Hub'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final r = active[i];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  title: Text(
                    'Status: ${r.status}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Pickup: ${r.pickupTime.toLocal().toString().split(".").first}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.liveJuniorPath(r.id)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
