import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart' as ll;
import 'package:share_plus/share_plus.dart';

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_receipt_export.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_receipt_summary.dart';
import 'package:khawi_flutter/features/ride_history/domain/trip_route_map_preview.dart';

class TripReceiptSheet extends StatelessWidget {
  final RideHistoryEntry entry;

  const TripReceiptSheet({
    super.key,
    required this.entry,
  });

  static Future<void> show(BuildContext context, RideHistoryEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TripReceiptSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final summary = buildRideReceiptSummary(entry);
    final routePreview = buildTripRouteMapPreview(entry);
    final routePoints = routePreview.path
        .map((point) => ll.LatLng(point.lat, point.lng))
        .toList();
    final exportText = buildRideReceiptExportText(
      entry: entry,
      summary: summary,
      isArabic: isRtl,
    );
    final departure =
        intl.DateFormat.yMMMd(localeName).add_jm().format(entry.departureTime);
    final completedAt = entry.completedAt == null
        ? (isRtl ? 'غير متاح' : 'N/A')
        : intl.DateFormat.yMMMd(localeName).add_jm().format(entry.completedAt!);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRtl ? 'إيصال الرحلة' : 'Trip Receipt',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${summary.receiptNumber}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _row(context, isRtl ? 'الرحلة' : 'Trip ID', entry.tripId),
              _row(context, isRtl ? 'المغادرة' : 'Departure', departure),
              _row(context, isRtl ? 'الاكتمال' : 'Completed', completedAt),
              _row(
                context,
                isRtl ? 'من' : 'From',
                entry.originLabel ?? (isRtl ? 'نقطة الانطلاق' : 'Origin'),
              ),
              _row(
                context,
                isRtl ? 'إلى' : 'To',
                entry.destLabel ?? (isRtl ? 'الوجهة' : 'Destination'),
              ),
              const SizedBox(height: 14),
              Text(
                isRtl ? 'ملخص المسار' : 'Route Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: ll.LatLng(
                          routePreview.centerLat,
                          routePreview.centerLng,
                        ),
                        initialZoom: routePreview.initialZoom,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.khawi.app.khawi_app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              color: AppTheme.primaryGreen,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: routePoints.first,
                              width: 24,
                              height: 24,
                              child: const Icon(
                                Icons.trip_origin,
                                color: AppTheme.info,
                                size: 20,
                              ),
                            ),
                            Marker(
                              point: routePoints.last,
                              width: 28,
                              height: 28,
                              child: const Icon(
                                Icons.location_on,
                                color: AppTheme.error,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (routePreview.waypointCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    isRtl
                        ? 'التوقفات: ${routePreview.waypointCount}'
                        : 'Stops: ${routePreview.waypointCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              if (entry.waypointLabels.isNotEmpty)
                _row(
                  context,
                  isRtl ? 'التوقفات' : 'Stops',
                  entry.waypointLabels.join(' • '),
                ),
              if (entry.distanceKm != null)
                _row(
                  context,
                  isRtl ? 'المسافة' : 'Distance',
                  '${entry.distanceKm!.toStringAsFixed(1)} ${isRtl ? 'كم' : 'km'}',
                ),
              _row(
                context,
                isRtl ? 'المدة التقديرية' : 'Estimated Duration',
                '${summary.durationMinutes} ${isRtl ? 'دقيقة' : 'min'}',
              ),
              _row(
                context,
                isRtl ? 'الأجرة التقديرية (معلومة)' : 'Estimated Fare (Info)',
                '${summary.estimatedFareSar.toStringAsFixed(2)} SAR',
              ),
              _row(
                context,
                isRtl ? 'تقسيم الراكب (معلومة)' : 'Per Passenger Share (Info)',
                '${summary.estimatedPerPassengerSar.toStringAsFixed(2)} SAR',
              ),
              if (entry.co2SavedKg != null)
                _row(
                  context,
                  isRtl ? 'CO₂ الموفّر' : 'CO₂ Saved',
                  '${entry.co2SavedKg!.toStringAsFixed(1)} kg',
                ),
              _row(
                context,
                isRtl ? 'نقاط XP' : 'XP Earned',
                '+${entry.xpEarned ?? 45} XP',
                valueColor: AppTheme.primaryGreenDark,
              ),
              if (entry.ratingGiven != null)
                _row(
                  context,
                  isRtl ? 'تقييمك' : 'Your Rating',
                  '${entry.ratingGiven} ★',
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: exportText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isRtl
                                ? 'تم نسخ بيانات الإيصال'
                                : 'Receipt details copied',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: Text(
                    isRtl ? 'نسخ بيانات الإيصال' : 'Copy Receipt Details',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Share.share(
                      exportText,
                      subject: isRtl ? 'إيصال الرحلة' : 'Trip Receipt',
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: Text(isRtl ? 'مشاركة الإيصال' : 'Share Receipt'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isRtl ? 'تم' : 'Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
