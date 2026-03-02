import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/rewards/data/rewards_repo.dart'
    show PremiumRequiredException;
import 'package:khawi_flutter/core/widgets/app_confetti.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

class RedeemXpScreen extends ConsumerStatefulWidget {
  const RedeemXpScreen({super.key});

  @override
  ConsumerState<RedeemXpScreen> createState() => _RedeemXpScreenState();
}

class _RedeemXpScreenState extends ConsumerState<RedeemXpScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showConfetti = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final isPremium = ref.watch(premiumProvider);

    return AppConfettiOverlay(
      isPlaying: _showConfetti,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGreen,
        appBar: AppBar(title: const Text('Redeem XP')),
        body: profileAsync.when(
          data: (profile) {
            // Khawi+ gate - must be premium to redeem
            if (!isPremium) {
              return _buildPremiumGate(context);
            }
            return _buildRedeemForm(context, profile.redeemableXp);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildPremiumGate(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Khawi+ Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Subscribe to Khawi+ (30 SAR/month) to redeem your XP for real rewards.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go(Routes.subscription),
                icon: const Icon(Icons.star),
                label: const Text('Subscribe to Khawi+'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemForm(BuildContext context, int redeemableXp) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Redeemable Balance',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Khawi+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$redeemableXp XP',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Convert your XP into real-world perks and rewards.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'XP amount',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 250',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _handleRedeem(redeemableXp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Redeem'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tip: redeeming does not reduce your Total XP (lifetime).',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRedeem(int redeemableXp) async {
    setState(() {
      _error = null;
    });

    final amount = int.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid XP amount');
      return;
    }
    if (amount > redeemableXp) {
      setState(() => _error = 'Not enough redeemable XP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(xpLedgerRepoProvider).redeemXp(amount);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showConfetti = true;
        _controller.clear();
      });
      KhawiMotion.hapticSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redeemed $amount XP'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } on PremiumRequiredException {
      // Server rejected due to non-premium status - redirect to subscription
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showPremiumRequiredDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showPremiumRequiredDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text('Khawi+ Required'),
          ],
        ),
        content: const Text(
          'Your premium subscription is not active. '
          'Subscribe to Khawi+ to redeem your XP for real rewards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(Routes.subscription);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
