import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/data/dto/edge/compute_incentives_dto.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/utils/back_guard_mixin.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/services/geocoding_service.dart';
import '../controllers/offer_ride_controller.dart';

class OfferRideWizard extends ConsumerStatefulWidget {
  const OfferRideWizard({super.key});

  @override
  ConsumerState<OfferRideWizard> createState() => _OfferRideWizardState();
}

class _OfferRideWizardState extends ConsumerState<OfferRideWizard>
    with BackGuardMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  bool get hasUnsavedProgress => _currentPage > 0 || _originCtl.text.isNotEmpty;

  final TextEditingController _originCtl = TextEditingController();
  final TextEditingController _destCtl = TextEditingController();
  final TextEditingController _waypointCtl = TextEditingController();
  final TextEditingController _companyCtl = TextEditingController();
  final TextEditingController _campusCtl = TextEditingController();
  final TextEditingController _eventCtl = TextEditingController();

  final GeocodingService _geocodingService = GeocodingService();
  List<GeocodingResult> _originSuggestions = [];
  List<GeocodingResult> _destSuggestions = [];
  List<GeocodingResult> _waypointSuggestions = [];
  Timer? _debounceTimer;
  int _originSearchEpoch = 0;
  int _destSearchEpoch = 0;
  int _waypointSearchEpoch = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _originCtl.dispose();
    _destCtl.dispose();
    _waypointCtl.dispose();
    _companyCtl.dispose();
    _campusCtl.dispose();
    _eventCtl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _searchOrigin(String query, OfferRideController controller) {
    _debounceTimer?.cancel();
    final requestEpoch = ++_originSearchEpoch;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || requestEpoch != _originSearchEpoch) return;
      if (query.length >= 3) {
        final results = await _geocodingService.search(query);
        if (!mounted || requestEpoch != _originSearchEpoch) return;
        setState(() => _originSuggestions = results);
      } else {
        if (!mounted || requestEpoch != _originSearchEpoch) return;
        setState(() => _originSuggestions = []);
      }
    });
  }

  void _searchDest(String query, OfferRideController controller) {
    _debounceTimer?.cancel();
    final requestEpoch = ++_destSearchEpoch;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || requestEpoch != _destSearchEpoch) return;
      if (query.length >= 3) {
        final results = await _geocodingService.search(query);
        if (!mounted || requestEpoch != _destSearchEpoch) return;
        setState(() => _destSuggestions = results);
      } else {
        if (!mounted || requestEpoch != _destSearchEpoch) return;
        setState(() => _destSuggestions = []);
      }
    });
  }

  void _searchWaypoint(String query) {
    _debounceTimer?.cancel();
    final requestEpoch = ++_waypointSearchEpoch;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || requestEpoch != _waypointSearchEpoch) return;
      if (query.length >= 3) {
        final results = await _geocodingService.search(query);
        if (!mounted || requestEpoch != _waypointSearchEpoch) return;
        setState(() => _waypointSuggestions = results);
      } else {
        if (!mounted || requestEpoch != _waypointSearchEpoch) return;
        setState(() => _waypointSuggestions = []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We need driverId, assume authed
    final user = ref.watch(userIdProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not authenticated")));
    }

    final state = ref.watch(offerRideControllerProvider(user));
    final controller = ref.read(offerRideControllerProvider(user).notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offer a Ride'),
          leading: _currentPage > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            _buildStep1Location(state, controller),
            _buildStep2Time(state, controller),
            _buildStep3Prefs(state, controller),
            _buildStep4Review(state, controller),
          ],
        ),
      ), // PopScope
    );
  }

  // Step 1: Locations
  Widget _buildStep1Location(
    OfferRideState state,
    OfferRideController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step 1", style: TextStyle(color: Colors.grey)),
          const Text(
            "Where are you going?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _originCtl,
            decoration: const InputDecoration(
              labelText: 'Origin',
              prefixIcon: Icon(Icons.my_location),
            ),
            onChanged: (val) => _searchOrigin(val, controller),
          ),
          if (_originSuggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _originSuggestions.length,
                itemBuilder: (context, i) {
                  final result = _originSuggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      result.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      controller.setOrigin(
                        result.lat,
                        result.lng,
                        result.label,
                      );
                      _originCtl.text = result.label.split(',').first;
                      setState(() => _originSuggestions = []);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _destCtl,
            decoration: const InputDecoration(
              labelText: 'Destination',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (val) => _searchDest(val, controller),
          ),
          if (_destSuggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _destSuggestions.length,
                itemBuilder: (context, i) {
                  final result = _destSuggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      result.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      controller.setDest(result.lat, result.lng, result.label);
                      _destCtl.text = result.label.split(',').first;
                      setState(() => _destSuggestions = []);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _waypointCtl,
                  decoration: InputDecoration(
                    labelText: 'Add Stop (max 3)',
                    prefixIcon: const Icon(Icons.add_location_alt_outlined),
                    helperText: state.waypoints.isEmpty
                        ? 'Optional intermediate stop'
                        : null,
                  ),
                  onChanged: _searchWaypoint,
                ),
              ),
            ],
          ),
          if (_waypointSuggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _waypointSuggestions.length,
                itemBuilder: (context, i) {
                  final result = _waypointSuggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      result.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: state.waypoints.length >= 3
                        ? null
                        : () {
                            controller.addWaypoint(
                              lat: result.lat,
                              lng: result.lng,
                              label: result.label,
                            );
                            _waypointCtl.clear();
                            setState(() => _waypointSuggestions = []);
                          },
                  );
                },
              ),
            ),
          if (state.waypoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(state.waypoints.length, (index) {
                final stop = state.waypoints[index];
                return InputChip(
                  avatar: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: Text(
                    stop.label.split(',').first,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: () => controller.removeWaypoint(index),
                );
              }),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (state.originLabel != null && state.destLabel != null)
                  ? _nextPage
                  : null,
              child: const Text('Next'),
            ),
          ),
          if ((_incentive?.multiplier ?? 0) > 1.0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_incentive!.multiplier}x XP Bonus Active!",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          _incentive!.areaId.isNotEmpty
                              ? _incentive!.areaId
                              : "High demand area",
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Step 2: Time
  Widget _buildStep2Time(OfferRideState state, OfferRideController controller) {
    final fmt = DateFormat('MMM d, y - h:mm a');
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step 2", style: TextStyle(color: Colors.grey)),
          const Text(
            "When are you leaving?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Departure Time'),
            subtitle: Text(
              state.departureTime != null
                  ? fmt.format(state.departureTime!)
                  : 'Select time',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (d != null && mounted) {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) {
                  final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  controller.setDepartureTime(dt);
                }
              }
            },
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (state.isAnalyzingTime)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 12),
                    Text(
                      "AI is analyzing traffic patterns...",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (state.suggestion != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withAlpha(50),
                    theme.colorScheme.secondaryContainer.withAlpha(50),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "AI Departure Optimizer",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "2x XP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic
                        ? state.suggestion!.reasonAr
                        : state.suggestion!.reasonEn,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.applySuggestion(),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        isArabic
                            ? "تطبيق اقتراح الذكاء الاصطناعي"
                            : "Apply AI Suggestion",
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (state.departureTime != null) ? _nextPage : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Prefs
  Widget _buildStep3Prefs(
    OfferRideState state,
    OfferRideController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step 3", style: TextStyle(color: Colors.grey)),
          const Text(
            "Ride Details",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Seats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Seats', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.setSeats(
                      (state.seats > 1) ? state.seats - 1 : 1,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${state.seats}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.setSeats(
                      (state.seats < 6) ? state.seats + 1 : 6,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          // Women Only
          SwitchListTile(
            title: const Text('Women Only'),
            subtitle: const Text('Only accept female passengers'),
            value: state.womenOnly,
            onChanged: (val) => controller.toggleWomenOnly(val),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Business Ride'),
            subtitle: const Text('Mark this as a company/work commute ride'),
            value: state.isBusinessRide,
            onChanged: (val) => controller.toggleBusinessRide(val),
            contentPadding: EdgeInsets.zero,
          ),
          if (state.isBusinessRide) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _companyCtl,
              decoration: const InputDecoration(
                labelText: 'Company name (optional)',
                prefixIcon: Icon(Icons.business),
              ),
              onChanged: controller.setCompanyName,
            ),
          ],
          const Divider(),
          SwitchListTile(
            title: const Text('Campus Carpool'),
            subtitle:
                const Text('Mark this ride for university/school commute'),
            value: state.isCampusRide,
            onChanged: (val) => controller.toggleCampusRide(val),
            contentPadding: EdgeInsets.zero,
          ),
          if (state.isCampusRide) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _campusCtl,
              decoration: const InputDecoration(
                labelText: 'Campus name (optional)',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              onChanged: controller.setCampusName,
            ),
          ],
          const Divider(),
          SwitchListTile(
            title: const Text('Event / Entertainment Ride'),
            subtitle:
                const Text('Link this ride to a concert, match, or event'),
            value: state.isEventRide,
            onChanged: (val) => controller.toggleEventRide(val),
            contentPadding: EdgeInsets.zero,
          ),
          if (state.isEventRide) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _eventCtl,
              decoration: const InputDecoration(
                labelText: 'Event name (optional)',
                prefixIcon: Icon(Icons.event_outlined),
              ),
              onChanged: controller.setEventLabel,
            ),
          ],
          const Divider(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: SwitchListTile(
              title: const Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Faz\'a (فزعة) Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              subtitle: const Text(
                'Offer this ride for free to help someone out. Earn massive XP and an exclusive badge!',
              ),
              value: state.isFazaRide,
              onChanged: (val) => controller.toggleFazaRide(val),
            ),
          ),
          const SizedBox(height: 16),
          _buildVibeCategory(
            context,
            title: 'Music',
            icon: Icons.music_note,
            options: [
              {'label': 'Arabic', 'key': 'music:arabic'},
              {'label': 'Pop', 'key': 'music:pop'},
              {'label': 'Jazz', 'key': 'music:jazz'},
              {'label': 'No Music', 'key': 'music:none'},
            ],
            state: state,
            controller: controller,
          ),
          const SizedBox(height: 16),
          _buildVibeCategory(
            context,
            title: 'Talkativeness',
            icon: Icons.chat_bubble_outline,
            options: [
              {'label': 'Chatty', 'key': 'vibe:chatty'},
              {'label': 'Silent', 'key': 'vibe:silent'},
              {'label': 'Mixed', 'key': 'vibe:mixed'},
            ],
            state: state,
            controller: controller,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ride Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Quiet'),
                selected: state.ridePreferences.contains('quiet'),
                onSelected: (selected) =>
                    controller.togglePreference('quiet', selected),
              ),
              FilterChip(
                label: const Text('No smoking'),
                selected: state.ridePreferences.contains('no_smoking'),
                onSelected: (selected) =>
                    controller.togglePreference('no_smoking', selected),
              ),
              FilterChip(
                label: const Text('Cold AC'),
                selected: state.ridePreferences.contains('cold_ac'),
                onSelected: (selected) =>
                    controller.togglePreference('cold_ac', selected),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, String>> options,
    required OfferRideState state,
    required OfferRideController controller,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final key = opt['key']!;
            final label = opt['label']!;
            return FilterChip(
              label: Text(label),
              selected: state.ridePreferences.contains(key),
              onSelected: (selected) =>
                  controller.togglePreference(key, selected),
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 4: Review
  Widget _buildStep4Review(
    OfferRideState state,
    OfferRideController controller,
  ) {
    final fmt = DateFormat('MMM d, h:mm a');

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Summary", style: TextStyle(color: Colors.grey)),
          const Text(
            "Confirm your ride",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow(Icons.my_location, 'From', state.originLabel ?? '-'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.location_on, 'To', state.destLabel ?? '-'),
          const SizedBox(height: 16),
          _buildSummaryRow(
            Icons.access_time,
            'Leaving',
            state.departureTime != null
                ? fmt.format(state.departureTime!)
                : '-',
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            Icons.event_seat,
            'Seats',
            '${state.seats} passengers',
          ),
          if (state.ridePreferences.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.tune,
              'Preferences',
              state.ridePreferences.map((p) {
                switch (p) {
                  case 'quiet':
                    return 'Quiet';
                  case 'no_smoking':
                    return 'No smoking';
                  case 'cold_ac':
                    return 'Cold AC';
                  default:
                    return p;
                }
              }).join(', '),
            ),
          ],
          if (state.waypoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...state.waypoints.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSummaryRow(
                      Icons.stop,
                      'Stop ${entry.key + 1}',
                      entry.value.label,
                    ),
                  ),
                ),
          ],
          if (state.womenOnly) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(Icons.female, 'Women Only', 'Yes'),
          ],
          if (state.isBusinessRide) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.business,
              'Business Ride',
              state.companyName ?? 'Company commute',
            ),
          ],
          if (state.isCampusRide) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.school_outlined,
              'Campus Carpool',
              state.campusName ?? 'University / school commute',
            ),
          ],
          if (state.isEventRide) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.event_outlined,
              'Event Ride',
              state.eventLabel ?? 'Event / entertainment commute',
            ),
          ],
          if (state.isFazaRide) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.volunteer_activism,
              'Faz\'a (فزعة) Ride',
              'Free ride for massive XP & badge',
            ),
          ],
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await controller.submit();
                  if (mounted) {
                    // Navigate back to home/explore after success
                    context.go(Routes.driverExploreMap);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ride created successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create ride: $e'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  ComputeIncentivesResponse? _incentive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIncentives();
    });
  }

  Future<void> _checkIncentives() async {
    final repo = ref.read(tripsRepoProvider);
    // Hardcoded Riyadh for demo, ideally use current location
    try {
      final res = await repo.fetchDriverIncentives(lat: 24.7136, lng: 46.6753);
      if (mounted) {
        setState(() => _incentive = res);
      }
    } catch (e) {
      debugPrint('Error fetching incentives: $e');
    }
  }
}
