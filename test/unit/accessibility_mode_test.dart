import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/domain/accessibility_mode.dart';

void main() {
  group('accessibility mode helpers', () {
    test('parses known keys and ignores unknown values', () {
      final needs = parseAccessibilityNeeds(
        ['wheelchair', 'assistive_support', 'vision_support', 'unknown'],
      );

      expect(needs.contains(AccessibilityNeed.wheelchair), isTrue);
      expect(needs.contains(AccessibilityNeed.assistiveSupport), isTrue);
      expect(needs.contains(AccessibilityNeed.visionSupport), isTrue);
      expect(needs.length, 3);
    });

    test('builds localized accessibility request note', () {
      final needs = {
        AccessibilityNeed.wheelchair,
        AccessibilityNeed.seniorFriendly,
      };

      final english = buildAccessibilityRequestNote(
        needs: needs,
        isArabic: false,
      );
      final arabic = buildAccessibilityRequestNote(
        needs: needs,
        isArabic: true,
      );

      expect(english, startsWith('Accessibility:'));
      expect(english, contains('Wheelchair access'));
      expect(arabic, startsWith('احتياجات وصول:'));
      expect(arabic, contains('كرسي متحرك'));
    });

    test('includes vision support label when selected', () {
      final english = buildAccessibilityRequestNote(
        needs: {AccessibilityNeed.visionSupport},
        isArabic: false,
      );
      final arabic = buildAccessibilityRequestNote(
        needs: {AccessibilityNeed.visionSupport},
        isArabic: true,
      );

      expect(english, 'Accessibility: Vision support');
      expect(arabic, 'احتياجات وصول: دعم لضعف البصر');
    });

    test('returns deterministic sorted accessibility keys', () {
      final keys = accessibilityNeedKeys({
        AccessibilityNeed.visionSupport,
        AccessibilityNeed.wheelchair,
        AccessibilityNeed.assistiveSupport,
      });

      expect(
        keys,
        ['assistive_support', 'vision_support', 'wheelchair'],
      );
    });

    test('returns null note when no accessibility needs selected', () {
      final note = buildAccessibilityRequestNote(
        needs: <AccessibilityNeed>{},
        isArabic: false,
      );

      expect(note, isNull);
    });

    test('merges notes with newline and handles empty values', () {
      final merged = mergeRequestNotes(
        primaryNote: 'Please call on arrival',
        secondaryNote: 'Accessibility: Wheelchair access',
      );

      expect(
          merged, 'Please call on arrival\nAccessibility: Wheelchair access',);
      expect(
        mergeRequestNotes(primaryNote: 'solo', secondaryNote: null),
        'solo',
      );
      expect(
        mergeRequestNotes(primaryNote: ' ', secondaryNote: '  '),
        isNull,
      );
    });
  });
}
