import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../rating/domain/ride_rating.dart';
import '../../../rating/domain/rating_flow_prefs.dart';
import '../../../../state/providers.dart';

class RatingDialog extends StatefulWidget {
  final String tripId;
  final String rateeId;
  final String rateeName;
  final String? originLabel;
  final String? destinationLabel;
  final List<String> waypointLabels;
  final bool isRatingDriver;

  const RatingDialog({
    super.key,
    required this.tripId,
    required this.rateeId,
    required this.rateeName,
    this.originLabel,
    this.destinationLabel,
    this.waypointLabels = const [],
    this.isRatingDriver = true,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _stars = 5;
  final Set<RatingTag> _selectedTags = <RatingTag>{};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  List<RatingTag> get _availableTags => defaultRatingTags(
        widget.isRatingDriver
            ? RatingDirection.rateDriver
            : RatingDirection.ratePassenger,
      );

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = isRtl ? 'ar' : 'en';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isRtl ? 'تقييم الرحلة' : 'Rate your trip',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isRtl
                  ? 'كيف كانت تجربتك مع ${widget.rateeName}؟'
                  : 'How was your trip with ${widget.rateeName}?',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            if (widget.originLabel != null ||
                widget.destinationLabel != null ||
                widget.waypointLabels.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? 'ملخص المسار' : 'Route Summary',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreenDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (widget.originLabel != null)
                      _routeRow(
                        isRtl ? 'من' : 'From',
                        widget.originLabel!,
                      ),
                    if (widget.destinationLabel != null)
                      _routeRow(
                        isRtl ? 'إلى' : 'To',
                        widget.destinationLabel!,
                      ),
                    if (widget.waypointLabels.isNotEmpty)
                      _routeRow(
                        isRtl ? 'التوقفات' : 'Stops',
                        widget.waypointLabels.join(' • '),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _stars = index + 1),
                  icon: Icon(
                    index < _stars ? Icons.star : Icons.star_border,
                    color: AppTheme.accentGold,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag.label(locale)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isRtl
                    ? 'أضف تعليقاً (اختياري)...'
                    : 'Add a comment (optional)...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isRtl ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isRtl ? 'إرسال' : 'Submit'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final commentText = _commentController.text.trim();
    try {
      await container.read(tripsRepoProvider).submitRating(
            tripId: widget.tripId,
            rateeId: widget.rateeId,
            stars: _stars,
            tags: _selectedTags.map((t) => t.key).toList(growable: false),
            comment: commentText,
          );
      unawaited(
        container.read(eventLogProvider).logRatingSubmitted(
              tripId: widget.tripId,
              rateeId: widget.rateeId,
              stars: _stars,
              tagCount: _selectedTags.length,
              hasComment: commentText.isNotEmpty,
              source: 'rating_dialog',
            ),
      );
      // Fire gamification safety mission progress (fire-and-forget)
      unawaited(
        container.read(gamificationHookProvider).onRatingSubmitted(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      unawaited(
        container.read(eventLogProvider).logRatingSubmissionFailed(
              tripId: widget.tripId,
              rateeId: widget.rateeId,
              source: 'rating_dialog',
              error: e.toString(),
            ),
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _routeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showRatingDialog(
  BuildContext context, {
  required String tripId,
  required String rateeId,
  required String rateeName,
  String? originLabel,
  String? destinationLabel,
  List<String> waypointLabels = const [],
  bool isRatingDriver = true,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => RatingDialog(
      tripId: tripId,
      rateeId: rateeId,
      rateeName: rateeName,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      waypointLabels: waypointLabels,
      isRatingDriver: isRatingDriver,
    ),
  );
}
