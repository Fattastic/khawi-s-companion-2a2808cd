import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';
import 'package:khawi_flutter/features/junior/domain/junior_invite_code.dart';
import 'package:khawi_flutter/features/junior/domain/trusted_driver.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_providers.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Screen to add/invite an appointed family driver for Khawi Junior.
class AddKidDriverScreen extends ConsumerStatefulWidget {
  const AddKidDriverScreen({super.key});

  @override
  ConsumerState<AddKidDriverScreen> createState() => _AddKidDriverScreenState();
}

class _AddKidDriverScreenState extends ConsumerState<AddKidDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _relation;
  bool _isLoading = false;
  String? _latestInviteCode;
  DateTime? _latestInviteExpiry;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _inviteDriver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final invite = await ref
          .read(juniorRepoProvider)
          .createFamilyDriverInvite(
            invitedDriverName: _nameController.text.trim(),
            invitedDriverPhone: _normalizedPhone(_phoneController.text.trim()),
            invitedDriverRelation: _relation!,
          );

      final expiresAt = DateTime.tryParse('${invite['expires_at'] ?? ''}');
      setState(() {
        _latestInviteCode = invite['code']?.toString().toUpperCase();
        _latestInviteExpiry = expiresAt?.toLocal();
      });
      ref.invalidate(myJuniorInviteCodesProvider);

      _nameController.clear();
      _phoneController.clear();
      _relation = null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invitation: $e')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invitation created. The family driver is confirmed only after redeeming the code.',
          ),
        ),
      );
    }
  }

  String _normalizedPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return raw;
    if (digits.startsWith('966')) return '+$digits';
    return '+966$digits';
  }

  Future<void> _copyLatestCode() async {
    final code = _latestInviteCode;
    if (code == null || code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  Future<void> _copyInviteMessage() async {
    final code = _latestInviteCode;
    if (code == null || code.isEmpty) return;
    final expiry = _latestInviteExpiry?.toString().split('.').first ?? 'soon';
    final message =
        'Khawi Jr Family Driver Invite\nCode: $code\nExpires: $expiry\nUse this code in Khawi Jr > Family Driver > Redeem invite.';
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite message copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingInvitesAsync = ref.watch(myJuniorInviteCodesProvider);
    final trustedDriversAsync = ref.watch(myTrustedDriversProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'دعوة سائق عائلي' : 'Invite Family Driver'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        children: [
          KhawiMotion.slideUpFadeIn(
            _SecurityHeroCard(isRtl: isRtl),
            index: 0,
          ),
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            _InviteSecurityFlowCard(isRtl: isRtl),
            index: 1,
          ),
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            _InviteFormCard(
              formKey: _formKey,
              nameController: _nameController,
              phoneController: _phoneController,
              relation: _relation,
              isLoading: _isLoading,
              isRtl: isRtl,
              onRelationChanged: (value) => setState(() => _relation = value),
              onSubmit: _inviteDriver,
            ),
            index: 2,
          ),
          if (_latestInviteCode != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            KhawiMotion.slideUpFadeIn(
              _LatestInviteCard(
                code: _latestInviteCode!,
                expiresAt: _latestInviteExpiry,
                isRtl: isRtl,
                onCopy: _copyLatestCode,
                onCopyMessage: _copyInviteMessage,
              ),
              index: 3,
            ),
          ],
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            _InviteListSection(isRtl: isRtl, invitesAsync: pendingInvitesAsync),
            index: 4,
          ),
          const SizedBox(height: AppTheme.spacing16),
          KhawiMotion.slideUpFadeIn(
            _TrustedDriversSection(
              isRtl: isRtl,
              driversAsync: trustedDriversAsync,
            ),
            index: 5,
          ),
        ],
      ),
    );
  }
}

class _SecurityHeroCard extends StatelessWidget {
  const _SecurityHeroCard({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.juniorGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowColored(AppTheme.juniorAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl
                ? 'تأكيد السائق عبر دعوة فقط'
                : 'Invite-Only Driver Confirmation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isRtl
                ? 'لا يتم تأكيد أي سائق عائلي إلا بعد استلام دعوة واسترداد رمز الدعوة.'
                : 'A family driver is only confirmed after receiving and redeeming your invite code.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _InviteSecurityFlowCard extends StatelessWidget {
  const _InviteSecurityFlowCard({required this.isRtl});

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
              isRtl ? 'Security Flow' : 'Security Flow',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            const _FlowStep(
              index: 1,
              title: 'Guardian creates invite',
              subtitle: 'Bound to family identity and expires automatically.',
            ),
            const SizedBox(height: 8),
            const _FlowStep(
              index: 2,
              title: 'Driver redeems secure code',
              subtitle: 'Confirmation only happens from this step.',
            ),
            const SizedBox(height: 8),
            const _FlowStep(
              index: 3,
              title: 'Driver becomes trusted',
              subtitle: 'Now eligible for assigned junior runs.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final int index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppTheme.juniorAccent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InviteFormCard extends StatelessWidget {
  const _InviteFormCard({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.relation,
    required this.isLoading,
    required this.isRtl,
    required this.onRelationChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String? relation;
  final bool isLoading;
  final bool isRtl;
  final ValueChanged<String?> onRelationChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isRtl ? 'بيانات السائق العائلي' : 'Family Driver Details',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isRtl ? 'اسم السائق' : 'Driver name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spacing12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isRtl ? 'رقم الهاتف' : 'Phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  prefixText: '+966 ',
                ),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 9 ? 'Enter valid phone' : null;
                },
              ),
              const SizedBox(height: AppTheme.spacing12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: relation,
                decoration: InputDecoration(
                  labelText: isRtl ? 'صلة القرابة' : 'Relationship',
                  prefixIcon: const Icon(Icons.group_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'mother', child: Text('Mother')),
                  DropdownMenuItem(value: 'father', child: Text('Father')),
                  DropdownMenuItem(value: 'aunt', child: Text('Aunt')),
                  DropdownMenuItem(value: 'uncle', child: Text('Uncle')),
                  DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                  DropdownMenuItem(
                    value: 'family_driver',
                    child: Text('Family Driver'),
                  ),
                ],
                onChanged: onRelationChanged,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spacing16),
              FilledButton.icon(
                onPressed: isLoading ? null : onSubmit,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(isRtl ? 'إرسال الدعوة' : 'Send invitation'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestInviteCard extends StatelessWidget {
  const _LatestInviteCard({
    required this.code,
    required this.expiresAt,
    required this.isRtl,
    required this.onCopy,
    required this.onCopyMessage,
  });

  final String code;
  final DateTime? expiresAt;
  final bool isRtl;
  final VoidCallback onCopy;
  final VoidCallback onCopyMessage;

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        expiresAt != null && expiresAt!.difference(DateTime.now()).inHours < 6;
    return Card(
      elevation: 0,
      color: AppTheme.primaryGreen.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'آخر رمز دعوة' : 'Latest Invite Code',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              code,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryGreenDark,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isExpiringSoon
                    ? AppTheme.warning.withValues(alpha: 0.18)
                    : AppTheme.info.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                isRtl ? 'Pending confirmation' : 'Pending confirmation',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isExpiringSoon ? AppTheme.warning : AppTheme.info,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (expiresAt != null) ...[
              const SizedBox(height: 6),
              Text(
                isRtl
                    ? 'ينتهي: ${expiresAt!.toString().split(".").first}'
                    : 'Expires: ${expiresAt!.toString().split(".").first}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'Share this code with the invited driver. They must redeem it to become trusted.'
                  : 'Share this code with the invited driver. They must redeem it to become trusted.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy),
                    label: Text(isRtl ? 'نسخ الرمز' : 'Copy code'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopyMessage,
                    icon: const Icon(Icons.message_outlined),
                    label: Text(isRtl ? 'نسخ الرسالة' : 'Copy message'),
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

class _InviteListSection extends StatelessWidget {
  const _InviteListSection({
    required this.isRtl,
    required this.invitesAsync,
  });

  final bool isRtl;
  final AsyncValue<List<JuniorInviteCode>> invitesAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'الدعوات الحالية' : 'Pending Invitations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            invitesAsync.when(
              data: (invites) {
                final pending = invites.where((i) => i.isPending).toList();
                if (pending.isEmpty) {
                  return Text(
                    isRtl
                        ? 'لا توجد دعوات معلقة.'
                        : 'No pending invitations yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  );
                }
                return Column(
                  children: pending
                      .map((invite) => _InviteRow(invite: invite, isRtl: isRtl))
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({
    required this.invite,
    required this.isRtl,
  });

  final JuniorInviteCode invite;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final left = invite.expiresAt.toUtc().difference(now);
    final expiringSoon = left.inHours < 6;
    final leftText = left.isNegative
        ? 'Expired'
        : left.inHours >= 1
            ? '${left.inHours}h left'
            : '${left.inMinutes.clamp(1, 59)}m left';
    final totalMs = invite.expiresAt
        .toUtc()
        .difference(invite.createdAt.toUtc())
        .inMilliseconds;
    final leftMs = invite.expiresAt.toUtc().difference(now).inMilliseconds;
    final lifeRatio = totalMs <= 0 ? 0.0 : (leftMs / totalMs).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.juniorAccent.withValues(alpha: 0.14),
            child: const Icon(
              Icons.mark_email_unread,
              color: AppTheme.juniorAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.invitedDriverName?.isNotEmpty == true
                      ? invite.invitedDriverName!
                      : (isRtl ? 'سائق عائلي' : 'Family driver'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${isRtl ? "Code" : "Code"}: ${invite.code}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                if ((invite.invitedDriverRelation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundNeutral,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      invite.invitedDriverRelation!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: expiringSoon
                        ? AppTheme.warning.withValues(alpha: 0.14)
                        : AppTheme.info.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    leftText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              expiringSoon ? AppTheme.warning : AppTheme.info,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                LevelProgressBar(
                  value: lifeRatio,
                  height: 6,
                  backgroundColor: AppTheme.borderLight,
                  gradient: LinearGradient(
                    colors: [
                      expiringSoon ? AppTheme.warning : AppTheme.info,
                      expiringSoon ? AppTheme.warning : AppTheme.info,
                    ],
                  ),
                  glowColor: expiringSoon ? AppTheme.warning : AppTheme.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustedDriversSection extends StatelessWidget {
  const _TrustedDriversSection({
    required this.isRtl,
    required this.driversAsync,
  });

  final bool isRtl;
  final AsyncValue<List<TrustedDriver>> driversAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'السائقون المؤكدون' : 'Confirmed Family Drivers',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            driversAsync.when(
              data: (drivers) {
                final active = drivers.where((d) => d.isActive).toList();
                if (active.isEmpty) {
                  return Text(
                    isRtl
                        ? 'لا يوجد سائقون مؤكدون حتى الآن.'
                        : 'No confirmed family drivers yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  );
                }
                return Column(
                  children: active
                      .map(
                        (driver) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryGreen.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.verified_user,
                              color: AppTheme.primaryGreenDark,
                            ),
                          ),
                          title: Text(
                            driver.label ??
                                (isRtl ? 'سائق عائلي' : 'Family Driver'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${isRtl ? "Driver ID" : "Driver ID"}: ${_shortId(driver.driverId)}',
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 10) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }
}
