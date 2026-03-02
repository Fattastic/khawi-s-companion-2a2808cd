import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/events/domain/khawi_event.dart';

/// Detail screen for a single event: rides going/returning + interest.
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  KhawiEvent? _event;
  List<EventRide> _ridesToEvent = [];
  List<EventRide> _ridesFromEvent = [];
  EventInterest? _myInterest;
  int _interestedCount = 0;
  bool _loading = true;
  bool _interestBusy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(userIdProvider);
      final repo = ref.read(eventRepoProvider);

      final results = await Future.wait([
        repo.fetchById(widget.eventId),
        repo.fetchEventRides(
          widget.eventId,
          direction: EventRideDirection.to,
        ),
        repo.fetchEventRides(
          widget.eventId,
          direction: EventRideDirection.from,
        ),
        if (userId != null)
          repo.getInterest(widget.eventId, userId)
        else
          Future.value(null),
        repo.interestCount(widget.eventId),
      ]);

      if (!mounted) return;
      setState(() {
        _event = results[0] as KhawiEvent;
        _ridesToEvent = results[1] as List<EventRide>;
        _ridesFromEvent = results[2] as List<EventRide>;
        _myInterest = results[3] as EventInterest?;
        _interestedCount = results[4] as int;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _toggleInterest(EventInterestStatus status) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;
    if (_interestBusy) return;

    setState(() => _interestBusy = true);

    final repo = ref.read(eventRepoProvider);
    try {
      if (_myInterest != null && _myInterest!.status == status) {
        await repo.removeInterest(widget.eventId, userId);
      } else {
        await repo.markInterest(
          eventId: widget.eventId,
          userId: userId,
          status: status,
        );
      }
      unawaited(_loadData());
    } finally {
      if (mounted) {
        setState(() => _interestBusy = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = isRtl ? 'ar' : 'en';

    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGreen,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final event = _event;
    if (event == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGreen,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(l10n.errorGeneric)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: CustomScrollView(
        slivers: [
          // Header image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.displayTitle(locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              background: event.imageUrl != null
                  ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          event.category.emoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
            ),
          ),

          // Event info card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${event.category.emoji} ${event.category.label(locale)}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (event.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🔴 LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date + Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.formattedDate} • ${event.formattedTime}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Venue
                  if (event.venueName != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            event.venueName!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Organizer
                  if (event.organizer != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.organizer!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                        icon: Icons.people,
                        value: '$_interestedCount',
                        label: l10n.interested,
                      ),
                      _MiniStat(
                        icon: Icons.directions_car,
                        value: '${event.rideCount}',
                        label: l10n.ridesAvailable,
                      ),
                      if (event.expectedAttendance > 0)
                        _MiniStat(
                          icon: Icons.groups,
                          value: '${event.expectedAttendance}',
                          label: l10n.expected,
                        ),
                    ],
                  ),

                  // Description
                  if (event.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      event.description!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Interest buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _InterestButton(
                      icon: Icons.star_outline,
                      label: l10n.interested,
                      isActive:
                          _myInterest?.status == EventInterestStatus.interested,
                      isDisabled: _interestBusy,
                      onTap: () =>
                          _toggleInterest(EventInterestStatus.interested),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InterestButton(
                      icon: Icons.check_circle_outline,
                      label: l10n.going,
                      isActive:
                          _myInterest?.status == EventInterestStatus.going,
                      isDisabled: _interestBusy,
                      onTap: () => _toggleInterest(EventInterestStatus.going),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rides tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryGreen,
                  tabs: [
                    Tab(
                      text: '${l10n.goingTo} (${_ridesToEvent.length})',
                    ),
                    Tab(
                      text: '${l10n.returning} (${_ridesFromEvent.length})',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rides list (using SliverFillRemaining for tab-like switching)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRidesList(_ridesToEvent, locale, l10n),
                  _buildRidesList(_ridesFromEvent, locale, l10n),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildRidesList(
    List<EventRide> rides,
    String locale,
    AppLocalizations l10n,
  ) {
    if (rides.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noRidesYet,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.beFirstToOfferRide,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        return _EventRideCard(ride: rides[index], locale: locale);
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }
}

class _InterestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;

  const _InterestButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppTheme.primaryGreen.withValues(alpha: 0.15)
          : Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.check_circle : icon,
                size: 20,
                color: isActive
                    ? AppTheme.primaryGreen
                    : (isDisabled ? Colors.grey[400] : Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppTheme.primaryGreen
                      : (isDisabled ? Colors.grey[400] : Colors.grey[700]),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventRideCard extends StatelessWidget {
  final EventRide ride;
  final String locale;

  const _EventRideCard({required this.ride, required this.locale});

  @override
  Widget build(BuildContext context) {
    final trip = ride.tripData ?? {};
    final poster = ride.posterData ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver info
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: poster['avatar_url'] != null
                      ? CachedNetworkImageProvider(
                          poster['avatar_url'] as String,)
                      : null,
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  child: poster['avatar_url'] == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    (poster['full_name'] as String?) ?? 'Driver',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ride.direction == EventRideDirection.to
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.direction.label(locale),
                    style: TextStyle(
                      color: ride.direction == EventRideDirection.to
                          ? AppTheme.primaryGreen
                          : Colors.orange[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Route
            Row(
              children: [
                const Icon(
                  Icons.trip_origin,
                  size: 14,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (trip['origin_label'] as String?) ?? '—',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (trip['dest_label'] as String?) ?? '—',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ride.seatsOffered > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.event_seat, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    '${ride.seatsOffered}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            if (ride.message != null) ...[
              const SizedBox(height: 6),
              Text(
                ride.message!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
