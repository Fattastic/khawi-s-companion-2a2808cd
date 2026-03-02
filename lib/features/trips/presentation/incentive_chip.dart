import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncentiveChip extends StatelessWidget {
  final double multiplier;
  final String reason;

  const IncentiveChip({
    super.key,
    required this.multiplier,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    if (multiplier <= 1.0) return const SizedBox.shrink();

    Color bg = const Color(0xFFFF8C00); // Orange default
    const IconData icon = Icons.bolt;
    String text = "${multiplier.toStringAsFixed(1)}x XP";

    if (reason == 'demand_high') {
      bg = const Color(0xFFFF4500); // Red-Orange
      text += " (Hot!)";
    } else if (reason == 'balanced') {
      bg = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
