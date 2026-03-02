import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

class TrustBadge extends StatelessWidget {
  final int score;
  final String badge; // 'gold', 'silver', 'bronze'
  final bool isJuniorTrusted;

  const TrustBadge({
    super.key,
    required this.score,
    required this.badge,
    this.isJuniorTrusted = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (badge.toLowerCase()) {
      case 'gold':
        color = const Color(0xFFFFD700);
        icon = Icons.verified;
        label = 'Gold Trusted';
        break;
      case 'silver':
        color = const Color(0xFFC0C0C0);
        icon = Icons.shield;
        label = 'Silver Trusted';
        break;
      default:
        color = const Color(0xFFCD7F32);
        icon = Icons.shield_outlined;
        label = 'Bronze Trusted';
    }

    return Semantics(
      label: 'Trust badge: $label. Score: $score.',
      excludeSemantics: true,
      child: ShimmerEffect(
        repeatCount: 1, // Periodic shimmer
        duration: const Duration(milliseconds: 2000),
        shimmerColor: color.withValues(alpha: 0.4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Score: $score",
                    style: GoogleFonts.inter(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (isJuniorTrusted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
