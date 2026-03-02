import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/events/domain/khawi_event.dart';

void main() {
  final now = DateTime(2026, 2, 16, 14, 30);
  final nowIso = now.toIso8601String();

  group('EventCategory', () {
    test('fromString returns matching category', () {
      expect(
        EventCategory.fromString('entertainment'),
        EventCategory.entertainment,
      );
      expect(EventCategory.fromString('sports'), EventCategory.sports);
      expect(EventCategory.fromString('religious'), EventCategory.religious);
      expect(EventCategory.fromString('education'), EventCategory.education);
      expect(EventCategory.fromString('business'), EventCategory.business);
      expect(EventCategory.fromString('community'), EventCategory.community);
    });

    test('fromString defaults to other for unknown', () {
      expect(EventCategory.fromString('unknown'), EventCategory.other);
      expect(EventCategory.fromString(null), EventCategory.other);
    });

    test('label returns Arabic for ar locale', () {
      expect(EventCategory.sports.label('ar'), 'رياضة');
      expect(EventCategory.entertainment.label('ar'), 'ترفيه');
    });

    test('label returns English for en locale', () {
      expect(EventCategory.sports.label('en'), 'Sports');
    });

    test('emoji returns unique emoji per category', () {
      final emojis = EventCategory.values.map((c) => c.emoji).toSet();
      expect(emojis.length, EventCategory.values.length);
      expect(EventCategory.sports.emoji, '⚽');
      expect(EventCategory.religious.emoji, '🕌');
    });
  });

  group('KhawiEvent', () {
    final json = <String, dynamic>{
      'id': 'e1',
      'title': 'Saudi Pro League Final',
      'title_ar': 'نهائي دوري روشن',
      'description': 'Big match',
      'category': 'sports',
      'venue_name': 'King Fahd Stadium',
      'venue_lat': 24.72,
      'venue_lng': 46.63,
      'start_time': '2026-02-16T20:00:00.000',
      'end_time': '2026-02-16T23:00:00.000',
      'image_url': 'https://img.co/match.jpg',
      'organizer': 'SPL',
      'is_featured': true,
      'is_active': true,
      'expected_attendance': 55000,
      'ride_count': 120,
      'metadata': <String, dynamic>{'teams': 'AlHilal v AlNassr'},
      'created_by': 'admin1',
      'created_at': nowIso,
    };

    test('fromJson parses all fields', () {
      final e = KhawiEvent.fromJson(json);
      expect(e.id, 'e1');
      expect(e.title, 'Saudi Pro League Final');
      expect(e.category, EventCategory.sports);
      expect(e.venueName, 'King Fahd Stadium');
      expect(e.isFeatured, true);
      expect(e.expectedAttendance, 55000);
      expect(e.rideCount, 120);
      expect(e.endTime, isNotNull);
    });

    test('fromJson uses defaults for optional fields', () {
      final minimal = <String, dynamic>{
        'id': 'e2',
        'title': 'Minimal Event',
        'start_time': nowIso,
        'created_at': nowIso,
      };
      final e = KhawiEvent.fromJson(minimal);
      expect(e.category, EventCategory.other); // fromString(null) → other
      expect(e.isFeatured, false);
      expect(e.isActive, true);
      expect(e.expectedAttendance, 0);
      expect(e.rideCount, 0);
      expect(e.endTime, isNull);
    });

    test('toJson round-trips all fields', () {
      final e = KhawiEvent.fromJson(json);
      final out = e.toJson();
      expect(out['title'], 'Saudi Pro League Final');
      expect(out['category'], 'sports');
      expect(out['expected_attendance'], 55000);
    });

    test('toInsertJson excludes id and created_at', () {
      final e = KhawiEvent.fromJson(json);
      final ins = e.toInsertJson();
      expect(ins.containsKey('id'), false);
      expect(ins.containsKey('created_at'), false);
      expect(ins['title'], 'Saudi Pro League Final');
      expect(ins['venue_name'], 'King Fahd Stadium');
    });

    test('displayTitle returns Arabic when locale is ar', () {
      final e = KhawiEvent.fromJson(json);
      expect(e.displayTitle('ar'), 'نهائي دوري روشن');
      expect(e.displayTitle('en'), 'Saudi Pro League Final');
    });

    test('displayTitle falls back to title when titleAr missing', () {
      final e = KhawiEvent.fromJson({...json, 'title_ar': null});
      expect(e.displayTitle('ar'), 'Saudi Pro League Final');
    });

    test('formattedDate returns YYYY-MM-DD', () {
      final e = KhawiEvent.fromJson(json);
      expect(e.formattedDate, '2026-02-16');
    });

    test('formattedTime returns 12h with AM/PM', () {
      final e = KhawiEvent.fromJson(json);
      expect(e.formattedTime, '8:00 PM');
    });

    test('formattedTime handles noon', () {
      final e = KhawiEvent.fromJson({
        ...json,
        'start_time': '2026-02-16T12:30:00.000',
      });
      expect(e.formattedTime, '12:30 PM');
    });

    test('formattedTime handles midnight', () {
      final e = KhawiEvent.fromJson({
        ...json,
        'start_time': '2026-02-16T00:15:00.000',
      });
      expect(e.formattedTime, '12:15 AM');
    });

    group('isUpcoming / isLive', () {
      test('event with endTime in future is upcoming', () {
        final e = KhawiEvent.fromJson({
          ...json,
          'start_time':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'end_time':
              DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
        });
        expect(e.isUpcoming, true);
      });

      test('event with endTime in past is not upcoming', () {
        final e = KhawiEvent.fromJson({
          ...json,
          'start_time': DateTime.now()
              .subtract(const Duration(hours: 10))
              .toIso8601String(),
          'end_time': DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        });
        expect(e.isUpcoming, false);
      });

      test('event currently running is live', () {
        final e = KhawiEvent.fromJson({
          ...json,
          'start_time': DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
          'end_time':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        });
        expect(e.isLive, true);
      });

      test('future event is not live', () {
        final e = KhawiEvent.fromJson({
          ...json,
          'start_time':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'end_time':
              DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
        });
        expect(e.isLive, false);
      });
    });
  });

  group('EventRideDirection', () {
    test('fromString parses to and from', () {
      expect(EventRideDirection.fromString('from'), EventRideDirection.from);
      expect(EventRideDirection.fromString('to'), EventRideDirection.to);
      expect(EventRideDirection.fromString(null), EventRideDirection.to);
    });

    test('label returns locale-aware text', () {
      expect(EventRideDirection.to.label('ar'), 'ذهاب');
      expect(EventRideDirection.from.label('en'), 'Returning');
    });
  });

  group('EventRide', () {
    test('fromJson parses all fields', () {
      final r = EventRide.fromJson({
        'id': 'er1',
        'event_id': 'e1',
        'trip_id': 't1',
        'direction': 'from',
        'posted_by': 'u1',
        'seats_offered': 3,
        'message': 'Leaving after the match',
        'created_at': nowIso,
      });
      expect(r.direction, EventRideDirection.from);
      expect(r.seatsOffered, 3);
      expect(r.message, 'Leaving after the match');
    });

    test('fromJson defaults seats to 1', () {
      final r = EventRide.fromJson({
        'id': 'er2',
        'event_id': 'e1',
        'trip_id': 't2',
        'posted_by': 'u2',
        'created_at': nowIso,
      });
      expect(r.seatsOffered, 1);
      expect(r.direction, EventRideDirection.to);
    });
  });

  group('EventInterestStatus', () {
    test('fromString parses correctly', () {
      expect(
        EventInterestStatus.fromString('going'),
        EventInterestStatus.going,
      );
      expect(
        EventInterestStatus.fromString('interested'),
        EventInterestStatus.interested,
      );
      expect(
        EventInterestStatus.fromString(null),
        EventInterestStatus.interested,
      );
    });
  });

  group('EventInterest', () {
    test('fromJson parses all fields', () {
      final i = EventInterest.fromJson({
        'event_id': 'e1',
        'user_id': 'u1',
        'status': 'going',
        'needs_ride': false,
        'created_at': nowIso,
      });
      expect(i.status, EventInterestStatus.going);
      expect(i.needsRide, false);
    });
  });
}
