import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/notifications/domain/app_notification.dart';
import 'package:rxdart/rxdart.dart';

class NotificationsRepo {
  final SupabaseClient _client;

  NotificationsRepo(this._client);

  /// Watch notifications from xp_events and the notifications table
  Stream<List<AppNotification>> watchNotifications() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);

    // Stream 1: XP Events
    final xpStream = _client
        .from(DbTable.xpEvents)
        .stream(primaryKey: [DbCol.id])
        .eq(DbCol.userId, uid)
        .order(DbCol.createdAt, ascending: false)
        .limit(15)
        .map(
          (rows) => rows.map((row) {
            final source = row['source'] as String? ?? 'bonus';
            final totalXp = row['total_xp'] as int? ?? 0;

            String title;
            String body;
            String type;

            switch (source) {
              case 'trip_completed':
                title = 'Trip Completed! 🚗';
                body = 'You earned $totalXp XP for your ride.';
                type = 'success';
                break;
              case 'request_accepted':
                title = 'Request Accepted! ✅';
                body = 'A driver accepted your ride request. +$totalXp XP';
                type = 'success';
                break;
              case 'referral':
                title = 'Referral Bonus! 🎉';
                body = 'Your friend joined Khawi! You earned $totalXp XP.';
                type = 'info';
                break;
              case 'daily_login':
                title = 'Daily Login Bonus! ⭐';
                body = 'Welcome back! +$totalXp XP for your streak.';
                type = 'info';
                break;
              default:
                title = 'XP Bonus! 🎁';
                body = 'You received $totalXp XP.';
                type = 'info';
            }

            return AppNotification(
              id: row[DbCol.id] as String,
              title: title,
              body: body,
              type: type,
              createdAt: DateTime.parse(row[DbCol.createdAt] as String),
            );
          }).toList(),
        );

    // Stream 2: Dedicated notifications table
    final notifyStream = _client
        .from(DbTable.notifications)
        .stream(primaryKey: [DbCol.id])
        .eq(DbCol.userId, uid)
        .order(DbCol.createdAt, ascending: false)
        .limit(15)
        .map(
          (rows) => rows.map((row) => AppNotification.fromJson(row)).toList(),
        );

    // Combine and sort
    return Rx.combineLatest2<List<AppNotification>, List<AppNotification>,
        List<AppNotification>>(
      xpStream,
      notifyStream,
      _mergeSortedNotifications,
    );
  }

  /// Linear merge of two sorted lists - O(n) instead of O(n log n)
  static List<AppNotification> _mergeSortedNotifications(
    List<AppNotification> xpList,
    List<AppNotification> notifyList,
  ) {
    final merged = <AppNotification>[];
    int i = 0;
    int j = 0;

    // Both lists are sorted by server in DESC order
    while (i < xpList.length && j < notifyList.length && merged.length < 20) {
      final xpTime = xpList[i].createdAt;
      final notifyTime = notifyList[j].createdAt;

      if (xpTime.compareTo(notifyTime) >= 0) {
        merged.add(xpList[i++]);
      } else {
        merged.add(notifyList[j++]);
      }
    }

    // Add remaining from either list
    while (i < xpList.length && merged.length < 20) {
      merged.add(xpList[i++]);
    }
    while (j < notifyList.length && merged.length < 20) {
      merged.add(notifyList[j++]);
    }

    return merged;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client
          .from(DbTable.notifications)
          .update({DbCol.isRead: true}).eq(DbCol.id, id);
    } catch (_) {
      // Ignore errors if notification is from xp_events (not in notifications table)
    }
  }

  Future<void> markAllAsRead() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    await _client
        .from(DbTable.notifications)
        .update({DbCol.isRead: true}).eq(DbCol.userId, uid);
  }
}

final notificationsRepoProvider =
    Provider((ref) => NotificationsRepo(Supabase.instance.client));

final notificationsProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepoProvider).watchNotifications();
});
