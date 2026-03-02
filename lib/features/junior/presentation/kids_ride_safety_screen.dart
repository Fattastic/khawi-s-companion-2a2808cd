import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/app/routes.dart';

class KidsRideSafetyScreen extends StatelessWidget {
  const KidsRideSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD700), // Safety Yellow
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 100, color: Color(0xFF3F0081)),
              const SizedBox(height: 32),
              Text(
                "Safety First!",
                style: GoogleFonts.bungee(
                  fontSize: 32,
                  color: const Color(0xFF3F0081),
                ),
              ),
              const SizedBox(height: 24),
              const _SafetyTip(
                icon: Icons.check_circle,
                text: "Wait for the driver in a safe spot.",
              ),
              const _SafetyTip(
                icon: Icons.check_circle,
                text: "Check the car's plate number.",
              ),
              const _SafetyTip(
                icon: Icons.check_circle,
                text: "Buckle up your seatbelt!",
              ),
              const _SafetyTip(
                icon: Icons.check_circle,
                text: "Enjoy your ride!",
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.juniorRoleSelection),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F0081),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "I'm Ready!",
                    style: GoogleFonts.bungee(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyTip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SafetyTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3F0081)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
