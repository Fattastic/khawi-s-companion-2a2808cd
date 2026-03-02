import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/trust_tier.dart';
import '../domain/reward_item.dart';

final mockRewardsProvider = Provider<List<RewardItem>>((ref) {
  return [
    const RewardItem(
      id: 'r1',
      category: RewardCategory.partner,
      nameEn: 'Free Coffee Box',
      nameAr: 'بوكس قهوة مجاني',
      descriptionEn: 'One box of signature items from Half Million.',
      descriptionAr: 'بوكس واحد من منتجات هاف مليون المميزة.',
      xpCost: 1200,
      trustTierRequired: TrustTier.bronze,
      subscriptionRequired: true,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-162955ed8a9f',
      providerLogoUrl:
          'https://seeklogo.com/images/H/half-million-logo-D3A248A8F2-seeklogo.com.png',
      isActive: true,
    ),
    const RewardItem(
      id: 'r2',
      category: RewardCategory.functional,
      nameEn: 'Priority Matching',
      nameAr: 'أولوية التوافق',
      descriptionEn: 'Get matched with drivers 2x faster during peak hours.',
      descriptionAr: 'احصل على توافق مع الكباتن أسرع بمرتين في وقت الذروة.',
      xpCost: 500,
      trustTierRequired: TrustTier.silver,
      subscriptionRequired: false,
      isActive: true,
    ),
    const RewardItem(
      id: 'r3',
      category: RewardCategory.symbolic,
      nameEn: 'Night Owl Aura',
      nameAr: 'هالة البومة الليلية',
      descriptionEn: 'Give your profile a cool dark glow for night rides.',
      descriptionAr: 'امنح ملفك الشخصي وهجًا ليليًا في المشاوير المتأخرة.',
      xpCost: 300,
      trustTierRequired: TrustTier.bronze,
      subscriptionRequired: false,
      isActive: true,
    ),
    const RewardItem(
      id: 'r4',
      category: RewardCategory.partner,
      nameEn: 'Car Wash Voucher',
      nameAr: 'قسيمة غسيل سيارة',
      descriptionEn: 'Full interior and exterior wash at Petromin.',
      descriptionAr: 'غسيل داخلي وخارجي كامل في بترومين.',
      xpCost: 2000,
      trustTierRequired: TrustTier.gold,
      subscriptionRequired: true,
      imageUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f',
      isActive: true,
    ),
  ];
});
