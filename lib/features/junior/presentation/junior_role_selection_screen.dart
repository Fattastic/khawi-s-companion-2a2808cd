import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

class JuniorRoleSelectionScreen extends ConsumerWidget {
  const JuniorRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE9E7),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.juniorRoleTitle ?? "Who are you?",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F0081),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF3F0081)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            KhawiMotion.slideUpFadeIn(
              _buildRoleCard(
                context,
                ref,
                AppLocalizations.of(context)?.juniorRoleGuardian ??
                    "Guardian / Parent",
                AppLocalizations.of(context)?.juniorRoleGuardianDesc ??
                    "I want to track my kids and manage drivers.",
                Icons.family_restroom,
                Colors.orange,
                () {
                  Future(() async {
                    await ref
                        .read(juniorOnboardingDoneProvider.notifier)
                        .setDone(true);
                    if (context.mounted) context.go(Routes.juniorHub);
                  });
                },
              ),
              index: 0,
            ),
            const SizedBox(height: 24),
            KhawiMotion.slideUpFadeIn(
              _buildRoleCard(
                context,
                ref,
                AppLocalizations.of(context)?.juniorRoleDriver ??
                    "Family Driver",
                AppLocalizations.of(context)?.juniorRoleDriverDesc ??
                    "I am an appointed driver for school runs.",
                Icons.time_to_leave,
                const Color(0xFF3F0081),
                () {
                  Future(() async {
                    await ref
                        .read(juniorOnboardingDoneProvider.notifier)
                        .setDone(true);
                    if (context.mounted) context.go(Routes.juniorAppointedDash);
                  });
                },
              ),
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
