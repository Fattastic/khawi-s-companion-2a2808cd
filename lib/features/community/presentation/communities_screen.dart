import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/community/domain/community.dart';

/// Main screen listing user's communities and discover tab.
class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _pendingCommunityIds = {};
  Timer? _searchDebounce;
  int _searchEpoch = 0;
  List<CommunityMembership> _myCommunities = [];
  List<Community> _discover = [];
  bool _loading = true;
  bool _isSearching = false;

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
      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _myCommunities = const [];
          _discover = const [];
          _loading = false;
        });
        return;
      }

      final repo = ref.read(communityRepoProvider);
      final results = await Future.wait([
        repo.fetchMyCommunities(userId),
        repo.fetchAll(),
      ]);

      if (!mounted) return;
      setState(() {
        _myCommunities = results[0] as List<CommunityMembership>;
        _discover = results[1] as List<Community>;
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

  Future<void> _searchCommunities(String query, int requestEpoch) async {
    final repo = ref.read(communityRepoProvider);
    if (!mounted || requestEpoch != _searchEpoch) return;
    final results = await repo.search(query);
    if (!mounted || requestEpoch != _searchEpoch) return;
    setState(() {
      _discover = results;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchEpoch++;
      setState(() => _isSearching = false);
      unawaited(_loadData());
      return;
    }
    final requestEpoch = ++_searchEpoch;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted || requestEpoch != _searchEpoch) return;
      setState(() => _isSearching = true);
      try {
        await _searchCommunities(trimmed, requestEpoch);
      } finally {
        if (mounted && requestEpoch == _searchEpoch) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _joinCommunity(Community community) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;
    if (_pendingCommunityIds.contains(community.id)) return;

    setState(() => _pendingCommunityIds.add(community.id));

    final repo = ref.read(communityRepoProvider);
    try {
      await repo.join(community.id, userId);
      unawaited(_loadData());
    } finally {
      if (mounted) {
        setState(() => _pendingCommunityIds.remove(community.id));
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${community.name}! 🎉'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Future<void> _leaveCommunity(String communityId) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;
    if (_pendingCommunityIds.contains(communityId)) return;

    setState(() => _pendingCommunityIds.add(communityId));

    final repo = ref.read(communityRepoProvider);
    try {
      await repo.leave(communityId, userId);
      unawaited(_loadData());
    } finally {
      if (mounted) {
        setState(() => _pendingCommunityIds.remove(communityId));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = isRtl ? 'ar' : 'en';

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(l10n.communities),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.myCommunities),
            Tab(text: l10n.discoverCommunities),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyCommunities(locale, l10n),
                _buildDiscover(locale, l10n),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.communityCreate),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyCommunities(String locale, AppLocalizations l10n) {
    if (_myCommunities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.groups_outlined,
                size: 80,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noCommunities,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.joinCommunityHint,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.explore),
                label: Text(l10n.discoverCommunities),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        itemCount: _myCommunities.length,
        itemBuilder: (context, index) {
          final membership = _myCommunities[index];
          final community = membership.community;
          if (community == null) return const SizedBox.shrink();

          return KhawiMotion.fadeInSlideUp(
            _CommunityCard(
              community: community,
              locale: locale,
              isMember: true,
              isBusy: _pendingCommunityIds.contains(community.id),
              onTap: () =>
                  context.push(Routes.communityDetailPath(community.id)),
              onAction: () => _leaveCommunity(community.id),
            ),
            duration: Duration(
              milliseconds: 260 + (index.clamp(0, 7) * 35),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscover(String locale, AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: l10n.searchCommunities,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        );
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        // Type filter chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: CommunityType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type.label(locale)),
                  selected: false,
                  onSelected: (_) async {
                    final repo = ref.read(communityRepoProvider);
                    final results = await repo.fetchByType(type);
                    if (!mounted) return;
                    setState(() => _discover = results);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _discover.length,
              itemBuilder: (context, index) {
                final community = _discover[index];
                final alreadyJoined =
                    _myCommunities.any((m) => m.communityId == community.id);

                return KhawiMotion.fadeInSlideUp(
                  _CommunityCard(
                    community: community,
                    locale: locale,
                    isMember: alreadyJoined,
                    isBusy: _pendingCommunityIds.contains(community.id),
                    onTap: () =>
                        context.push(Routes.communityDetailPath(community.id)),
                    onAction:
                        alreadyJoined ? null : () => _joinCommunity(community),
                  ),
                  duration: Duration(
                    milliseconds: 260 + (index.clamp(0, 7) * 35),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Card widget for a community.
class _CommunityCard extends StatelessWidget {
  final Community community;
  final String locale;
  final bool isMember;
  final bool isBusy;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _CommunityCard({
    required this.community,
    required this.locale,
    required this.isMember,
    required this.isBusy,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: () {
          if (onTap == null) return;
          KhawiMotion.hapticLight();
          onTap!();
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Community icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: community.iconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          community.iconUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          community.typeEmoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            community.displayName(locale),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (community.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppTheme.primaryGreen,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${community.memberCount}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          community.type.label(locale),
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (community.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        community.description!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action button
              if (onAction != null)
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () {
                          KhawiMotion.hapticSelection();
                          onAction?.call();
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: isMember
                        ? Colors.grey[200]
                        : AppTheme.primaryGreen.withValues(alpha: 0.1),
                    foregroundColor:
                        isMember ? Colors.grey[700] : AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isMember ? 'Leave' : 'Join'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
