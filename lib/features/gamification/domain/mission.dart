import 'gamification_enums.dart';

/// Definition of a weekly mission assigned to a user.
class Mission {
  const Mission({
    required this.id,
    required this.userId,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.category,
    required this.status,
    required this.targetCount,
    required this.currentCount,
    required this.rewardXp,
    required this.weekStart,
    required this.weekEnd,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final MissionCategory category;
  final MissionStatus status;
  final int targetCount;
  final int currentCount;
  final int rewardXp;
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime createdAt;

  /// Progress ratio in 0.0–1.0 range.
  double get progress =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => currentCount >= targetCount;

  bool get isExpired => DateTime.now().isAfter(weekEnd);

  String localizedTitle({required bool isRtl}) => isRtl ? titleAr : title;

  String localizedDescription({required bool isRtl}) =>
      isRtl ? descriptionAr : description;

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? '',
        titleAr: json['title_ar'] as String? ?? '',
        description: json['description'] as String? ?? '',
        descriptionAr: json['description_ar'] as String? ?? '',
        category: MissionCategory.fromString(
            json['category'] as String? ?? 'general',),
        status: MissionStatus.fromString(json['status'] as String? ?? 'active'),
        targetCount: json['target_count'] as int? ?? 1,
        currentCount: json['current_count'] as int? ?? 0,
        rewardXp: json['reward_xp'] as int? ?? 0,
        weekStart: DateTime.parse(json['week_start'] as String),
        weekEnd: DateTime.parse(json['week_end'] as String),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
}
