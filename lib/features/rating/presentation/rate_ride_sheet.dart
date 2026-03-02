import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/ride_rating.dart';
import '../../../services/store_rating_service.dart';

/// Bottom sheet dialog for rating a ride after completion.
///
/// Shows 5-star selector, quick-select tags, and optional comment field.
/// Returns the rating data when submitted, null if dismissed.
class RateRideSheet extends StatefulWidget {
  /// Name of the person being rated (driver name for passengers, passenger name for drivers).
  final String counterpartName;

  /// Whether the current user is rating as a passenger (rates driver) or driver (rates passenger).
  final bool isRatingDriver;

  const RateRideSheet({
    super.key,
    required this.counterpartName,
    this.isRatingDriver = true,
  });

  /// Show the rating bottom sheet and return rating data if submitted.
  static Future<RateRideResult?> show(
    BuildContext context, {
    required String counterpartName,
    bool isRatingDriver = true,
  }) {
    return showModalBottomSheet<RateRideResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateRideSheet(
        counterpartName: counterpartName,
        isRatingDriver: isRatingDriver,
      ),
    );
  }

  @override
  State<RateRideSheet> createState() => _RateRideSheetState();
}

class _RateRideSheetState extends State<RateRideSheet> {
  int _selectedStars = 0;
  final Set<RatingTag> _selectedTags = {};
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  List<RatingTag> get _availableTags => widget.isRatingDriver
      ? [
          RatingTag.onTime,
          RatingTag.cleanCar,
          RatingTag.smoothDriving,
          RatingTag.safeDriver,
          RatingTag.friendly,
          RatingTag.comfortable,
        ]
      : [
          RatingTag.onTime,
          RatingTag.polite,
          RatingTag.friendly,
          RatingTag.greatConversation,
        ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isAr ? 'ar' : 'en';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            isAr ? 'كيف كانت رحلتك؟' : 'How was your ride?',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'قيّم ${widget.counterpartName}'
                : 'Rate ${widget.counterpartName}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = starNumber),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starNumber <= _selectedStars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 44,
                    color: starNumber <= _selectedStars
                        ? AppTheme.accentGold
                        : AppTheme.textTertiary,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Rating label
          if (_selectedStars > 0)
            Text(
              _ratingLabel(_selectedStars, isAr),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.accentGoldDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 20),

          // Quick tags
          if (_selectedStars > 0) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag.label(locale)),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor:
                      AppTheme.primaryGreenLight.withValues(alpha: 0.3),
                  checkmarkColor: AppTheme.primaryGreen,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText:
                    isAr ? 'أضف تعليقاً (اختياري)' : 'Add a comment (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedStars > 0 ? _submit : null,
              child: Text(isAr ? 'إرسال التقييم' : 'Submit Rating'),
            ),
          ),
          const SizedBox(height: 8),

          // Skip button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isAr ? 'تخطي' : 'Skip'),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int stars, bool isAr) {
    if (isAr) {
      return switch (stars) {
        1 => 'سيئة 😞',
        2 => 'مقبولة 😐',
        3 => 'جيدة 🙂',
        4 => 'ممتازة 😊',
        5 => 'رائعة! ⭐',
        _ => '',
      };
    }
    return switch (stars) {
      1 => 'Poor 😞',
      2 => 'Fair 😐',
      3 => 'Good 🙂',
      4 => 'Great 😊',
      5 => 'Excellent! ⭐',
      _ => '',
    };
  }

  void _submit() {
    final comment = _commentController.text.trim();
    final result = RateRideResult(
      score: _selectedStars,
      tags: _selectedTags.map((t) => t.key).toList(),
      comment: comment.isEmpty ? null : comment,
    );

    // Trigger store rating check — §2.5 / FT-20.
    // After a 5-star rating this is the peak satisfaction moment.
    // StoreRatingService handles all cooldown / eligibility logic internally.
    StoreRatingService(InAppReview.instance).onTripCompleted(
      fiveStarRating: _selectedStars == 5,
    );

    Navigator.of(context).pop(result);
  }
}

/// Result returned from the rating dialog.
class RateRideResult {
  final int score;
  final List<String> tags;
  final String? comment;

  const RateRideResult({
    required this.score,
    this.tags = const [],
    this.comment,
  });
}
