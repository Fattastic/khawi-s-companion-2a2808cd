/// Event model for Khawi Event Rides.
///
/// Events represent real-world gatherings (concerts, matches, conferences)
/// that generate traffic congestion. Users can offer/find rides to/from events.
library;

/// Category of event.
enum EventCategory {
  entertainment('entertainment', 'ترفيه', 'Entertainment'),
  sports('sports', 'رياضة', 'Sports'),
  religious('religious', 'ديني', 'Religious'),
  education('education', 'تعليمي', 'Education'),
  business('business', 'أعمال', 'Business'),
  community('community', 'مجتمعي', 'Community'),
  other('other', 'أخرى', 'Other');

  final String key;
  final String labelAr;
  final String labelEn;

  const EventCategory(this.key, this.labelAr, this.labelEn);

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;

  static EventCategory fromString(String? s) => EventCategory.values.firstWhere(
        (e) => e.key == s,
        orElse: () => EventCategory.other,
      );

  /// Emoji icon per category.
  String get emoji => switch (this) {
        EventCategory.entertainment => '🎉',
        EventCategory.sports => '⚽',
        EventCategory.religious => '🕌',
        EventCategory.education => '📚',
        EventCategory.business => '💼',
        EventCategory.community => '🤝',
        EventCategory.other => '📌',
      };
}

/// A real-world event that generates ride demand.
class KhawiEvent {
  final String id;
  final String title;
  final String? titleAr;
  final String? description;
  final EventCategory category;
  final String? venueName;
  final double? venueLat;
  final double? venueLng;
  final DateTime startTime;
  final DateTime? endTime;
  final String? imageUrl;
  final String? organizer;
  final bool isFeatured;
  final bool isActive;
  final int expectedAttendance;
  final int rideCount;
  final Map<String, dynamic> metadata;
  final String? createdBy;
  final DateTime createdAt;

  const KhawiEvent({
    required this.id,
    required this.title,
    this.titleAr,
    this.description,
    this.category = EventCategory.entertainment,
    this.venueName,
    this.venueLat,
    this.venueLng,
    required this.startTime,
    this.endTime,
    this.imageUrl,
    this.organizer,
    this.isFeatured = false,
    this.isActive = true,
    this.expectedAttendance = 0,
    this.rideCount = 0,
    this.metadata = const {},
    this.createdBy,
    required this.createdAt,
  });

  factory KhawiEvent.fromJson(Map<String, dynamic> j) => KhawiEvent(
        id: j['id'] as String,
        title: j['title'] as String,
        titleAr: j['title_ar'] as String?,
        description: j['description'] as String?,
        category: EventCategory.fromString(j['category'] as String?),
        venueName: j['venue_name'] as String?,
        venueLat: (j['venue_lat'] as num?)?.toDouble(),
        venueLng: (j['venue_lng'] as num?)?.toDouble(),
        startTime: DateTime.parse(j['start_time'] as String),
        endTime: j['end_time'] != null
            ? DateTime.parse(j['end_time'] as String)
            : null,
        imageUrl: j['image_url'] as String?,
        organizer: j['organizer'] as String?,
        isFeatured: (j['is_featured'] as bool?) ?? false,
        isActive: (j['is_active'] as bool?) ?? true,
        expectedAttendance: (j['expected_attendance'] as int?) ?? 0,
        rideCount: (j['ride_count'] as int?) ?? 0,
        metadata: (j['metadata'] as Map<String, dynamic>?) ?? const {},
        createdBy: j['created_by'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_ar': titleAr,
        'description': description,
        'category': category.key,
        'venue_name': venueName,
        'venue_lat': venueLat,
        'venue_lng': venueLng,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'image_url': imageUrl,
        'organizer': organizer,
        'is_featured': isFeatured,
        'is_active': isActive,
        'expected_attendance': expectedAttendance,
        'ride_count': rideCount,
        'metadata': metadata,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };

  /// JSON shape for insert (server generates id + created_at).
  Map<String, dynamic> toInsertJson() => {
        'title': title,
        if (titleAr != null) 'title_ar': titleAr,
        if (description != null) 'description': description,
        'category': category.key,
        if (venueName != null) 'venue_name': venueName,
        if (venueLat != null) 'venue_lat': venueLat,
        if (venueLng != null) 'venue_lng': venueLng,
        'start_time': startTime.toIso8601String(),
        if (endTime != null) 'end_time': endTime!.toIso8601String(),
        if (imageUrl != null) 'image_url': imageUrl,
        if (organizer != null) 'organizer': organizer,
        'is_featured': isFeatured,
        if (expectedAttendance > 0) 'expected_attendance': expectedAttendance,
        'created_by': createdBy,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  /// Display title respecting locale.
  String displayTitle(String locale) {
    if (locale == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  /// Whether the event is upcoming (hasn't ended yet).
  bool get isUpcoming {
    final now = DateTime.now();
    if (endTime != null) return endTime!.isAfter(now);
    return startTime.isAfter(now.subtract(const Duration(hours: 6)));
  }

  /// Whether the event is happening right now.
  bool get isLive {
    final now = DateTime.now();
    if (endTime == null) {
      return startTime.isBefore(now) &&
          startTime.isAfter(now.subtract(const Duration(hours: 6)));
    }
    return startTime.isBefore(now) && endTime!.isAfter(now);
  }

  /// Formatted date string.
  String get formattedDate {
    final d = startTime;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Formatted time string.
  String get formattedTime {
    final h = startTime.hour;
    final m = startTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }
}

/// Direction of an event ride.
enum EventRideDirection {
  to('to', 'ذهاب', 'Going'),
  from('from', 'عودة', 'Returning');

  final String key;
  final String labelAr;
  final String labelEn;

  const EventRideDirection(this.key, this.labelAr, this.labelEn);

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;

  static EventRideDirection fromString(String? s) =>
      s == 'from' ? EventRideDirection.from : EventRideDirection.to;
}

/// A ride linked to a specific event.
class EventRide {
  final String id;
  final String eventId;
  final String tripId;
  final EventRideDirection direction;
  final String postedBy;
  final int seatsOffered;
  final String? message;
  final DateTime createdAt;

  /// Joined trip data.
  final Map<String, dynamic>? tripData;

  /// Joined poster profile data.
  final Map<String, dynamic>? posterData;

  const EventRide({
    required this.id,
    required this.eventId,
    required this.tripId,
    this.direction = EventRideDirection.to,
    required this.postedBy,
    this.seatsOffered = 1,
    this.message,
    required this.createdAt,
    this.tripData,
    this.posterData,
  });

  factory EventRide.fromJson(Map<String, dynamic> j) => EventRide(
        id: j['id'] as String,
        eventId: j['event_id'] as String,
        tripId: j['trip_id'] as String,
        direction: EventRideDirection.fromString(j['direction'] as String?),
        postedBy: j['posted_by'] as String,
        seatsOffered: (j['seats_offered'] as int?) ?? 1,
        message: j['message'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        tripData: j['trips'] as Map<String, dynamic>?,
        posterData: j['profiles'] as Map<String, dynamic>?,
      );
}

/// User interest in an event.
enum EventInterestStatus {
  interested('interested'),
  going('going');

  final String key;
  const EventInterestStatus(this.key);

  static EventInterestStatus fromString(String? s) =>
      s == 'going' ? EventInterestStatus.going : EventInterestStatus.interested;
}

/// A user's interest in an event.
class EventInterest {
  final String eventId;
  final String userId;
  final EventInterestStatus status;
  final bool needsRide;
  final DateTime createdAt;

  const EventInterest({
    required this.eventId,
    required this.userId,
    this.status = EventInterestStatus.interested,
    this.needsRide = true,
    required this.createdAt,
  });

  factory EventInterest.fromJson(Map<String, dynamic> j) => EventInterest(
        eventId: j['event_id'] as String,
        userId: j['user_id'] as String,
        status: EventInterestStatus.fromString(j['status'] as String?),
        needsRide: (j['needs_ride'] as bool?) ?? true,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
