String formatVoiceNoteDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final mm = (safe ~/ 60).toString().padLeft(2, '0');
  final ss = (safe % 60).toString().padLeft(2, '0');
  return '$mm:$ss';
}

String formatVoiceNoteMessage({required int seconds, required bool isRtl}) {
  final safe = seconds < 1 ? 1 : seconds;
  final duration = formatVoiceNoteDuration(safe);
  return isRtl ? '🎤 رسالة صوتية ($duration)' : '🎤 Voice message ($duration)';
}
