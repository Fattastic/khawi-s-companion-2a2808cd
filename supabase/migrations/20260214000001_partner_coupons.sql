-- Add Saudi partner coupons to reward catalog

INSERT INTO reward_catalog (
    category,
    name_en,
    name_ar,
    description_en,
    description_ar,
    xp_cost,
    trust_tier_required,
    subscription_required,
    weekly_cap
) VALUES
('partner', 'Half Million Coffee Voucher', 'قسيمة هاف مليون',
 'Coffee voucher valid up to 25 SAR at Half Million.',
 'قسيمة قهوة صالحة حتى 25 ريال في هاف مليون.',
 900, 'gold', TRUE, 2),
('partner', 'Barn\'s Coffee Voucher', 'قسيمة بارنز',
 'Drink voucher valid up to 20 SAR at Barn\'s.',
 'قسيمة مشروب صالحة حتى 20 ريال في بارنز.',
 800, 'gold', TRUE, 2),
('partner', 'Dunkin Donuts Voucher', 'قسيمة دانكن دونتس',
 'Coffee + donut combo valid up to 22 SAR at Dunkin Donuts.',
 'قسيمة قهوة + دونات صالحة حتى 22 ريال في دانكن دونتس.',
 850, 'gold', TRUE, 2);
