import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

class PassengerSearchBar extends StatelessWidget {
  const PassengerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => context.go(Routes.passengerSearch),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const Icon(Icons.search, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.whereAreYouGoing ??
                    (isRtl
                        ? 'وين ناوي تروح اليوم؟'
                        : 'Where are you going today?'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
