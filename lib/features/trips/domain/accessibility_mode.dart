enum AccessibilityNeed {
  wheelchair('wheelchair', 'كرسي متحرك', 'Wheelchair access'),
  seniorFriendly(
      'senior_friendly', 'مراعاة كبار السن', 'Senior-friendly support',),
  assistiveSupport(
      'assistive_support', 'دعم وسائل مساعدة', 'Assistive support',),
  visionSupport('vision_support', 'دعم لضعف البصر', 'Vision support');

  const AccessibilityNeed(this.key, this.labelAr, this.labelEn);

  final String key;
  final String labelAr;
  final String labelEn;

  String label({required bool isArabic}) => isArabic ? labelAr : labelEn;

  static AccessibilityNeed? fromKey(String key) {
    for (final value in AccessibilityNeed.values) {
      if (value.key == key) return value;
    }
    return null;
  }
}

Set<AccessibilityNeed> parseAccessibilityNeeds(Iterable<String> keys) {
  final values = <AccessibilityNeed>{};
  for (final key in keys) {
    final parsed = AccessibilityNeed.fromKey(key.trim());
    if (parsed != null) values.add(parsed);
  }
  return values;
}

List<String> accessibilityNeedKeys(Set<AccessibilityNeed> needs) {
  final keys = needs.map((need) => need.key).toList()..sort();
  return keys;
}

String? buildAccessibilityRequestNote({
  required Set<AccessibilityNeed> needs,
  required bool isArabic,
}) {
  if (needs.isEmpty) return null;

  final labels = needs
      .map((need) => need.label(isArabic: isArabic))
      .toList(growable: false);
  labels.sort();

  final prefix = isArabic ? 'احتياجات وصول:' : 'Accessibility:';
  return '$prefix ${labels.join('، ')}';
}

String? mergeRequestNotes({
  String? primaryNote,
  String? secondaryNote,
}) {
  final first = primaryNote?.trim() ?? '';
  final second = secondaryNote?.trim() ?? '';

  if (first.isEmpty && second.isEmpty) return null;
  if (first.isEmpty) return second;
  if (second.isEmpty) return first;
  return '$first\n$second';
}
