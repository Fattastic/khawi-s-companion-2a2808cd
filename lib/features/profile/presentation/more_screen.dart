import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/app_settings.dart';

class MoreScreen extends ConsumerWidget {
  final bool isJunior;
  const MoreScreen({super.key, this.isJunior = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final activeRole = ref.watch(activeRoleProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: profileAsync.when(
        data: (profile) => CustomScrollView(
          slivers: [
            _buildSliverHeader(context, profile, theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSectionHeader(
                      l10n.morePremiumSection,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumCard(context, isRtl),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      l10n.moreAccountSettings,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      Icons.person_outline,
                      l10n.morePersonalInformation,
                      () => _comingSoon(context, l10n, isRtl),
                      isRtl: isRtl,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.language,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  isRtl
                                      ? l10n.languageArabic
                                      : l10n.languageEnglish,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isRtl,
                            // ignore: deprecated_member_use
                            // ignore: deprecated_member_use
                            activeColor: AppTheme.primaryGreen,
                            onChanged: (bool val) {
                              ref.read(localeProvider.notifier).setLocale(
                                    val
                                        ? const Locale('ar')
                                        : const Locale('en'),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dark mode toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.dark_mode_outlined,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isRtl ? 'الوضع الداكن' : 'Dark Mode',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Switch(
                            value: ref.watch(themeModeProvider).value ==
                                ThemeMode.dark,
                            activeTrackColor: AppTheme.primaryGreen,
                            onChanged: (bool val) {
                              ref.read(themeModeProvider.notifier).setThemeMode(
                                    val ? ThemeMode.dark : ThemeMode.light,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuTile(
                      Icons.swap_horiz,
                      l10n.moreSwitchRole,
                      () => _showRoleSwitcher(
                        context,
                        ref,
                        profile,
                        activeRole,
                        l10n,
                      ),
                      subtitle: _roleLabel(activeRole, l10n) ?? '',
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.payment_outlined,
                      l10n.xpLedger,
                      () {
                        if (activeRole == UserRole.passenger) {
                          context.push(Routes.passengerXpLedger);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.moreXpLedgerPassengerOnly,
                              ),
                            ),
                          );
                        }
                      },
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.history,
                      l10n.tripHistory,
                      () {
                        final role = ref.read(activeRoleProvider);
                        if (role == UserRole.driver) {
                          context.push(Routes.driverHistory);
                        } else {
                          context.push(Routes.passengerHistory);
                        }
                      },
                      isRtl: isRtl,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      l10n.moreSocial,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      Icons.groups,
                      l10n.communities,
                      () => context.push(Routes.communities),
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.event,
                      l10n.eventRides,
                      () => context.push(Routes.events),
                      isRtl: isRtl,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      l10n.moreGeneral,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      Icons.settings_outlined,
                      isRtl ? 'الإعدادات' : 'Settings',
                      () => context.push(Routes.settings),
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.help_outline,
                      l10n.moreHelpCenter,
                      () => context.push(Routes.helpCenter),
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.share_outlined,
                      l10n.moreInviteFriends,
                      () => context.push('/referral'),
                      isRtl: isRtl,
                    ),
                    _buildMenuTile(
                      Icons.info_outline,
                      l10n.moreAboutKhawi,
                      () => context.push(Routes.about),
                      isRtl: isRtl,
                    ),
                    const SizedBox(height: 48),
                    _buildLogoutButton(context, ref, isRtl),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('${l10n.somethingWentWrong}: $err')),
      ),
    );
  }

  Widget _buildSliverHeader(
    BuildContext context,
    Profile profile,
    ThemeData theme,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.push(
                  Routes.trustTier,
                  extra: {
                    'trustScore': profile.trustScore?.toInt() ?? 0,
                    'badge': profile.trustBadge ?? 'bronze',
                    'isJuniorTrusted': false,
                  },
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 94,
                      height: 94,
                      child: CircularProgressIndicator(
                        value: (profile.totalXp % 1000) / 1000,
                        backgroundColor: Colors.white24,
                        color: AppTheme.accentGold,
                        strokeWidth: 4,
                      ),
                    ),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage: profile.avatarUrl != null
                          ? CachedNetworkImageProvider(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: AppTheme.accentGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Level ${profile.totalXp ~/ 1000 + 1} Member",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              if (profile.isPremium) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppTheme.accentGold,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Khawi+ Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isRtl) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.push(Routes.subscription),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.premiumGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.shadowColored(AppTheme.primaryGreen),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppTheme.accentGold,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.moreUpgradeToPremium,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.morePremiumSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
    bool isRtl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, bool isRtl) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await ref.read(authRepoProvider).signOut();
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: Text(
          l10n.logout,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, AppLocalizations l10n, bool isRtl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.moreComingSoon,
        ),
      ),
    );
  }

  String? _roleLabel(UserRole? role, AppLocalizations l10n) {
    return switch (role) {
      UserRole.passenger => l10n.iAmAPassenger,
      UserRole.driver => l10n.iAmADriver,
      UserRole.junior => l10n.roleJuniorTitle,
      null => null,
    };
  }

  Future<void> _showRoleSwitcher(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    UserRole? activeRole,
    AppLocalizations l10n,
  ) async {
    final next = await showModalBottomSheet<UserRole>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.moreSwitchRole,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.iAmAPassenger),
                trailing: activeRole == UserRole.passenger
                    ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                    : null,
                onTap: () => Navigator.pop(ctx, UserRole.passenger),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car_outlined),
                title: Text(l10n.iAmADriver),
                trailing: activeRole == UserRole.driver
                    ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                    : null,
                onTap: () => Navigator.pop(ctx, UserRole.driver),
              ),
            ],
          ),
        );
      },
    );

    if (next == null) return;
    if (next == activeRole) return;

    // Persist preferred role and move to the correct shell without glitches.
    ref.read(activeRoleProvider.notifier).setRole(next);
    // Fire-and-forget DB update; realtime stream will reconcile.
    // ignore: unawaited_futures
    ref.read(profileActionsProvider).setRole(profile.id, next);

    if (!context.mounted) return;
    context.go(
      switch (next) {
        UserRole.passenger => Routes.passengerHome,
        UserRole.driver => Routes.driverDashboard,
        UserRole.junior => Routes.juniorHub,
      },
    );
  }
}
