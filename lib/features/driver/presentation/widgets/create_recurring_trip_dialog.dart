import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/state/providers.dart';

class CreateRecurringTripDialog extends ConsumerStatefulWidget {
  final String driverId;

  const CreateRecurringTripDialog({super.key, required this.driverId});

  @override
  ConsumerState<CreateRecurringTripDialog> createState() =>
      _CreateRecurringTripDialogState();
}

class _CreateRecurringTripDialogState
    extends ConsumerState<CreateRecurringTripDialog> {
  final _originLabel = TextEditingController();
  final _destLabel = TextEditingController();
  final _pickupLat = TextEditingController(text: '24.7136');
  final _pickupLng = TextEditingController(text: '46.6753');
  final _dropLat = TextEditingController(text: '24.7743');
  final _dropLng = TextEditingController(text: '46.7386');
  final _timeCtl = TextEditingController(text: '07:30');
  final _days = <int>{1, 2, 3, 4, 5};
  bool _isLoading = false;

  @override
  void dispose() {
    _originLabel.dispose();
    _destLabel.dispose();
    _pickupLat.dispose();
    _pickupLng.dispose();
    _dropLat.dispose();
    _dropLng.dispose();
    _timeCtl.dispose();
    super.dispose();
  }

  static String _weekdayName(int d) {
    return switch (d) {
      1 => 'Mon',
      2 => 'Tue',
      3 => 'Wed',
      4 => 'Thu',
      5 => 'Fri',
      6 => 'Sat',
      7 => 'Sun',
      _ => 'Day',
    };
  }

  Future<void> _create() async {
    if (_isLoading) return;

    final oLat = double.tryParse(_pickupLat.text.trim());
    final oLng = double.tryParse(_pickupLng.text.trim());
    final dLat = double.tryParse(_dropLat.text.trim());
    final dLng = double.tryParse(_dropLng.text.trim());

    if (oLat == null || oLng == null || dLat == null || dLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coordinates')),
        );
      }
      return;
    }

    if (_days.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one day')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      // Use dummy date for time, actual schedule logic handles recurrence
      final departureTime = DateTime(now.year, now.month, now.day, 7, 30);

      final scheduleJson = {
        'type': 'weekly',
        'days': _days.toList()..sort(),
        'time': _timeCtl.text.trim(),
      };

      final draft = Trip(
        id: '',
        driverId: widget.driverId,
        originLat: oLat,
        originLng: oLng,
        destLat: dLat,
        destLng: dLng,
        originLabel:
            _originLabel.text.trim().isEmpty ? null : _originLabel.text.trim(),
        destLabel:
            _destLabel.text.trim().isEmpty ? null : _destLabel.text.trim(),
        polyline: null,
        departureTime: departureTime,
        isRecurring: true,
        scheduleJson: scheduleJson,
        seatsTotal: 1,
        seatsAvailable: 1,
        womenOnly: false,
        isKidsRide: false,
        tags: const [],
        status: TripStatus.planned,
        neighborhoodId: null,
      );

      await ref.read(tripsRepoProvider).createTrip(draft);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error creating trip: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New regular trip'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _originLabel,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Origin label'),
            ),
            TextField(
              controller: _destLabel,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Destination label'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pickupLat,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(labelText: 'Origin lat'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pickupLng,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(labelText: 'Origin lng'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dropLat,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(labelText: 'Dest lat'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dropLng,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(labelText: 'Dest lng'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeCtl,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Days',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (final d in [1, 2, 3, 4, 5, 6, 7])
                  FilterChip(
                    selected: _days.contains(d),
                    label: Text(_weekdayName(d)),
                    onSelected: _isLoading
                        ? null
                        : (v) {
                            setState(() {
                              if (v) {
                                _days.add(d);
                              } else {
                                _days.remove(d);
                              }
                            });
                          },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _create,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
