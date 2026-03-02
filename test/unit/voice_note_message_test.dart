import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/chat/domain/voice_note_message.dart';

void main() {
  group('voice note message formatting', () {
    test('formats duration in mm:ss', () {
      expect(formatVoiceNoteDuration(0), '00:00');
      expect(formatVoiceNoteDuration(9), '00:09');
      expect(formatVoiceNoteDuration(65), '01:05');
    });

    test('returns English voice message text', () {
      expect(
        formatVoiceNoteMessage(seconds: 12, isRtl: false),
        '🎤 Voice message (00:12)',
      );
    });

    test('returns Arabic voice message text', () {
      expect(
        formatVoiceNoteMessage(seconds: 12, isRtl: true),
        '🎤 رسالة صوتية (00:12)',
      );
    });

    test('enforces minimum 1 second for message payload', () {
      expect(
        formatVoiceNoteMessage(seconds: 0, isRtl: false),
        '🎤 Voice message (00:01)',
      );
    });
  });
}
