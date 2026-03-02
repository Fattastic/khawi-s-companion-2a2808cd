/// XP transaction record (formerly XPTransaction).
class XpTransaction {
  final String id;
  final String userId;
  final String title;
  final String amount;
  final String type; // 'credit' or 'debit'
  final double multiplier;
  final DateTime createdAt;

  const XpTransaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    this.multiplier = 1.0,
    required this.createdAt,
  });

  factory XpTransaction.fromJson(Map<String, dynamic> json) => XpTransaction(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        amount: json['amount'] as String,
        type: json['type'] as String,
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'multiplier': multiplier,
        'created_at': createdAt.toIso8601String(),
      };
}
