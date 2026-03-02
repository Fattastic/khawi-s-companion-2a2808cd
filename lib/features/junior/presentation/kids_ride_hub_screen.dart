import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/slow_network_banner.dart';
import 'package:khawi_flutter/features/gamification/presentation/mission_card_list.dart';
import 'package:khawi_flutter/features/gamification/presentation/next_best_action_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/streak_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/wallet_summary_tile.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/services/permission_service.dart';
import 'package:khawi_flutter/state/providers.dart';

import 'junior_providers.dart';

class KidsRideHubScreen extends ConsumerWidget {
  const KidsRideHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'خاوي جونيور' : 'Khawi Junior'),
        backgroundColor: AppTheme.juniorAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.sharedNotifications),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SlowNetworkBanner(
        child: RefreshIndicator(
          color: AppTheme.juniorAccent,
          onRefresh: () async {
            ref.invalidate(myKidsProvider);
            ref.invalidate(myJuniorRunsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            children: [
              KhawiMotion.slideUpFadeIn(
                _HeaderCard(
                  onSos: () => _triggerSos(context, ref),
                  isRtl: isRtl,
                ),
                index: 0,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(
                _QuickActionsRow(isRtl: isRtl),
                index: 1,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(
                _GamificationPulseSection(isRtl: isRtl),
                index: 2,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(
                _GuardianOperationsPanel(isRtl: isRtl),
                index: 3,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(
                const _ReliabilityBanner(),
                index: 4,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(_KidsSection(isRtl: isRtl), index: 5),
              const SizedBox(height: AppTheme.spacingSmall),
              KhawiMotion.slideUpFadeIn(_RunsSection(isRtl: isRtl), index: 6),
            ],
          ),
        ), // RefreshIndicator
      ), // SlowNetworkBanner
    );
  }

  static Future<void> _triggerSos(BuildContext context, WidgetRef ref) async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final repo = ref.read(juniorRepoProvider);
    final messageCtl = TextEditingController();
    int severity = 3;

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(isRtl ? 'إرسال نداء استغاثة' : 'Send SOS'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: messageCtl,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: isRtl ? 'رسالة (اختياري)' : 'Message (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(isRtl ? 'الخطورة' : 'Severity'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: severity.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$severity',
                        activeColor: Colors.red,
                        onChanged: (v) => setState(() => severity = v.round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(isRtl ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRtl ? 'إرسال' : 'Send'),
              ),
            ],
          ),
        ),
      );

      if (ok != true) return;
      if (!context.mounted) return;

      final pos = await PermissionService.getCurrentPositionWithPermission(
        context,
        showSettingsDialogIfDenied: true,
      );

      if (pos == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRtl
                  ? 'فشل SOS: لا يمكن الحصول على الموقع'
                  : 'SOS failed: Could not get location',
            ),
          ),
        );
        return;
      }

      try {
        await repo.createSos(
          lat: pos.latitude,
          lng: pos.longitude,
          severity: severity,
          message:
              messageCtl.text.trim().isEmpty ? null : messageCtl.text.trim(),
          meta: const {'source': 'guardian_hub'},
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS sent'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS failed: $e')),
        );
      }
    } finally {
      messageCtl.dispose();
    }
  }
}

class _QuickActionsRow extends StatelessWidget {
  final bool isRtl;
  const _QuickActionsRow({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.child_friendly,
            title: isRtl ? 'توصيل الأطفال' : 'Kids Carpool',
            subtitle: isRtl ? 'لوحة سريعة' : 'Quick hub',
            color: AppTheme.juniorAccent,
            onTap: () => context.push(Routes.juniorCarpool),
            isRtl: isRtl,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.family_restroom,
            title: isRtl ? 'سائق عائلي' : 'Family Driver',
            subtitle: isRtl ? 'إضافة/دعوة' : 'Add/invite',
            color: AppTheme.primaryGreen,
            onTap: () => context.push(Routes.juniorAddDriver),
            isRtl: isRtl,
          ),
        ),
      ],
    );
  }
}

class _GamificationPulseSection extends StatelessWidget {
  const _GamificationPulseSection({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'تحفيز يومي' : 'Daily Motivation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isRtl
                  ? 'أنجز مهامك اليومية في خواي واحصل على مكافآت أسرع.'
                  : 'Complete Khawi challenges daily and unlock rewards faster.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            const NextBestActionCard(),
            const StreakCard(),
            const MissionCardList(),
            const WalletSummaryTile(),
          ],
        ),
      ),
    );
  }
}

class _GuardianOperationsPanel extends ConsumerWidget {
  const _GuardianOperationsPanel({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsAsync = ref.watch(myKidsProvider);
    final runsAsync = ref.watch(myJuniorRunsProvider);
    final invitesAsync = ref.watch(myJuniorInviteCodesProvider);
    final trustedAsync = ref.watch(myTrustedDriversProvider);

    final kidsCount = kidsAsync.asData?.value.length ?? 0;
    final activeRuns = runsAsync.asData?.value
            .where((r) => r.status != 'completed' && r.status != 'cancelled')
            .length ??
        0;
    final pendingInvites =
        invitesAsync.asData?.value.where((i) => i.isPending).length ?? 0;
    final trustedDrivers =
        trustedAsync.asData?.value.where((d) => d.isActive).length ?? 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'Guardian Operations' : 'Guardian Operations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              isRtl
                  ? 'At-a-glance family safety and driver confirmation status.'
                  : 'At-a-glance family safety and driver confirmation status.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _OpsMetric(
                    label: isRtl ? 'Kids' : 'Kids',
                    value: '$kidsCount',
                    icon: Icons.child_care,
                    color: AppTheme.juniorAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OpsMetric(
                    label: isRtl ? 'Active Runs' : 'Active Runs',
                    value: '$activeRuns',
                    icon: Icons.route,
                    color: AppTheme.primaryGreenDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _OpsMetric(
                    label: isRtl ? 'Pending Invites' : 'Pending Invites',
                    value: '$pendingInvites',
                    icon: Icons.mark_email_unread,
                    color: AppTheme.accentGoldDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OpsMetric(
                    label: isRtl ? 'Trusted Drivers' : 'Trusted Drivers',
                    value: '$trustedDrivers',
                    icon: Icons.verified_user,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OpsMetric extends StatelessWidget {
  const _OpsMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReliabilityBanner extends StatelessWidget {
  const _ReliabilityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.14),
            child: const Icon(
              Icons.shield_moon_outlined,
              size: 15,
              color: AppTheme.primaryGreenDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Khawi Jr safety model active: invite-only drivers + live run tracking + SOS support.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isRtl;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Icon(
                isRtl ? Icons.chevron_left : Icons.chevron_right,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final VoidCallback onSos;
  final bool isRtl;
  const _HeaderCard({required this.onSos, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        gradient: AppTheme.juniorGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.juniorAccent.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'مركز الولي' : 'Guardian Hub',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isRtl
                ? 'خطط لرحلات آمنة • شارك أكواد الدعوة • تتبع مباشر'
                : 'Plan safe school runs • Share invite codes • Live tracking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onSos,
              icon: const Icon(Icons.emergency_outlined),
              label: Text(
                isRtl ? 'إرسال نداء استغاثة' : 'Send SOS',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KidsSection extends ConsumerWidget {
  final bool isRtl;
  const _KidsSection({required this.isRtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsAsync = ref.watch(myKidsProvider);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isRtl ? 'الأطفال' : 'Kids',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddKidDialog(context, ref, isRtl),
                  icon: const Icon(Icons.add, color: AppTheme.juniorAccent),
                  label: Text(
                    isRtl ? 'إضافة' : 'Add',
                    style: const TextStyle(color: AppTheme.juniorAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            kidsAsync.when(
              data: (kids) {
                if (kids.isEmpty) {
                  return Text(
                    isRtl
                        ? 'أضف ملف طفلك لبدء التخطيط لرحلات آمنة.'
                        : 'Add your kid profile to start planning safe runs.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.start,
                  );
                }
                return Column(
                  children: kids
                      .map(
                        (k) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.juniorAccent.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.child_care,
                              color: AppTheme.juniorAccent,
                            ),
                          ),
                          title: Text(
                            k.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            k.schoolName ??
                                k.notes ??
                                (isRtl ? 'ملف الطفل' : 'Kid profile'),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(color: AppTheme.juniorAccent),
              ),
              error: (e, _) => Text('${isRtl ? "خطأ" : "Error"}: $e'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showAddKidDialog(
    BuildContext context,
    WidgetRef ref,
    bool isRtl,
  ) async {
    final nameCtl = TextEditingController();
    final ageCtl = TextEditingController();

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isRtl ? 'إضافة طفل' : 'Add kid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                textAlign: TextAlign.start,
                decoration:
                    InputDecoration(labelText: isRtl ? 'الاسم' : 'Name'),
              ),
              TextField(
                controller: ageCtl,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: isRtl ? 'العمر (اختياري)' : 'Age (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isRtl ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.juniorAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(isRtl ? 'إضافة' : 'Add'),
            ),
          ],
        ),
      );

      if (ok != true) return;
      final uid = ref.read(userIdProvider);
      if (uid == null) return;
      final age = int.tryParse(ageCtl.text.trim()) ?? 0;
      await ref.read(juniorRepoProvider).addKid(
            parentId: uid,
            name: nameCtl.text.trim(),
            age: age,
          );
    } finally {
      nameCtl.dispose();
      ageCtl.dispose();
    }
  }
}

class _RunsSection extends ConsumerWidget {
  final bool isRtl;
  const _RunsSection({required this.isRtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(myJuniorRunsProvider);
    final kidsAsync = ref.watch(myKidsProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isRtl ? 'الرحلات' : 'Runs',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      _showCreateRunDialog(context, ref, kidsAsync, isRtl),
                  icon: const Icon(Icons.add, color: AppTheme.juniorAccent),
                  label: Text(
                    isRtl ? 'رحلة جديدة' : 'New run',
                    style: const TextStyle(color: AppTheme.juniorAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            runsAsync.when(
              data: (runs) {
                if (runs.isEmpty) {
                  return Text(
                    isRtl
                        ? 'أنشئ رحلة لتوليد كود دعوة لسائق العائلة.'
                        : 'Create a run to generate an invite code for your family driver.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.start,
                  );
                }
                return Column(
                  children: runs.map((r) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.borderColor),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppTheme.juniorAccent.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.route,
                              color: AppTheme.juniorAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRtl
                                      ? 'الحالة: ${r.status}'
                                      : 'Status: ${r.status}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  isRtl
                                      ? 'Ø§Ù„Ø§Ø³ØªÙ„Ø§Ù…: ${r.pickupTime.toLocal().toString().split(".").first}'
                                      : 'Pickup: ${r.pickupTime.toLocal().toString().split(".").first}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'track') {
                                context.push(Routes.liveJuniorPath(r.id));
                              } else if (v == 'invite') {
                                _createInvite(context, ref, r.id, isRtl);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'track',
                                child: Text(
                                  isRtl ? 'تتبع مباشر' : 'Live tracking',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'invite',
                                child: Text(
                                  isRtl
                                      ? 'إنشاء كود دعوة'
                                      : 'Create invite code',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(color: AppTheme.juniorAccent),
              ),
              error: (e, _) => Text('${isRtl ? "خطأ" : "Error"}: $e'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _createInvite(
    BuildContext context,
    WidgetRef ref,
    String runId,
    bool isRtl,
  ) async {
    try {
      final row =
          await ref.read(juniorRepoProvider).createInviteCode(runId: runId);
      final code = row['code']?.toString() ?? '';
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isRtl ? 'كود الدعوة' : 'Invite code'),
          content: SelectableText(
            code.isEmpty
                ? (isRtl ? 'لم يتم إرجاع كود' : 'No code returned')
                : code,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isRtl ? 'إغلاق' : 'Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl
                ? 'فشل إنشاء كود الدعوة: $e'
                : 'Failed to create invite code: $e',
          ),
        ),
      );
    }
  }

  static Future<void> _showCreateRunDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Kid>> kidsAsync,
    bool isRtl,
  ) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;

    final kids =
        kidsAsync.maybeWhen(data: (k) => k, orElse: () => const <Kid>[]);
    if (kids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl ? 'أضف طفلاً أولاً' : 'Add a kid first',
          ),
        ),
      );
      return;
    }

    Kid selected = kids.first;
    final pickupLat = TextEditingController(text: '24.7136');
    final pickupLng = TextEditingController(text: '46.6753');
    final dropLat = TextEditingController(text: '24.7743');
    final dropLng = TextEditingController(text: '46.7386');
    DateTime pickupTime = DateTime.now().add(const Duration(hours: 1));

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(isRtl ? 'إنشاء رحلة' : 'Create run'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Kid>(
                    // ignore: deprecated_member_use
                    // ignore: deprecated_member_use
                    value: selected,
                    items: [
                      for (final k in kids)
                        DropdownMenuItem(value: k, child: Text(k.name)),
                    ],
                    onChanged: (v) => setState(() => selected = v ?? selected),
                    decoration: InputDecoration(
                      labelText: isRtl ? 'الطفل' : 'Kid',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pickupLat,
                          decoration: InputDecoration(
                            labelText: isRtl ? 'خط عرض الاستلام' : 'Pickup lat',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: pickupLng,
                          decoration: InputDecoration(
                            labelText: isRtl ? 'خط طول الاستلام' : 'Pickup lng',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dropLat,
                          decoration: InputDecoration(
                            labelText: isRtl ? 'خط عرض التوصيل' : 'Dropoff lat',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: dropLng,
                          decoration: InputDecoration(
                            labelText: isRtl ? 'خط طول التوصيل' : 'Dropoff lng',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isRtl
                              ? 'الاستلام: ${pickupTime.toLocal().toString().split(".").first}'
                              : 'Pickup: ${pickupTime.toLocal().toString().split(".").first}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            initialDate: pickupTime,
                          );
                          if (!ctx.mounted) return;
                          if (d == null) return;
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(pickupTime),
                          );
                          if (!ctx.mounted) return;
                          if (t == null) return;
                          setState(() {
                            pickupTime = DateTime(
                              d.year,
                              d.month,
                              d.day,
                              t.hour,
                              t.minute,
                            );
                          });
                        },
                        child: Text(isRtl ? 'اختيار' : 'Pick'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(isRtl ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.juniorAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRtl ? 'إنشاء' : 'Create'),
              ),
            ],
          ),
        ),
      );

      if (ok != true) return;

      final pLat = double.tryParse(pickupLat.text.trim());
      final pLng = double.tryParse(pickupLng.text.trim());
      final dLat = double.tryParse(dropLat.text.trim());
      final dLng = double.tryParse(dropLng.text.trim());
      if (pLat == null || pLng == null || dLat == null || dLng == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRtl ? 'إحداثيات غير صالحة' : 'Invalid coordinates',
            ),
          ),
        );
        return;
      }

      try {
        await ref.read(juniorRepoProvider).createRun(
              parentId: uid,
              kidId: selected.id,
              pickupLat: pLat,
              pickupLng: pLng,
              dropoffLat: dLat,
              dropoffLng: dLng,
              pickupTime: pickupTime,
            );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRtl ? 'فشل إنشاء الرحلة: $e' : 'Failed to create run: $e',
            ),
          ),
        );
      }
    } finally {
      pickupLat.dispose();
      pickupLng.dispose();
      dropLat.dispose();
      dropLng.dispose();
    }
  }
}
