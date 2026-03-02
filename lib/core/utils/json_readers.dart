// Helper functions for safe JSON reading.
// Handles type mismatches (String vs int vs double) gracefully.

String readString(Map<String, dynamic> json, String key) =>
    (json[key] ?? '').toString();

String? readNullableString(Map<String, dynamic> json, String key) =>
    json[key]?.toString();

bool readBool(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}

double readDouble(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is num) return v.toDouble();
  return double.tryParse((v ?? '').toString()) ?? 0.0;
}

int readInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is num) return v.toInt();
  return int.tryParse((v ?? '').toString()) ?? 0;
}
