import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';
import 'package:khawi_flutter/core/widgets/khawi_button.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

String _sanitizeDisplayText(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return '';
  final lower = value.toLowerCase();
  const invalidTokens = {
    'n/a',
    'na',
    'none',
    'null',
    '-',
    '--',
    'غير متوفر',
    'غير متاح',
    'not available',
  };
  return invalidTokens.contains(lower) ? '' : value;
}

String formatVehicleSummary({
  required bool isArabic,
  String? vehicleModel,
  String? vehiclePlateNumber,
}) {
  final model = _sanitizeDisplayText(vehicleModel);
  final plate = _sanitizeDisplayText(vehiclePlateNumber);
  if (model.isEmpty && plate.isEmpty) {
    return isArabic ? 'غير متوفر' : 'Not available';
  }
  if (model.isNotEmpty && plate.isNotEmpty) {
    return '$model • $plate';
  }
  return model.isNotEmpty ? model : plate;
}

String formatEtaSummary({
  required bool isArabic,
  int? etaMinutes,
}) {
  if (etaMinutes == null || etaMinutes <= 0) {
    return isArabic ? 'جاري الحساب...' : 'Calculating...';
  }
  return isArabic ? '$etaMinutes د' : '$etaMinutes min';
}

String formatDepartureRelativeLabel({
  required bool isArabic,
  required DateTime departureTime,
  DateTime? now,
}) {
  final mins = departureTime.difference(now ?? DateTime.now()).inMinutes;
  if (mins <= 0) return isArabic ? 'انطلاق الآن' : 'Departing now';
  if (mins < 60) return isArabic ? 'ينطلق بعد $mins د' : 'Departs in $mins min';
  final hours = mins ~/ 60;
  final rem = mins % 60;
  if (rem == 0) {
    return isArabic ? 'ينطلق بعد $hours س' : 'Departs in ${hours}h';
  }
  return isArabic
      ? 'ينطلق بعد $hours س $rem د'
      : 'Departs in ${hours}h ${rem}m';
}

String formatRouteSummary({
  required String pickupFallback,
  required String destinationFallback,
  String? originLabel,
  String? destinationLabel,
}) {
  final origin = _sanitizeDisplayText(originLabel);
  final destination = _sanitizeDisplayText(destinationLabel);
  final safeOrigin = origin.isNotEmpty ? origin : pickupFallback;
  final safeDestination =
      destination.isNotEmpty ? destination : destinationFallback;
  return '$safeOrigin → $safeDestination';
}

String formatStopsSummary({
  required bool isArabic,
  required Iterable<String?> waypointLabels,
}) {
  final labels = waypointLabels
      .map((label) => _sanitizeDisplayText(label?.split(',').first))
      .where((label) => label.isNotEmpty)
      .toList(growable: false);

  if (labels.isEmpty) {
    return isArabic ? 'بدون محطات' : 'No stops';
  }
  return labels.join(' • ');
}

final _driverVehicleProvider =
    FutureProvider.family<Profile, String>((ref, driverId) async {
  return ref.watch(profileRepoProvider).fetchProfileById(driverId);
});

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, this.tripId});

  final String? tripId;

  String _txt(BuildContext context, {required String en, required String ar}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? ar : en;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final stream =
        tripId == null ? null : ref.read(tripsRepoProvider).watchTrip(tripId!);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_txt(context, en: 'Booking confirmation', ar: 'تأكيد الحجز')),
      ),
      body: StreamBuilder<Trip>(
        stream: stream,
        builder: (context, snapshot) {
          final trip = snapshot.data;
          final localeName = Localizations.localeOf(context).toLanguageTag();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerEffect(
                  child: Text(
                    _txt(
                      context,
                      en: 'Your booking request was sent.',
                      ar: 'تم إرسال طلب الحجز بنجاح.',
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_txt(context, en: 'Trip', ar: 'الرحلة')}: ${tripId ?? _txt(context, en: 'unknown', ar: 'غير معروف')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (trip != null) ...[
                  const SizedBox(height: 20),
                  _InfoCard(
                    icon: Icons.route,
                    title: l10n.routeDetails,
                    value: formatRouteSummary(
                      pickupFallback: l10n.pickup,
                      destinationFallback: l10n.destination,
                      originLabel: trip.originLabel,
                      destinationLabel: trip.destLabel,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.schedule,
                    title: _txt(context, en: 'Departure', ar: 'موعد الانطلاق'),
                    value:
                        '${DateFormat.yMMMd(localeName).add_jm().format(trip.departureTime)} • ${formatDepartureRelativeLabel(isArabic: isArabic, departureTime: trip.departureTime)}',
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.access_time,
                    title: l10n.eta,
                    value: formatEtaSummary(
                      isArabic: isArabic,
                      etaMinutes: trip.etaMinutes,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ref.watch(_driverVehicleProvider(trip.driverId)).when(
                        data: (driverProfile) => _InfoCard(
                          icon: Icons.directions_car,
                          title: _txt(context, en: 'Vehicle', ar: 'السيارة'),
                          value: formatVehicleSummary(
                            isArabic: isArabic,
                            vehicleModel: driverProfile.vehicleModel,
                            vehiclePlateNumber:
                                driverProfile.vehiclePlateNumber,
                          ),
                        ),
                        loading: () => _InfoCard(
                          icon: Icons.directions_car,
                          title: _txt(context, en: 'Vehicle', ar: 'السيارة'),
                          value: _txt(
                            context,
                            en: 'Loading vehicle details...',
                            ar: 'جارٍ تحميل تفاصيل السيارة...',
                          ),
                        ),
                        error: (_, __) => _InfoCard(
                          icon: Icons.directions_car,
                          title: _txt(context, en: 'Vehicle', ar: 'السيارة'),
                          value: _txt(
                            context,
                            en: 'Not available',
                            ar: 'غير متوفر',
                          ),
                        ),
                      ),
                  if (trip.waypoints.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.alt_route,
                      title: _txt(context, en: 'Stops', ar: 'المحطات'),
                      value: formatStopsSummary(
                        isArabic: isArabic,
                        waypointLabels: trip.waypoints.map((w) => w.label),
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                KhawiButton(
                  onPressed: () => context.go(Routes.passengerTrips),
                  text: _txt(context, en: 'View my trips', ar: 'عرض رحلاتي'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      hasShadow: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
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
