List<String> buildChatAssistantSuggestions({
  required bool isRtl,
  required String draft,
  required String? lastIncomingMessage,
  int maxItems = 3,
}) {
  final normalizedDraft = draft.trim().toLowerCase();
  final normalizedIncoming = (lastIncomingMessage ?? '').trim().toLowerCase();

  final suggestions = <String>[];

  if (normalizedDraft.isEmpty) {
    suggestions.addAll(
      isRtl
          ? const [
              'أنا داخل الآن على الطريق.',
              'أرسل لوكيشنك الدقيق لو سمحت.',
              'إذا تأخرت عليّ دقيقتين خبرني.',
            ]
          : const [
              'I am heading to the pickup now.',
              'Please share your exact location.',
              'Let me know if you are running late.',
            ],
    );
  }

  final locationSignal = normalizedDraft.contains('location') ||
      normalizedDraft.contains('لوكيشن') ||
      normalizedDraft.contains('موقع') ||
      normalizedIncoming.contains('location') ||
      normalizedIncoming.contains('موقع');
  if (locationSignal) {
    suggestions.add(
      isRtl
          ? 'تمام، شاركني الموقع على الخريطة وبوصل لك.'
          : 'Perfect, share the map pin and I will head there.',
    );
  }

  final delaySignal = normalizedDraft.contains('late') ||
      normalizedDraft.contains('delay') ||
      normalizedDraft.contains('متأخر') ||
      normalizedDraft.contains('تأخير') ||
      normalizedIncoming.contains('late') ||
      normalizedIncoming.contains('تأخير');
  if (delaySignal) {
    suggestions.add(
      isRtl
          ? 'ولا يهمك، خذ وقتك وأنا منتظر.'
          : 'No worries, take your time and I will wait.',
    );
  }

  final thanksSignal = normalizedDraft.contains('thanks') ||
      normalizedDraft.contains('thank you') ||
      normalizedDraft.contains('شكرا') ||
      normalizedDraft.contains('مشكور') ||
      normalizedIncoming.contains('thanks') ||
      normalizedIncoming.contains('شكرا');
  if (thanksSignal) {
    suggestions.add(
      isRtl ? 'العفو، بالخدمة دائمًا 🙏' : 'You are welcome, happy to help 🙏',
    );
  }

  final pickupSignal = normalizedDraft.contains('pickup') ||
      normalizedDraft.contains('نقطة') ||
      normalizedIncoming.contains('pickup') ||
      normalizedIncoming.contains('نقطة');
  if (pickupSignal) {
    suggestions.add(
      isRtl
          ? 'أنا عند نقطة الالتقاء المتفق عليها.'
          : 'I am at the agreed pickup point.',
    );
  }

  final unique = <String>[];
  for (final value in suggestions) {
    if (!unique.contains(value)) {
      unique.add(value);
    }
  }
  return unique.take(maxItems).toList();
}
