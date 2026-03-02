import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/widgets/khawi_button.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

class JuniorIntroScreen extends StatelessWidget {
  const JuniorIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFBE9E7), // Soft orange/pink background for kids theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: Color(0xFFFF8C00),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)?.juniorIntroTitle ??
                    "Khawi Junior",
                style: GoogleFonts.chewy(
                  // Check if this font is available or use generic rounded
                  fontSize: 48,
                  color: const Color(0xFF3F0081),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.juniorIntroSubtitle ??
                    "Safety First School Runs",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              KhawiMotion.slideUpFadeIn(
                _buildPoint(
                  Icons.security,
                  AppLocalizations.of(context)?.juniorSafetyPoint ??
                      "Guardian Drivers only (Verified + Vetted)",
                ),
                index: 0,
              ),
              KhawiMotion.slideUpFadeIn(
                _buildPoint(
                  Icons.family_restroom,
                  AppLocalizations.of(context)?.juniorFamilyPoint ??
                      "Appoint trusted Family Drivers",
                ),
                index: 1,
              ),
              KhawiMotion.slideUpFadeIn(
                _buildPoint(
                  Icons.location_on,
                  AppLocalizations.of(context)?.juniorTrackingPoint ??
                      "Live Tracking for Parents",
                ),
                index: 2,
              ),
              const Spacer(),
              KhawiButton(
                onPressed: () => context.go(Routes.juniorSafety),
                text:
                    AppLocalizations.of(context)?.juniorContinue ?? "Continue",
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.pop(), // Go back if they clicked by mistake
                child: Text(
                  AppLocalizations.of(context)?.juniorNotParent ??
                      "Not a Parent?",
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
