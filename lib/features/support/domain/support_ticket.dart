class SupportTicket {
  final String id;
  final String subject;
  final String body;
  final String status; // open, resolved
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.body,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      subject: (json['subject'] as String?) ?? 'No Subject',
      body: (json['body'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
