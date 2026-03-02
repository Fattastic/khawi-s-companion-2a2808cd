import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';

class KidsRideSplashScreen extends StatefulWidget {
  const KidsRideSplashScreen({super.key});

  @override
  State<KidsRideSplashScreen> createState() => _KidsRideSplashScreenState();
}

class _KidsRideSplashScreenState extends State<KidsRideSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go(Routes.juniorSafety);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F0081),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.rocket_launch,
                size: 100,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "KHAWI JUNIOR",
              style: GoogleFonts.bungee(fontSize: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Ready for an adventure?",
              style: GoogleFonts.inter(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
