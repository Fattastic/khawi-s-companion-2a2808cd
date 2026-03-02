import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Screen to create a new regular/recurring route for drivers.
class SetRegularRouteScreen extends ConsumerStatefulWidget {
  const SetRegularRouteScreen({super.key});

  @override
  ConsumerState<SetRegularRouteScreen> createState() =>
      _SetRegularRouteScreenState();
}

class _SetRegularRouteScreenState extends ConsumerState<SetRegularRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fromLocation;
  String? _toLocation;
  TimeOfDay _departureTime = const TimeOfDay(hour: 7, minute: 30);
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Mon-Fri by default
  int _availableSeats = 3;
  bool _kidsAllowed = false;
  bool _womenOnly = false;
  bool _isLoading = false;

  final _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _saveRoute() async {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pickup and drop-off locations'),
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = ref.read(userIdProvider);
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Build schedule JSON for recurring trips
      final scheduleJson = {
        'type': 'weekly',
        'days': _selectedDays.toList()..sort(),
        'time':
            '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
      };

      // Create departure DateTime
      final now = DateTime.now();
      final departureTime = DateTime(
        now.year,
        now.month,
        now.day,
        _departureTime.hour,
        _departureTime.minute,
      );

      // Create the trip draft
      // Note: In production, these would be real coordinates from location picker
      final draft = Trip(
        id: '',
        driverId: uid,
        originLat: 24.7136, // Placeholder - would come from location picker
        originLng: 46.6753,
        destLat: 24.7736,
        destLng: 46.7353,
        originLabel: _fromLocation,
        destLabel: _toLocation,
        polyline: null,
        departureTime: departureTime,
        isRecurring: true,
        scheduleJson: scheduleJson,
        seatsTotal: _availableSeats,
        seatsAvailable: _availableSeats,
        womenOnly: _womenOnly,
        isKidsRide: _kidsAllowed,
        tags: [
          if (_womenOnly) 'women_only',
          if (_kidsAllowed) 'kids_allowed',
          'regular_commute',
        ],
        status: TripStatus.planned,
        neighborhoodId: null,
      );

      await ref.read(tripsRepoProvider).createTrip(draft);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create route: $e')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Regular route created!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.newRegularRouteTitle ?? 'New Regular Route'),
        backgroundColor: AppTheme.backgroundGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Set up your daily commute and get matched with passengers automatically.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // From Location
              Text(
                'From',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _LocationPicker(
                hint: 'Select pickup location',
                value: _fromLocation,
                icon: Icons.my_location,
                onTap: () async {
                  setState(() => _fromLocation = 'Home (Al Olaya District)');
                },
              ),
              const SizedBox(height: 16),

              // To Location
              Text(
                'To',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _LocationPicker(
                hint: 'Select drop-off location',
                value: _toLocation,
                icon: Icons.location_on,
                onTap: () async {
                  setState(() => _toLocation = 'Work (King Fahd Road)');
                },
              ),
              const SizedBox(height: 24),

              // Departure Time
              Text(
                'Departure Time',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _departureTime.format(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Days of Week
              Text(
                'Repeat On',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final isSelected = _selectedDays.contains(i + 1);
                  return FilterChip(
                    label: Text(_dayNames[i]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(i + 1);
                        } else {
                          _selectedDays.remove(i + 1);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Available Seats
              Text(
                'Available Seats',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: _availableSeats > 1
                        ? () => setState(() => _availableSeats--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_availableSeats',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: _availableSeats < 6
                        ? () => setState(() => _availableSeats++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preferences
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Kids Allowed'),
                subtitle: const Text('Allow passengers with children'),
                value: _kidsAllowed,
                onChanged: (v) => setState(() => _kidsAllowed = v),
                // ignore: deprecated_member_use
                activeColor: AppTheme.primaryGreen,
              ),
              SwitchListTile(
                title: const Text('Women Only'),
                subtitle: const Text('Only visible to women passengers'),
                value: _womenOnly,
                onChanged: (v) => setState(() => _womenOnly = v),
                // ignore: deprecated_member_use
                activeColor: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveRoute,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Save Route'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({
    required this.hint,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String hint;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value != null ? AppTheme.primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value != null ? AppTheme.textDark : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
