import 'package:flutter_test/flutter_test.dart';

import 'package:khawi_flutter/features/chat/domain/quick_reply_templates.dart';

void main() {
  group('quickReplyTemplates', () {
    test('returns English templates when isRtl is false', () {
      final templates = quickReplyTemplates(isRtl: false);
      expect(templates, hasLength(5));
      expect(templates.first, 'I am near the pickup point');
    });

    test('returns Arabic templates when isRtl is true', () {
      final templates = quickReplyTemplates(isRtl: true);
      expect(templates, hasLength(5));
      expect(templates.first, 'أنا قريب من نقطة الالتقاء');
    });
  });
}
