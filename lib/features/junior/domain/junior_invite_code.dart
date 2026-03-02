class JuniorInviteCode {
  const JuniorInviteCode({
    required this.id,
    required this.code,
    required this.parentId,
    required this.isUsed,
    required this.expiresAt,
    required this.createdAt,
    this.invitedDriverName,
    this.invitedDriverPhone,
    this.invitedDriverRelation,
    this.redeemedBy,
    this.redeemedAt,
  });

  final String id;
  final String code;
  final String parentId;
  final bool isUsed;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? invitedDriverName;
  final String? invitedDriverPhone;
  final String? invitedDriverRelation;
  final String? redeemedBy;
  final DateTime? redeemedAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());
  bool get isPending => !isUsed && !isExpired;

  factory JuniorInviteCode.fromJson(Map<String, dynamic> json) {
    return JuniorInviteCode(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString().toUpperCase(),
      parentId: (json['parent_id'] ?? '').toString(),
      isUsed: json['is_used'] == true,
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      invitedDriverName: json['invited_driver_name']?.toString(),
      invitedDriverPhone: json['invited_driver_phone']?.toString(),
      invitedDriverRelation: json['invited_driver_relation']?.toString(),
      redeemedBy: json['redeemed_by']?.toString(),
      redeemedAt: DateTime.tryParse((json['redeemed_at'] ?? '').toString()),
    );
  }
}
