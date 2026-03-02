import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/state/providers.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userIdProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Text(isRtl ? 'غير مسجل دخول' : 'Not authenticated'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(title: Text(isRtl ? 'رحلاتي' : 'My Trips')),
      body: _MyTripsBody(uid: uid),
    );
  }

  static Widget? _buildTrailing(
    BuildContext context,
    WidgetRef ref,
    TripRequest r,
  ) {
    if (r.status == RequestStatus.pending) {
      return TextButton(
        onPressed: () async {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          try {
            await ref.read(requestsRepoProvider).cancelJoinRequest(r.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isRtl ? 'تم إلغاء الطلب' : 'Request cancelled',
                ),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isRtl ? 'فشل الإلغاء: $e' : 'Failed: $e')),
            );
          }
        },
        child: Text(
          Directionality.of(context) == TextDirection.rtl ? 'إلغاء' : 'Cancel',
        ),
      );
    }
    if (r.status == RequestStatus.accepted) {
      return const Icon(Icons.chevron_right);
    }
    return Text(
      _statusLabel(r.status, Directionality.of(context) == TextDirection.rtl),
      style: const TextStyle(color: AppTheme.textSecondary),
    );
  }
}

class _MyTripsBody extends ConsumerWidget {
  const _MyTripsBody({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sentAsync = ref.watch(_sentRequestsProvider(uid));
    return sentAsync.when(
      data: (reqs) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        if (reqs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isRtl ? 'لا توجد رحلات بعد' : 'No trips yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRtl
                        ? 'ابحث عن رحلات واطلب الانضمام'
                        : 'Search rides and request to join.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.go(Routes.passengerSearch),
                    icon: const Icon(Icons.search),
                    label: Text(isRtl ? 'ابحث عن رحلة' : l10n.findRide),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go(Routes.passengerHome),
                    icon: const Icon(Icons.home),
                    label: Text(isRtl ? 'الرئيسية' : 'Home'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final r = reqs[i];
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
                    Icons.directions_car,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                title: Text(
                  '${isRtl ? 'الطلب' : 'Request'}: ${_statusLabel(r.status, isRtl)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${isRtl ? 'الرحلة' : 'Trip'}: ${r.tripId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: MyTripsScreen._buildTrailing(context, ref, r),
                onTap: r.status == RequestStatus.accepted
                    ? () => context.push(
                          Routes.livePassenger.replaceFirst(
                            ':tripId',
                            r.tripId,
                          ),
                        )
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          Directionality.of(context) == TextDirection.rtl
              ? 'حدث خطأ: $e'
              : 'Error: $e',
        ),
      ),
    );
  }
}

final _sentRequestsProvider = StreamProvider.family<List<TripRequest>, String>(
  (ref, uid) => ref.watch(requestsRepoProvider).watchSent(uid),
);

String _statusLabel(RequestStatus s, bool isRtl) => switch (s) {
      RequestStatus.pending => isRtl ? 'قيد الانتظار' : 'Pending',
      RequestStatus.accepted => isRtl ? 'مقبول' : 'Accepted',
      RequestStatus.declined => isRtl ? 'مرفوض' : 'Declined',
      RequestStatus.cancelled => isRtl ? 'ملغي' : 'Cancelled',
      RequestStatus.expired => isRtl ? 'منتهي' : 'Expired',
      RequestStatus.pickedUp => isRtl ? 'تم الالتقاط' : 'Picked Up',
      RequestStatus.droppedOff => isRtl ? 'تم الإنزال' : 'Dropped Off',
      RequestStatus.completed => isRtl ? 'مكتمل' : 'Completed',
    };
