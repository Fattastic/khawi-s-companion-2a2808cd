import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/models/user_role.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/services/verification/verification_providers.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Driver Verification Screen showing:
/// - Identity verification status (Nafath preferred)
/// - Vehicle ownership verification status (official + manual fallback)
/// - Consent disclosure
/// - "Continue to Dashboard" when fully verified
class NafathVerificationScreen extends ConsumerStatefulWidget {
  const NafathVerificationScreen({super.key});

  @override
  ConsumerState<NafathVerificationScreen> createState() =>
      _NafathVerificationScreenState();
}

class _NafathVerificationScreenState
    extends ConsumerState<NafathVerificationScreen> {
  bool _identityLoading = false;
  bool _vehicleLoading = false;
  bool _consentGiven = false;

  // Vehicle form fields (manual fallback)
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  bool _showVehicleForm = false;

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(l10n.driverVerificationAppBarTitle),
        backgroundColor: AppTheme.backgroundGreen,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go(Routes.authRole),
            child: Text(
              l10n.driverVerificationNotNow,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('${l10n.somethingWentWrong}: $e'),
          ),
          data: (profile) {
            final isDriver = profile.role == UserRole.driver;
            final idVerified = profile.isIdentityVerified || profile.isVerified;
            final vehStatus = profile.vehicleVerificationStatus;
            final vehApproved = vehStatus == 'approved';
            final vehPending = vehStatus == 'pending';

            // For V3, identity verification is the primary objective for everyone.
            // Vehicle is only for drivers.
            final allDone = idVerified && (!isDriver || vehApproved);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                textDirection: Directionality.of(context),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDriver
                        ? l10n.driverVerificationHeader
                        : (isRtl ? 'توثيق الهوية' : 'Identity Verification'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDriver
                        ? l10n.driverVerificationBody
                        : (isRtl
                            ? 'وثق هويتك لتتمكن من الانضمام للدوائر الوردية ورفع مستوى ثقتك في المجتمع.'
                            : 'Verify your identity to join Pink Circles and elevate your trust tier in the community.'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 24),
                  _VerificationCard(
                    icon: Icons.fingerprint,
                    title: l10n.driverVerificationIdentityTitle,
                    subtitle: l10n.driverVerificationIdentitySubtitle,
                    status: idVerified
                        ? _VerificationState.verified
                        : _VerificationState.notStarted,
                    statusLabel: idVerified
                        ? l10n.driverVerificationStatusVerified
                        : l10n.driverVerificationStatusNotVerified,
                    actionLabel: idVerified
                        ? null
                        : l10n.driverVerificationActionVerifyWithNafath,
                    loading: _identityLoading,
                    onAction:
                        idVerified ? null : () => _verifyIdentity(profile.id),
                  ),
                  if (isDriver) ...[
                    const SizedBox(height: 16),
                    _VerificationCard(
                      icon: Icons.directions_car,
                      title: l10n.driverVerificationVehicleTitle,
                      subtitle: l10n.driverVerificationVehicleSubtitle,
                      status: vehApproved
                          ? _VerificationState.verified
                          : vehPending
                              ? _VerificationState.pending
                              : _VerificationState.notStarted,
                      statusLabel: vehApproved
                          ? l10n.driverVerificationStatusApproved
                          : vehPending
                              ? l10n.driverVerificationStatusPending
                              : l10n.driverVerificationStatusNotVerified,
                      actionLabel: (vehApproved || vehPending)
                          ? null
                          : l10n.driverVerificationActionVerifyVehicle,
                      loading: _vehicleLoading,
                      onAction: (vehApproved || vehPending)
                          ? null
                          : () => setState(() => _showVehicleForm = true),
                    ),
                    if (_showVehicleForm && !vehApproved && !vehPending) ...[
                      const SizedBox(height: 20),
                      _buildVehicleForm(theme, profile.id, l10n),
                    ],
                  ],
                  const SizedBox(height: 24),
                  if (!allDone) _buildConsentSection(theme, isRtl, l10n),
                  if (allDone) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => context.go(isDriver
                            ? Routes.driverDashboard
                            : Routes.passengerHome,),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textDirection: Directionality.of(context),
                          children: [
                            Text(
                              isDriver
                                  ? l10n.driverVerificationContinue
                                  : (isRtl
                                      ? 'العودة للرئيسية'
                                      : 'Back to Home'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              isRtl ? Icons.arrow_back : Icons.arrow_forward,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isDriver && vehPending && !vehApproved) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        textDirection: Directionality.of(context),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.hourglass_empty,
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.driverVerificationPendingNotice,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _verifyIdentity(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_consentGiven) {
      _showConsentNeeded(l10n);
      return;
    }
    setState(() => _identityLoading = true);
    try {
      final verifier = ref.read(identityVerifierProvider);
      final result = await verifier.verify(userId);
      if (result.success) {
        await ref.read(profileActionsProvider).setVerificationStatus(
              userId,
              isVerified: true,
            );
        ref.invalidate(myProfileProvider);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ?? l10n.driverVerificationVerificationFailed,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.somethingWentWrong}: $e')),
        );
      }
    }
    if (mounted) setState(() => _identityLoading = false);
  }

  Widget _buildVehicleForm(
    ThemeData theme,
    String userId,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverVerificationVehicleDetailsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _plateController,
            decoration: InputDecoration(
              labelText: l10n.driverVerificationPlateLabel,
              hintText: l10n.driverVerificationPlateHint,
              border: const OutlineInputBorder(),
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: l10n.driverVerificationModelLabel,
              hintText: l10n.driverVerificationModelHint,
              border: const OutlineInputBorder(),
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.driverVerificationVehicleLaterNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _vehicleLoading
                  ? null
                  : () => _submitVehicleVerification(userId),
              child: _vehicleLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.driverVerificationSubmitForReview),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVehicleVerification(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_consentGiven) {
      _showConsentNeeded(l10n);
      return;
    }
    if (_plateController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverVerificationFillVehicleFieldsError)),
      );
      return;
    }

    setState(() => _vehicleLoading = true);
    try {
      final verifier = ref.read(vehicleOwnershipVerifierProvider);
      await verifier.verify(
        userId,
        request: VehicleVerificationRequest(
          method: 'manual',
          plateNumber: _plateController.text.trim(),
          vehicleModel: _modelController.text.trim(),
        ),
      );
      ref.invalidate(myProfileProvider);
      if (mounted) setState(() => _showVehicleForm = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.somethingWentWrong}: $e')),
        );
      }
    }
    if (mounted) setState(() => _vehicleLoading = false);
  }

  Widget _buildConsentSection(
    ThemeData theme,
    bool isRtl,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverVerificationDataDisclosureTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.info,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          _DisclosureBullet(text: l10n.driverVerificationDisclosureIdentity),
          const SizedBox(height: 6),
          _DisclosureBullet(text: l10n.driverVerificationDisclosureVehicle),
          const SizedBox(height: 6),
          _DisclosureBullet(text: l10n.driverVerificationDisclosurePurpose),
          const SizedBox(height: 6),
          _DisclosureBullet(text: l10n.driverVerificationDisclosureRetention),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: isRtl
                ? ListTileControlAffinity.trailing
                : ListTileControlAffinity.leading,
            value: _consentGiven,
            onChanged: (v) => setState(() => _consentGiven = v ?? false),
            title: Text(
              l10n.driverVerificationConsentCheckbox,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  void _showConsentNeeded(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driverVerificationConsentNeeded)),
    );
  }
}

enum _VerificationState { notStarted, pending, verified }

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _VerificationState status;
  final String statusLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = switch (status) {
      _VerificationState.verified => AppTheme.success,
      _VerificationState.pending => AppTheme.warning,
      _VerificationState.notStarted => AppTheme.borderColor,
    };
    final statusColor = switch (status) {
      _VerificationState.verified => AppTheme.success,
      _VerificationState.pending => AppTheme.warning,
      _VerificationState.notStarted => AppTheme.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(icon, color: borderColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  textDirection: Directionality.of(context),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: Directionality.of(context),
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      onPressed: loading ? null : onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              actionLabel!,
                              style: const TextStyle(fontSize: 13),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DisclosureBullet extends StatelessWidget {
  const _DisclosureBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      textDirection: Directionality.of(context),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•', style: TextStyle(height: 1.4)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
