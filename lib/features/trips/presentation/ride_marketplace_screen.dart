import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/features/trips/domain/accessibility_mode.dart';
import 'package:khawi_flutter/features/trips/domain/marketplace_visible_trips.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/profile/presentation/trust_badge.dart';
import 'controllers/ride_marketplace_controller.dart';

const _kBookingAccessibilityNeedsKey = 'khawi_booking_accessibility_needs';

class RideMarketplaceScreen extends ConsumerStatefulWidget {
  const RideMarketplaceScreen({super.key});

  @override
  ConsumerState<RideMarketplaceScreen> createState() =>
      _RideMarketplaceScreenState();
}

class _RideMarketplaceScreenState extends ConsumerState<RideMarketplaceScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  bool _womenOnly = false;
  bool _businessOnly = false;
  bool _campusOnly = false;
  bool _eventOnly = false;
  DateTime? _scheduledDeparture;
  final Set<String> _selectedPreferences = <String>{};
  Set<String> _favoriteDriverIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final userId = ref.read(userIdProvider);
    final ids =
        await ref.read(favoriteDriversProvider).getFavorites(userId: userId);
    if (!mounted) return;
    setState(() => _favoriteDriverIds = ids);
  }

  Future<void> _toggleFavorite(String driverId) async {
    final userId = ref.read(userIdProvider);
    final added = await ref
        .read(favoriteDriversProvider)
        .toggleFavorite(driverId, userId: userId);
    if (!mounted) return;
    setState(() {
      if (added) {
        _favoriteDriverIds.add(driverId);
      } else {
        _favoriteDriverIds.remove(driverId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideMarketplaceControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.findRide,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          _buildSearchHeader(context, theme, state),
          Expanded(
            child: _buildResultsList(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(
    BuildContext context,
    ThemeData theme,
    RideMarketplaceState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(premiumProvider);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final scheduleLabel = _scheduledDeparture == null
        ? l10n.rideNow
        : DateFormat.yMMMd(localeName).add_jm().format(_scheduledDeparture!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAddressField(
                theme: theme,
                controller: _fromController,
                hint: l10n.pickup,
                icon: Icons.my_location,
                iconColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _buildAddressField(
                theme: theme,
                controller: _toController,
                hint: l10n.destination,
                icon: Icons.location_on,
                iconColor: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _txt(
                            context,
                            en: 'Khawi+ Priority Matching',
                            ar: 'أولوية المطابقة (خاوي+)',
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    FilterChip(
                      label: Text(l10n.womenOnly),
                      selected: _womenOnly,
                      onSelected: (val) => setState(() => _womenOnly = val),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    FilterChip(
                      label: Text(
                        _txt(
                          context,
                          en: 'Business rides',
                          ar: 'رحلات أعمال',
                        ),
                      ),
                      selected: _businessOnly,
                      onSelected: (val) => setState(() => _businessOnly = val),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    FilterChip(
                      label: Text(
                        _txt(
                          context,
                          en: 'Campus carpools',
                          ar: 'كاربول الجامعات',
                        ),
                      ),
                      selected: _campusOnly,
                      onSelected: (val) => setState(() => _campusOnly = val),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    FilterChip(
                      label: Text(
                        _txt(
                          context,
                          en: 'Event rides',
                          ar: 'رحلات الفعاليات',
                        ),
                      ),
                      selected: _eventOnly,
                      onSelected: (val) => setState(() => _eventOnly = val),
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text(scheduleLabel),
                      onPressed: () => _pickScheduledDeparture(),
                    ),
                    if (_scheduledDeparture != null)
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 18),
                        label: Text(_txt(context, en: 'Clear', ar: 'مسح')),
                        onPressed: () =>
                            setState(() => _scheduledDeparture = null),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Quiet', ar: 'هادئ'),
                      'quiet',
                    ),
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'No smoking', ar: 'بدون تدخين'),
                      'no_smoking',
                    ),
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Cold AC', ar: 'مكيّف بارد'),
                      'cold_ac',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Vibe Check',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Chatty', ar: 'ثرثار'),
                      'vibe:chatty',
                    ),
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Silent', ar: 'هادئ جداً'),
                      'vibe:silent',
                    ),
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Arabic Music', ar: 'موسيقى عربية'),
                      'music:arabic',
                    ),
                    _prefChip(
                      context,
                      theme,
                      _txt(context, en: 'Pop Music', ar: 'موسيقى بوب'),
                      'music:pop',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(rideMarketplaceControllerProvider.notifier)
                        .quickSearch(
                          originLat: 24.7136,
                          originLng: 46.6753,
                          destLat: 24.7743,
                          destLng: 46.7386,
                          womenOnly: _womenOnly,
                          desiredDeparture: _scheduledDeparture,
                          passengerPreferences: _selectedPreferences.toList(),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          l10n.searchForARide,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _txt(BuildContext context, {required String en, required String ar}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? ar : en;
  }

  Widget _buildAddressField({
    required ThemeData theme,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultsList(RideMarketplaceState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTrips = buildVisibleMarketplaceTrips(
      trips: state.trips,
      businessOnly: _businessOnly,
      campusOnly: _campusOnly,
      eventOnly: _eventOnly,
      selectedPreferences: _selectedPreferences,
      favoriteDriverIds: _favoriteDriverIds,
    );

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 72,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              state.trips.isEmpty
                  ? _txt(
                      context,
                      en: 'No rides found yet.',
                      ar: 'ما فيه مشاوير متاحة حالياً.',
                    )
                  : _txt(
                      context,
                      en: 'No rides match selected preferences.',
                      ar: 'ما فيه مشاوير تطابق التفضيلات المختارة.',
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _txt(
                context,
                en: '${filteredTrips.length} rides found',
                ar: 'تم العثور على ${filteredTrips.length} رحلة',
              ),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredTrips.length,
            itemBuilder: (context, index) {
              final trip = filteredTrips[index];
              return _TripCard(
                trip: trip,
                isFavorite: _favoriteDriverIds.contains(trip.driverId),
                onToggleFavorite: () => _toggleFavorite(trip.driverId),
                onTap: () => _showBookingSheet(trip),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBookingSheet(Trip trip) {
    const double currentLat = 24.7136;
    const double currentLng = 46.6753;
    final String label = _fromController.text.isNotEmpty
        ? _fromController.text
        : _txt(context, en: 'Current location', ar: 'موقعك الحالي');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _BookingSheet(
        trip: trip,
        pickupLat: currentLat,
        pickupLng: currentLng,
        pickupLabel: label,
      ),
    );
  }

  Future<void> _pickScheduledDeparture() async {
    final now = DateTime.now();
    final initial = _scheduledDeparture ?? now.add(const Duration(hours: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    final scheduled = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (scheduled.isBefore(now)) return;

    setState(() => _scheduledDeparture = scheduled);
  }

  Widget _prefChip(
    BuildContext context,
    ThemeData theme,
    String label,
    String key,
  ) {
    final selected = _selectedPreferences.contains(key);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setState(() {
          if (value) {
            _selectedPreferences.add(key);
          } else {
            _selectedPreferences.remove(key);
          }
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}

class _BookingSheet extends ConsumerStatefulWidget {
  final Trip trip;
  final double pickupLat;
  final double pickupLng;
  final String pickupLabel;

  const _BookingSheet({
    required this.trip,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupLabel,
  });

  @override
  ConsumerState<_BookingSheet> createState() => _BookingSheetState();
}

class BookingPickupOption {
  const BookingPickupOption({
    required this.label,
    required this.lat,
    required this.lng,
    this.isWaypoint = false,
  });

  final String label;
  final double lat;
  final double lng;
  final bool isWaypoint;
}

List<BookingPickupOption> buildBookingPickupOptions({
  required Trip trip,
  required double defaultPickupLat,
  required double defaultPickupLng,
  required String defaultPickupLabel,
}) {
  final options = <BookingPickupOption>[
    BookingPickupOption(
      label: defaultPickupLabel,
      lat: defaultPickupLat,
      lng: defaultPickupLng,
    ),
  ];

  for (final stop in trip.waypoints) {
    final alreadyIncluded = options.any(
      (option) =>
          option.label == stop.label ||
          (option.lat == stop.lat && option.lng == stop.lng),
    );
    if (alreadyIncluded) continue;
    options.add(
      BookingPickupOption(
        label: stop.label,
        lat: stop.lat,
        lng: stop.lng,
        isWaypoint: true,
      ),
    );
  }

  return options;
}

class _BookingSheetState extends ConsumerState<_BookingSheet> {
  bool _useFlexOffer = false;
  bool _isSubmitting = false;
  final TextEditingController _flexOfferController = TextEditingController();
  final TextEditingController _flexNoteController = TextEditingController();
  late final List<BookingPickupOption> _pickupOptions;
  late BookingPickupOption _selectedPickup;
  Set<AccessibilityNeed> _accessibilityNeeds = <AccessibilityNeed>{};
  bool _requestQuickStop = false;

  @override
  void initState() {
    super.initState();
    _pickupOptions = buildBookingPickupOptions(
      trip: widget.trip,
      defaultPickupLat: widget.pickupLat,
      defaultPickupLng: widget.pickupLng,
      defaultPickupLabel: widget.pickupLabel,
    );
    _selectedPickup = _pickupOptions.first;
  }

  @override
  void dispose() {
    _flexOfferController.dispose();
    _flexNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _txt(context, en: 'Confirm booking', ar: 'تأكيد الحجز'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.my_location,
            l10n.pickup,
            _selectedPickup.label,
          ),
          if (_pickupOptions.length > 1) ...[
            const SizedBox(height: 8),
            InputDecorator(
              decoration: InputDecoration(
                labelText: _txt(
                  context,
                  en: 'Pickup point',
                  ar: 'نقطة الالتقاط',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BookingPickupOption>(
                  value: _selectedPickup,
                  isExpanded: true,
                  items: _pickupOptions
                      .map(
                        (option) => DropdownMenuItem<BookingPickupOption>(
                          value: option,
                          child: Text(
                            option.isWaypoint
                                ? '${option.label} • ${_txt(context, en: 'Stop', ar: 'توقف')}'
                                : option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedPickup = value);
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.location_on,
            l10n.destination,
            widget.trip.destLabel ?? l10n.destination,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.schedule,
            _txt(context, en: 'Departure', ar: 'موعد الانطلاق'),
            DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
                .add_jm()
                .format(widget.trip.departureTime),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.event_seat,
            _txt(context, en: 'Seats left', ar: 'المقاعد المتبقية'),
            '${widget.trip.seatsAvailable}/${widget.trip.seatsTotal}',
          ),
          const SizedBox(height: 14),
          Text(
            _txt(
              context,
              en: 'Accessibility mode',
              ar: 'وضع سهولة الوصول',
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _txt(
              context,
              en: 'Select any support needed so the driver is prepared before pickup.',
              ar: 'حدد أي دعم تحتاجه ليكون السائق مستعداً قبل الالتقاط.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _AccessibilityNeedsSection(
            isArabic: isArabic,
            onChanged: (needs) {
              _accessibilityNeeds = needs;
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _requestQuickStop,
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.local_cafe_outlined),
            title: Text(
              _txt(
                context,
                en: 'Quick Stop (Coffee/Drive-thru)',
                ar: 'توقف سريع (قهوة / مرور سريع)',
              ),
            ),
            subtitle: Text(
              _txt(
                context,
                en: 'Suggest a brief stop without changing the route.',
                ar: 'اقتراح توقف قصير دون تغيير المسار.',
              ),
              style: theme.textTheme.bodySmall,
            ),
            onChanged: (value) => setState(() => _requestQuickStop = value),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _useFlexOffer,
            contentPadding: EdgeInsets.zero,
            title: Text(
              _txt(
                context,
                en: 'Khawi Flex (optional negotiation)',
                ar: 'خاوي فليكس (تفاوض اختياري)',
              ),
            ),
            subtitle: Text(
              _txt(
                context,
                en: 'No payment is processed in-app. This is just a suggested contribution signal.',
                ar: 'لا يوجد دفع داخل التطبيق. هذا فقط اقتراح مساهمة يراه السائق.',
              ),
              style: theme.textTheme.bodySmall,
            ),
            onChanged: (value) => setState(() => _useFlexOffer = value),
          ),
          if (_useFlexOffer) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _flexOfferController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _txt(
                  context,
                  en: 'Suggested contribution (SAR)',
                  ar: 'المساهمة المقترحة (ريال)',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _flexNoteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: _txt(
                  context,
                  en: 'Note to driver (optional)',
                  ar: 'ملاحظة للسائق (اختياري)',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _BookingActionSection(
            projectedXpLabel: l10n.projectedXp,
            xpLabel: '${45} ${l10n.xp}',
            confirmLabel: _txt(
              context,
              en: 'Confirm ride request',
              ar: 'تأكيد طلب الرحلة',
            ),
            isSubmitting: _isSubmitting,
            onSubmit: () => _submitBooking(isArabic),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _submitBooking(bool isArabic) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(requestsRepoProvider);
      final flexOfferSar = _useFlexOffer
          ? double.tryParse(_flexOfferController.text.trim())
          : null;
      final flexNote = _useFlexOffer ? _flexNoteController.text.trim() : null;
      final accessibilityNote = buildAccessibilityRequestNote(
        needs: _accessibilityNeeds,
        isArabic: isArabic,
      );
      final quickStopNote = _requestQuickStop
          ? (isArabic
              ? 'طلب توقف سريع (قهوة / مرور سريع) ☕'
              : 'Requested Quick Stop (Coffee/Drive-thru) ☕')
          : null;

      final intermediateNote = mergeRequestNotes(
        primaryNote: flexNote,
        secondaryNote: quickStopNote,
      );
      final mergedNote = mergeRequestNotes(
        primaryNote: intermediateNote,
        secondaryNote: accessibilityNote,
      );

      await repo.sendJoinRequest(
        widget.trip.id,
        pickupLat: _selectedPickup.lat,
        pickupLng: _selectedPickup.lng,
        pickupLabel: _selectedPickup.label,
        flexOfferSar: flexOfferSar,
        flexNote: mergedNote,
      );

      KhawiMotion.hapticSuccess();

      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.pop(context);
      unawaited(
        router.push(Routes.passengerBooking, extra: widget.trip.id),
      );
    } catch (_) {
      KhawiMotion.hapticMedium();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _txt(
              context,
              en: 'Unable to submit request. Please try again.',
              ar: 'تعذر إرسال الطلب. حاول مرة أخرى.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _txt(BuildContext context, {required String en, required String ar}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? ar : en;
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccessibilityNeedsSection extends StatefulWidget {
  final bool isArabic;
  final ValueChanged<Set<AccessibilityNeed>> onChanged;

  const _AccessibilityNeedsSection({
    required this.isArabic,
    required this.onChanged,
  });

  @override
  State<_AccessibilityNeedsSection> createState() =>
      _AccessibilityNeedsSectionState();
}

class _AccessibilityNeedsSectionState
    extends State<_AccessibilityNeedsSection> {
  Set<AccessibilityNeed> _needs = <AccessibilityNeed>{};

  @override
  void initState() {
    super.initState();
    unawaited(_loadNeeds());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AccessibilityNeed.values
          .map(
            (need) => FilterChip(
              avatar: Icon(
                _accessibilityIcon(need),
                size: 16,
              ),
              label: Text(need.label(isArabic: widget.isArabic)),
              selected: _needs.contains(need),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _needs.add(need);
                  } else {
                    _needs.remove(need);
                  }
                });
                widget.onChanged(Set<AccessibilityNeed>.from(_needs));
                unawaited(_saveNeeds());
              },
            ),
          )
          .toList(growable: false),
    );
  }

  IconData _accessibilityIcon(AccessibilityNeed need) => switch (need) {
        AccessibilityNeed.wheelchair => Icons.accessible,
        AccessibilityNeed.seniorFriendly => Icons.elderly,
        AccessibilityNeed.assistiveSupport => Icons.accessibility_new,
        AccessibilityNeed.visionSupport => Icons.visibility,
      };

  Future<void> _loadNeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getStringList(_kBookingAccessibilityNeedsKey) ?? const <String>[];
    final loaded = parseAccessibilityNeeds(keys);
    if (!mounted) return;
    setState(() => _needs = loaded);
    widget.onChanged(Set<AccessibilityNeed>.from(_needs));
  }

  Future<void> _saveNeeds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kBookingAccessibilityNeedsKey,
      accessibilityNeedKeys(_needs),
    );
  }
}

class _BookingActionSection extends StatelessWidget {
  final String projectedXpLabel;
  final String xpLabel;
  final String confirmLabel;
  final bool isSubmitting;
  final Future<void> Function() onSubmit;

  const _BookingActionSection({
    required this.projectedXpLabel,
    required this.xpLabel,
    required this.confirmLabel,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              projectedXpLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              xpLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    confirmLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  String _txt(BuildContext context, {required String en, required String ar}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? ar : en;
  }

  String _driverLabel(BuildContext context, String driverId) {
    final s = driverId.trim();
    if (s.isEmpty) return _txt(context, en: 'Driver', ar: 'السائق');
    final short = s.length <= 6 ? s : s.substring(0, 6);
    return '${_txt(context, en: 'Driver', ar: 'السائق')} $short';
  }

  String _departureLabel(BuildContext context) {
    final mins = trip.departureTime.difference(DateTime.now()).inMinutes;
    if (mins <= 0) return _txt(context, en: 'Departing now', ar: 'انطلاق الآن');
    if (mins < 60) {
      return _txt(context, en: 'Departs in ${mins}m', ar: 'ينطلق بعد $mins د');
    }
    final hours = mins ~/ 60;
    final rem = mins % 60;
    if (rem == 0) {
      return _txt(
        context,
        en: 'Departs in ${hours}h',
        ar: 'ينطلق بعد $hours س',
      );
    }
    return _txt(
      context,
      en: 'Departs in ${hours}h ${rem}m',
      ar: 'ينطلق بعد $hours س $rem د',
    );
  }

  String _etaLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eta = trip.etaMinutes;
    if (eta == null || eta <= 0) {
      return _txt(context, en: 'ETA pending', ar: 'الوقت المتوقع قريبًا');
    }
    return '${l10n.eta} ${eta}m';
  }

  String? _companyTag() {
    for (final tag in trip.tags) {
      if (tag.startsWith('company:')) {
        final value = tag.substring('company:'.length).replaceAll('_', ' ');
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  String? _campusTag() {
    for (final tag in trip.tags) {
      if (tag.startsWith('campus:')) {
        final value = tag.substring('campus:'.length).replaceAll('_', ' ');
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  String? _eventTag() {
    for (final tag in trip.tags) {
      if (tag.startsWith('event:')) {
        final value = tag.substring('event:'.length).replaceAll('_', ' ');
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _driverLabel(context, trip.driverId),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (trip.driverTrustBadge != null) ...[
                              const SizedBox(width: 4),
                              TrustBadge(
                                score: trip.driverTrustScore ?? 50,
                                badge: trip.driverTrustBadge!,
                                isJuniorTrusted:
                                    trip.driverJuniorTrusted ?? false,
                              ),
                            ],
                          ],
                        ),
                        if (trip.matchScore != null)
                          Text(
                            '${_txt(context, en: 'Match score', ar: 'درجة التطابق')}: ${trip.matchScore}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: isFavorite
                        ? _txt(
                            context,
                            en: 'Remove favorite driver',
                            ar: 'إزالة من المفضلة',
                          )
                        : _txt(
                            context,
                            en: 'Favorite driver',
                            ar: 'إضافة للمفضلة',
                          ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _txt(context, en: 'Community ride', ar: 'رحلة مجتمعية'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _txt(context, en: 'Earn XP', ar: 'اكسب XP'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (trip.isKidsRide)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _txt(context, en: 'KIDS', ar: 'أطفال'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      if (trip.tags.contains('business_ride'))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _txt(context, en: 'BUSINESS', ar: 'أعمال'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      if (trip.tags.contains('campus_ride'))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _txt(context, en: 'CAMPUS', ar: 'جامعي'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      if (trip.tags.contains('event_ride'))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _txt(context, en: 'EVENT', ar: 'فعالية'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      if (trip.tags.contains('faza'))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade200,
                                Colors.orange.shade300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volunteer_activism,
                                size: 10,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _txt(context, en: 'FAZ\'A', ar: 'فزعة'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (_companyTag() != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _companyTag()!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_campusTag() != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _campusTag()!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_eventTag() != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _eventTag()!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.originLabel ?? l10n.pickup,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.destLabel ?? l10n.destination,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (trip.matchTags?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: trip.matchTags!
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _departureLabel(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _etaLabel(context),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
