import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Shows app version, Privacy Policy, and Terms of Service links.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Replace these with real hosted URLs before production launch.
  static const _privacyPolicyUrl = 'https://khawi.app/privacy-policy';
  static const _termsUrl = 'https://khawi.app/terms-of-service';

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreAboutKhawi),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Logo + version
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_icon_legacy.png',
                    width: 96,
                    height: 96,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Khawi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 0.1.0 (Alpha)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Legal links
          _LegalTile(
            icon: Icons.privacy_tip_outlined,
            label: l10n.privacyPolicy,
            onTap: () => _launch(context, _privacyPolicyUrl),
            isRtl: isRtl,
          ),
          const Divider(),
          _LegalTile(
            icon: Icons.gavel_outlined,
            label: l10n.termsOfService,
            onTap: () => _launch(context, _termsUrl),
            isRtl: isRtl,
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              '© ${DateTime.now().year} Khawi. All rights reserved.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isRtl,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(label, textAlign: isRtl ? TextAlign.right : TextAlign.left),
      trailing: Icon(
        isRtl ? Icons.chevron_left : Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
