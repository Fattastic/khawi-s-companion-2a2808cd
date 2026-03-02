import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/chat/domain/chat_assistant_suggestions.dart';

void main() {
  group('buildChatAssistantSuggestions', () {
    test('returns default english suggestions for empty draft', () {
      final suggestions = buildChatAssistantSuggestions(
        isRtl: false,
        draft: '',
        lastIncomingMessage: null,
      );

      expect(suggestions, isNotEmpty);
      expect(suggestions.first, contains('pickup'));
    });

    test('returns location-aware arabic suggestion when location intent exists',
        () {
      final suggestions = buildChatAssistantSuggestions(
        isRtl: true,
        draft: 'وين موقعك؟',
        lastIncomingMessage: null,
      );

      expect(
        suggestions.any((s) => s.contains('الموقع') || s.contains('لوكيشن')),
        isTrue,
      );
    });

    test('limits output size and removes duplicates', () {
      final suggestions = buildChatAssistantSuggestions(
        isRtl: false,
        draft: 'thanks thanks thanks',
        lastIncomingMessage: 'thanks',
        maxItems: 2,
      );

      expect(suggestions.length, lessThanOrEqualTo(2));
      expect(suggestions.toSet().length, suggestions.length);
    });
  });
}
