import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/app_surface.dart';

class SmartMatchPromo extends StatelessWidget {
  const SmartMatchPromo({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      onTap: () => context.push(Routes.sharedSmartCommute),
      child: AppSurface(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        color: AppTheme.primaryGreen.withValues(alpha: 0.06),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isRtl
                              ? "المطابقة الذكية مفعّلة"
                              : "SmartMatch AI Active",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRtl
                        ? "نحلل آلاف المسارات للعثور على رفيق المشوار المثالي."
                        : "We analyze thousands of routes to find you the perfect commute partner.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
