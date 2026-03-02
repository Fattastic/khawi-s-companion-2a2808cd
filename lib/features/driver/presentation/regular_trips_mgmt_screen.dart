import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/driver/presentation/widgets/create_recurring_trip_dialog.dart';

class RegularTripsMgmtScreen extends ConsumerWidget {
  const RegularTripsMgmtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userIdProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final tripsStream = ref.watch(tripsRepoProvider).watchMyRecurringTrips(uid);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(title: const Text('Regular Trips')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRecurringTrip(context, ref, uid),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Trip>>(
        stream: tripsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final trips = snapshot.data!;
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          if (trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_repeat,
                      size: 80,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isRtl ? 'لا توجد رحلات منتظمة' : 'No regular trips',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRtl
                          ? 'أنشئ رحلة أسبوعية للتنقل اليومي'
                          : 'Create a weekly commute trip',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () =>
                          _showCreateRecurringTrip(context, ref, uid),
                      icon: const Icon(Icons.add),
                      label: Text(
                        isRtl ? 'أنشئ رحلة منتظمة' : 'Create Regular Trip',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, i) {
              final t = trips[i];
              final schedule = _formatSchedule(t.scheduleJson);
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: ListTile(
                  title: Text(
                    '${t.originLabel ?? 'Origin'} → ${t.destLabel ?? 'Destination'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    schedule ?? 'Weekly',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, t.id),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: trips.length,
          );
        },
      ),
    );
  }

  static String? _formatSchedule(Map<String, dynamic>? schedule) {
    if (schedule == null) return null;
    final type = schedule['type'];
    if (type != 'weekly') return null;
    final days = (schedule['days'] as List?)?.cast<int>() ?? const <int>[];
    final time = schedule['time'] as String?;
    if (days.isEmpty && time == null) return null;
    final dayNames = days.map(_weekdayName).join(', ');
    if (time != null && dayNames.isNotEmpty) return '$dayNames • $time';
    if (time != null) return time;
    return dayNames;
  }

  static String _weekdayName(int d) {
    return switch (d) {
      1 => 'Mon',
      2 => 'Tue',
      3 => 'Wed',
      4 => 'Thu',
      5 => 'Fri',
      6 => 'Sat',
      7 => 'Sun',
      _ => 'Day',
    };
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String tripId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete regular trip?'),
        content:
            const Text('This removes the recurring trip from your schedule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(tripsRepoProvider).deleteTrip(tripId);
  }

  static Future<void> _showCreateRecurringTrip(
    BuildContext context,
    WidgetRef ref,
    String driverId,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (ctx) => CreateRecurringTripDialog(driverId: driverId),
    );
  }
}
