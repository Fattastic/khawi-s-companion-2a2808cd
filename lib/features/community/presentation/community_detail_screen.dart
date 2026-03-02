import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/community/domain/community.dart';

/// Screen for viewing a community's ride board and members.
class CommunityDetailScreen extends ConsumerStatefulWidget {
  final String communityId;
  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  Community? _community;
  List<CommunityRide> _rides = [];
  List<Map<String, dynamic>> _members = [];
  bool _isMember = false;
  bool _loading = true;
  bool _membershipBusy = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final repo = ref.read(communityRepoProvider);
      final results = await Future.wait([
        repo.fetchById(widget.communityId),
        repo.fetchCommunityRides(widget.communityId),
        repo.fetchMembers(widget.communityId),
        repo.isMember(widget.communityId, userId),
      ]);

      if (!mounted) return;
      setState(() {
        _community = results[0] as Community;
        _rides = results[1] as List<CommunityRide>;
        _members = results[2] as List<Map<String, dynamic>>;
        _isMember = results[3] as bool;
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

  Future<void> _toggleMembership() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;
    if (_membershipBusy) return;

    setState(() => _membershipBusy = true);

    final repo = ref.read(communityRepoProvider);
    try {
      if (_isMember) {
        await repo.leave(widget.communityId, userId);
      } else {
        await repo.join(widget.communityId, userId);
      }
      unawaited(_loadData());
    } finally {
      if (mounted) {
        setState(() => _membershipBusy = false);
      }
    }
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

    final community = _community;
    if (community == null) {
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
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                community.displayName(locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              background: community.coverUrl != null
                  ? Image.network(community.coverUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          community.typeEmoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
            ),
            actions: [
              _membershipBusy
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _toggleMembership,
                      child: Text(
                        _isMember ? l10n.leaveCommunity : l10n.joinCommunity,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.people,
                    value: '${community.memberCount}',
                    label: l10n.members,
                  ),
                  _StatItem(
                    icon: Icons.directions_car,
                    value: '${_rides.length}',
                    label: l10n.activeRides,
                  ),
                  _StatItem(
                    icon: Icons.verified,
                    value: community.isVerified ? '✓' : '—',
                    label: l10n.verified,
                  ),
                ],
              ),
            ),
          ),

          // Description
          if (community.description != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  community.description!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ),

          // Ride board header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.communityRideBoard,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rides list
          if (_rides.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    l10n.noRidesYet,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ride = _rides[index];
                  return _CommunityRideCard(ride: ride, locale: locale);
                },
                childCount: _rides.length,
              ),
            ),

          // Members header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.people, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.members} (${_members.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Members list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = _members[index];
                final profile =
                    member['profiles'] as Map<String, dynamic>? ?? {};
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile['avatar_url'] != null
                        ? CachedNetworkImageProvider(
                            profile['avatar_url'] as String,)
                        : null,
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.2),
                    child: profile['avatar_url'] == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryGreen,
                          )
                        : null,
                  ),
                  title: Text(
                    (profile['full_name'] as String?) ?? 'Member',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    (member['role'] as String?) ?? 'member',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  trailing: profile['average_rating'] != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (profile['average_rating'] as num)
                                  .toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        )
                      : null,
                );
              },
              childCount: _members.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

class _CommunityRideCard extends StatelessWidget {
  final CommunityRide ride;
  final String locale;

  const _CommunityRideCard({required this.ride, required this.locale});

  @override
  Widget build(BuildContext context) {
    final trip = ride.tripData ?? {};
    final poster = ride.posterData ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                if (trip['seats_available'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_seat,
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trip['seats_available']}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
