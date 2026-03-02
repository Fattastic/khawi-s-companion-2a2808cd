import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Trust Tier Progression screen — §4.12 of the UX requirements.
///
/// Shows the user's current trust tier, the exact criteria met and unmet
/// for the next tier, and actionable next steps. Tappable from the trust
/// badge on any profile or ride card.
class TrustTierScreen extends ConsumerWidget {
  final int trustScore;
  final String badge; // 'bronze' | 'silver' | 'gold' | 'platinum'
  final bool isJuniorTrusted;

  const TrustTierScreen({
    super.key,
    required this.trustScore,
    required this.badge,
    this.isJuniorTrusted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(myProfileProvider);
    final idVerified = profileAsync.valueOrNull?.isIdentityVerified ?? false;

    final tierInfo = _TierInfo.fromBadge(badge);
    final nextTierInfo = tierInfo.next;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
        title: Text(
          isRtl ? 'ملف الثقة' : 'My Trust Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Current tier badge ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                _TierBadgeDisplay(tierInfo: tierInfo),
                const SizedBox(height: 12),
                Text(
                  tierInfo.label(isRtl),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tierInfo.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRtl
                      ? 'نقاط الثقة: $trustScore'
                      : 'Trust score: $trustScore',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Criteria met ───────────────────────────────────────────────
          _SectionHeader(isRtl ? 'المعايير المحققة' : 'Criteria Met'),
          const SizedBox(height: 8),
          ..._criteriaForTier(tierInfo, isRtl, idVerified).map(
            (c) => _CriterionTile(criterion: c),
          ),

          if (nextTierInfo != null) ...[
            const SizedBox(height: 24),

            // ── Next tier progress ───────────────────────────────────────
            _SectionHeader(
              isRtl
                  ? 'للوصول إلى ${nextTierInfo.label(isRtl)}'
                  : 'To reach ${nextTierInfo.label(false)}',
            ),
            const SizedBox(height: 8),
            ..._pendingCriteriaForNextTier(tierInfo, isRtl, idVerified).map(
              (c) => _CriterionTile(criterion: c),
            ),

            const SizedBox(height: 24),
            // ── Actionable suggestions ────────────────────────────────
            _SectionHeader(
              isRtl ? 'خطوات يمكنك اتخاذها الآن' : 'Steps you can take today',
            ),
            const SizedBox(height: 8),
            ..._suggestionsForTier(tierInfo, isRtl, context, idVerified).map(
              (s) => _SuggestionTile(suggestion: s),
            ),
          ] else ...[
            const SizedBox(height: 24),
            _PlatinumCelebration(isRtl: isRtl),
          ],

          const SizedBox(height: 28),

          // ── How tiers work ─────────────────────────────────────────────
          _HowTiersWorkCard(isRtl: isRtl),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<_Criterion> _criteriaForTier(
    _TierInfo tier,
    bool isRtl,
    bool idVerified,
  ) {
    return switch (tier.id) {
      'bronze' => [
          _Criterion(
            met: true,
            label: isRtl ? 'إنشاء الحساب' : 'Account created',
            icon: Icons.check_circle,
          ),
          _Criterion(
            met: trustScore >= 50,
            label: isRtl ? 'أكمل أول رحلة' : 'Complete first ride',
            icon: Icons.directions_car,
          ),
        ],
      'silver' => [
          _Criterion(
            met: idVerified,
            label: isRtl
                ? 'الهوية الوطنية موثقة (نفاث)'
                : 'Identity Verified (Nafath)',
            icon: Icons.verified_user,
          ),
          _Criterion(
            met: idVerified,
            label: isRtl ? 'الوصول إلى الدوائر الوردية' : 'Pink Circles Access',
            icon: Icons.favorite,
          ),
        ],
      'gold' => [
          _Criterion(
            met: idVerified,
            label: isRtl ? 'موثق الهوية' : 'Identity Verified',
            icon: Icons.verified_user,
          ),
          _Criterion(
            met: trustScore >= 500,
            label: isRtl ? '20 رحلة مكتملة' : '20 completed trips',
            icon: Icons.directions_car,
          ),
          _Criterion(
            met: trustScore >= 600,
            label: isRtl ? 'تقييم ≥ 4.8 نجوم' : 'Rating ≥ 4.8 stars',
            icon: Icons.star,
          ),
        ],
      'platinum' => [
          _Criterion(
            met: idVerified,
            label: isRtl ? 'موثق الهوية' : 'Identity Verified',
            icon: Icons.verified_user,
          ),
          _Criterion(
            met: trustScore >= 1200,
            label: isRtl ? '100 رحلة مكتملة' : '100 completed trips',
            icon: Icons.workspace_premium,
          ),
          _Criterion(
            met: trustScore >= 1300,
            label: isRtl ? 'تقييم ≥ 4.95 نجوم' : 'Rating ≥ 4.95 stars',
            icon: Icons.auto_awesome,
          ),
        ],
      _ => [],
    };
  }

  List<_Criterion> _pendingCriteriaForNextTier(
    _TierInfo tier,
    bool isRtl,
    bool idVerified,
  ) {
    return switch (tier.id) {
      'bronze' => [
          _Criterion(
            met: idVerified,
            label:
                isRtl ? 'توثيق الهوية عبر نفاث' : 'Verify Identity via Nafath',
            icon: Icons.badge,
          ),
        ],
      'silver' => [
          _Criterion(
            met: false,
            label: isRtl ? 'أكمل 20 رحلة' : 'Complete 20 trips',
            icon: Icons.directions_car,
            progress: (trustScore / 500).clamp(0.0, 1.0),
          ),
          _Criterion(
            met: false,
            label: isRtl ? 'حقق تقييم ≥ 4.8 نجوم' : 'Achieve ≥ 4.8 star rating',
            icon: Icons.star,
          ),
        ],
      'gold' => [
          _Criterion(
            met: false,
            label: isRtl ? 'أكمل 100 رحلة' : 'Complete 100 trips',
            icon: Icons.workspace_premium,
            progress: (trustScore / 1000).clamp(0.0, 1.0),
          ),
          _Criterion(
            met: false,
            label: isRtl ? 'تقييم ≥ 4.95 نجوم' : 'Maintain ≥ 4.95 star rating',
            icon: Icons.auto_awesome,
          ),
        ],
      _ => [],
    };
  }

  List<_Suggestion> _suggestionsForTier(
    _TierInfo tier,
    bool isRtl,
    BuildContext context,
    bool idVerified,
  ) {
    return switch (tier.id) {
      'bronze' => [
          if (!idVerified)
            _Suggestion(
              icon: Icons.verified_user,
              text: isRtl
                  ? 'وثق هويتك الآن لفتح الدوائر الوردية ومستوى الفضة'
                  : 'Verify identity now to unlock Pink Circles & Silver Tier',
              onTap: () => context.push(Routes.verification),
            ),
          _Suggestion(
            icon: Icons.directions_car,
            text: isRtl
                ? 'أكمل رحلتك القادمة لزيادة نقاط الثقة'
                : 'Complete your next ride to increase trust points',
          ),
        ],
      'silver' => [
          _Suggestion(
            icon: Icons.favorite,
            text: isRtl
                ? 'انضم للدوائر الوردية لزيادة ثقة المجتمع بك'
                : 'Join Pink Circles to increase community trust',
          ),
          _Suggestion(
            icon: Icons.star,
            text: isRtl
                ? 'احرص على تقديم تقييمات ممتازة لرفع رتبتك'
                : 'Aim for excellent ratings to reach Gold',
          ),
        ],
      'gold' => [
          _Suggestion(
            icon: Icons.workspace_premium,
            text: isRtl
                ? 'استمر في مشاركة الرحلات للوصول لرتبة البلاتينيوم'
                : 'Keep sharing rides to reach Platinum status',
          ),
        ],
      _ => [],
    };
  }
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _TierInfo {
  final String id;
  final Color color;
  final IconData icon;
  final _TierInfo? next;

  const _TierInfo._({
    required this.id,
    required this.color,
    required this.icon,
    this.next,
  });

  static const platinum = _TierInfo._(
    id: 'platinum',
    color: Color(0xFF4DD0E1),
    icon: Icons.verified_user,
  );
  static const gold = _TierInfo._(
    id: 'gold',
    color: Color(0xFFFFD700),
    icon: Icons.verified,
    next: platinum,
  );
  static const silver = _TierInfo._(
    id: 'silver',
    color: Color(0xFFC0C0C0),
    icon: Icons.shield,
    next: gold,
  );
  static const bronze = _TierInfo._(
    id: 'bronze',
    color: Color(0xFFCD7F32),
    icon: Icons.shield_outlined,
    next: silver,
  );

  factory _TierInfo.fromBadge(String badge) {
    return switch (badge.toLowerCase()) {
      'platinum' => platinum,
      'gold' => gold,
      'silver' => silver,
      _ => bronze,
    };
  }

  String label(bool isRtl) => switch (id) {
        'platinum' => isRtl ? 'بلاتيني' : 'Platinum',
        'gold' => isRtl ? 'ذهبي' : 'Gold',
        'silver' => isRtl ? 'فضي' : 'Silver',
        _ => isRtl ? 'برونزي' : 'Bronze',
      };
}

class _Criterion {
  final bool met;
  final String label;
  final IconData icon;
  final double? progress; // null = binary (no progress bar)
  const _Criterion({
    required this.met,
    required this.label,
    required this.icon,
    this.progress,
  });
}

class _Suggestion {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _Suggestion({required this.icon, required this.text, this.onTap});
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textTertiary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _TierBadgeDisplay extends StatelessWidget {
  final _TierInfo tierInfo;
  const _TierBadgeDisplay({required this.tierInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tierInfo.color.withValues(alpha: 0.1),
        border: Border.all(color: tierInfo.color, width: 3),
      ),
      child: Icon(tierInfo.icon, color: tierInfo.color, size: 52),
    );
  }
}

class _CriterionTile extends StatelessWidget {
  final _Criterion criterion;
  const _CriterionTile({required this.criterion});

  @override
  Widget build(BuildContext context) {
    final color = criterion.met ? AppTheme.primaryGreen : AppTheme.textTertiary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  criterion.met ? Icons.check_circle : criterion.icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    criterion.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: criterion.met
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (criterion.progress != null && !criterion.met) ...[
              const SizedBox(height: 8),
              const SizedBox(height: 12),
              LevelProgressBar(
                value: criterion.progress!,
                height: 10,
                glowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 4),
              Text(
                '${(criterion.progress! * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final _Suggestion suggestion;
  const _SuggestionTile({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: suggestion.onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(suggestion.icon, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  suggestion.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              if (suggestion.onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatinumCelebration extends StatelessWidget {
  final bool isRtl;
  const _PlatinumCelebration({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DD0E1), Color(0xFF006064)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            isRtl
                ? 'أنت في أعلى مستوى من الثقة!'
                : 'You\'ve reached the highest trust level!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isRtl
                ? 'شكراً لمساهمتك في بناء مجتمع خاوي الآمن'
                : 'Thank you for building a safe Khawi community',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HowTiersWorkCard extends StatelessWidget {
  final bool isRtl;
  const _HowTiersWorkCard({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isRtl ? 'كيف تعمل مستويات الثقة؟' : 'How trust tiers work',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isRtl
                ? 'تتدرج المستويات من برونزي → فضي → ذهبي → بلاتيني. كل معيار يمكنك التحقق منه في أي وقت — لا توجد اشتراطات مخفية. '
                    'يُحسب مستواك تلقائياً في غضون 60 ثانية من استيفاء أي شرط.'
                : 'Tiers progress Bronze → Silver → Gold → Platinum. Every criterion is transparent — no hidden requirements. '
                    'Your tier updates automatically within 60 seconds of meeting any criterion.',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
