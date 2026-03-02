import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';

class InstantRideDriverScreen extends StatelessWidget {
  const InstantRideDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n?.instantRide ?? 'Instant Ride',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3F0081),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3F0081),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.flash_on, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.acceptInstantRides ?? "Accept Instant Rides",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.acceptInstantRidesDescription ??
                        "Receive requests from passengers near you who need a ride right now.",
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: Text(
                      l10n?.goOnline ?? "Go Online",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: true,
                    onChanged: (val) {},
                    // ignore: deprecated_member_use
                    // ignore: deprecated_member_use
                    activeColor: Colors.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n?.howItWorks ?? "How it works",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              Icons.wifi,
              l10n?.instantRideStep1 ??
                  "Go online to start receiving requests.",
            ),
            _buildStep(
              Icons.timer,
              l10n?.instantRideStep2 ??
                  "You have 30 seconds to accept a request.",
            ),
            _buildStep(
              Icons.map,
              l10n?.instantRideStep3 ??
                  "Follow the map to the passenger's location.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F0081).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF3F0081), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
