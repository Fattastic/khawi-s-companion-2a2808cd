import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

class PassengerSliverHeader extends ConsumerWidget {
  const PassengerSliverHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final l10n = AppLocalizations.of(context);

    return SliverAppBar(
      expandedHeight: 210,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.passengerGradient),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              end: 24,
              bottom: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (p) {
                    final raw = (p.fullName).trim();
                    final firstName =
                        raw.isEmpty ? '' : raw.split(RegExp(r'\\s+')).first;
                    final greeting = firstName.isEmpty
                        ? (l10n?.hello ?? 'Hello!')
                        : (l10n?.homeGreetingWithName(firstName) ??
                            'Good morning, $firstName!');
                    return Text(
                      greeting,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                      textAlign: TextAlign.start,
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => Text(
                    l10n?.hello ?? 'Hello!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.homeTitle ?? 'Ready for your daily commute?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(Routes.passengerScan),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          tooltip: l10n?.rideNow ?? 'Ride Now',
        ),
        IconButton(
          onPressed: () => context.push(Routes.sharedNotifications),
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          tooltip: l10n?.notifications ?? 'Notifications',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
