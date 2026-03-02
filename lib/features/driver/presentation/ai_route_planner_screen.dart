import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/driver/domain/smart_route_suggestion.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';

class AiRoutePlannerScreen extends ConsumerWidget {
  const AiRoutePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final stream = ref.watch(tripsRepoProvider).watchMyTrips(userId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          l10n?.aiRoutePlannerTitle ?? "AI Route Planner",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF3F0081),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<List<Trip>>(
          stream: stream,
          builder: (context, snapshot) {
            final trips = snapshot.data ?? const <Trip>[];
            final suggestions = buildSmartRouteSuggestions(trips);
            final patterns = detectCommutePatterns(trips);

            final highScoreCount =
                trips.where((t) => (t.matchScore ?? 0) >= 80).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureCard(
                  Icons.timeline,
                  l10n?.optimalStartTime ?? "Optimal Start Time",
                  suggestions.isNotEmpty
                      ? 'Top suggestion departs at ${_formatTime(suggestions.first.departureTime)}'
                      : 'Create rides to generate smart route timing suggestions.',
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  Icons.bolt,
                  l10n?.highDemandAreas ?? "High Demand Areas",
                  '$highScoreCount high-match routes • ${patterns.length} commute patterns detected.',
                  Colors.amber,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  Icons.auto_graph,
                  'Commute Pattern Detector',
                  patterns.isNotEmpty
                      ? 'Top pattern: ${patterns.first.timeWindowLabel} • ${patterns.first.frequency} similar rides'
                      : 'Insufficient trip history for pattern detection yet.',
                  Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n?.suggestedRoutes ?? "Suggested Routes",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CircularProgressIndicator()
                else if (suggestions.isEmpty)
                  Text(
                    'No route suggestions yet. Offer recurring or planned rides to train Smart Route Suggestions.',
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  )
                else
                  ...suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRouteOption(
                        s.title,
                        _formatTime(s.departureTime),
                        '${s.estimatedDurationMinutes} mins',
                        s.confidenceLabel,
                        subtitle: s.reason,
                      ),
                    ),
                  ),
                if (patterns.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Detected Commute Patterns',
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...patterns.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPatternCard(p),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.driverOfferRide),
        backgroundColor: const Color(0xFF3F0081),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          l10n?.confirmSchedule ?? "Confirm Schedule",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOption(
    String title,
    String time,
    String duration,
    String tag, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3F0081),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(duration, style: GoogleFonts.inter(color: Colors.grey)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(CommutePattern pattern) {
    final badgeColor = pattern.isPeakWindow ? Colors.orange : Colors.blue;
    final badgeText = pattern.isPeakWindow ? 'Peak window' : 'Stable window';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pattern.routeLabel,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                pattern.timeWindowLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Text(
                '${pattern.frequency} rides',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }
}
