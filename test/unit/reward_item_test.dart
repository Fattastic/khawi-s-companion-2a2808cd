import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/rewards/domain/reward_item.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';

void main() {
  group('RewardCategory', () {
    test('fromString parses all categories', () {
      expect(RewardCategoryX.fromString('symbolic'), RewardCategory.symbolic);
      expect(
        RewardCategoryX.fromString('functional'),
        RewardCategory.functional,
      );
      expect(RewardCategoryX.fromString('partner'), RewardCategory.partner);
    });

    test('fromString defaults to symbolic', () {
      expect(RewardCategoryX.fromString('unknown'), RewardCategory.symbolic);
      expect(RewardCategoryX.fromString(null), RewardCategory.symbolic);
    });

    test('displayName returns English', () {
      expect(RewardCategory.symbolic.displayName, 'Symbolic');
      expect(RewardCategory.functional.displayName, 'Functional');
      expect(RewardCategory.partner.displayName, 'Partner');
    });

    test('displayNameAr returns Arabic', () {
      expect(RewardCategory.symbolic.displayNameAr, 'رمزية');
      expect(RewardCategory.functional.displayNameAr, 'عملية');
      expect(RewardCategory.partner.displayNameAr, 'شراكات');
    });
  });

  group('RewardItem', () {
    final json = <String, dynamic>{
      'id': 'r1',
      'category': 'functional',
      'name_en': 'Priority Matching',
      'name_ar': 'أولوية المطابقة',
      'description_en': 'Get matched first for 24 hours',
      'description_ar': 'احصل على مطابقة أولاً لمدة ٢٤ ساعة',
      'xp_cost': 500,
      'trust_tier_required': 'silver',
      'subscription_required': true,
      'weekly_cap': 3,
      'is_active': true,
    };

    test('fromJson parses all fields', () {
      final r = RewardItem.fromJson(json);
      expect(r.id, 'r1');
      expect(r.category, RewardCategory.functional);
      expect(r.nameEn, 'Priority Matching');
      expect(r.nameAr, 'أولوية المطابقة');
      expect(r.xpCost, 500);
      expect(r.trustTierRequired, TrustTier.silver);
      expect(r.subscriptionRequired, true);
      expect(r.weeklyCap, 3);
      expect(r.isActive, true);
    });

    test('fromJson uses defaults', () {
      final r = RewardItem.fromJson({
        'id': 'r2',
        'name_en': 'Badge',
        'name_ar': 'شارة',
        'xp_cost': 100,
      });
      expect(r.category, RewardCategory.symbolic); // default
      expect(r.trustTierRequired, TrustTier.bronze); // default
      expect(r.subscriptionRequired, false);
      expect(r.weeklyCap, isNull);
      expect(r.isActive, true); // default
    });

    test('name returns localized value', () {
      final r = RewardItem.fromJson(json);
      expect(r.name(true), 'أولوية المطابقة'); // RTL = Arabic
      expect(r.name(false), 'Priority Matching');
    });

    test('description returns localized value', () {
      final r = RewardItem.fromJson(json);
      expect(r.description(true), contains('٢٤'));
      expect(r.description(false), contains('24 hours'));
    });
  });
}
