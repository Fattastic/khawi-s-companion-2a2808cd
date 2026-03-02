import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/khawi_button.dart';
import 'package:khawi_flutter/state/app_settings.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).setDone(true);
    // Let the centralized router redirect decide the correct next step.
    if (mounted) context.go(Routes.authLogin);
  }

  void _onNext(int slideCount) {
    if (_currentPage < slideCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutQuart,
      );
      return;
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeAsync = ref.watch(localeProvider);
    final currentCode = localeAsync.maybeWhen(
      data: (l) => l.languageCode,
      orElse: () => 'ar',
    );

    final slides = <_OnboardingData>[
      _OnboardingData(
        title:
            l10n?.onboardingSlide1Title ?? 'Share the road and reduce traffic.',
        description: l10n?.onboardingZeroCommissionDescription ??
            'We charge 0% commission. Usage is free, subscription is only for rewards.',
        icon: Icons.route,
        color: AppTheme.primaryGreen,
      ),
      _OnboardingData(
        title:
            l10n?.onboardingSlide2Title ?? 'Earn points for every kilometer.',
        description: l10n?.onboardingSlide2Description ??
            'XP, badges, weekly challenges... and real rewards.',
        icon: Icons.bolt,
        color: AppTheme.accentGold,
      ),
      _OnboardingData(
        title: l10n?.onboardingSlide3Title ??
            'Multiply your points during peak hours!',
        description: l10n?.onboardingSlide3Description ??
            'Incentives that reduce congestion and emissions.',
        icon: Icons.eco,
        color: AppTheme.primaryGreen,
      ),
      _OnboardingData(
        title:
            l10n?.onboardingSlide4Title ?? 'Zero Commission. 100% Community.',
        description: l10n?.onboardingSubscriptionDescription ??
            'Finding rides is always free. Subscribe to turn your XP into coffee, fuel, and more.',
        icon: Icons.groups,
        color: AppTheme.primaryGreen,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_currentPage == 0)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _LanguageToggle(
                    selectedCode: currentCode,
                    arabicLabel: l10n?.languageArabic ?? 'Arabic',
                    englishLabel: l10n?.languageEnglish ?? 'English',
                    onSelect: (code) => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(code)),
                  ),
                ),
              if (_currentPage == 0) const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: AppTheme.shadowMedium,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Parallax icon entrance
                              KhawiMotion.scaleIn(
                                duration: MotionTokens.t4,
                                curve: MotionTokens.entrance,
                                startScale: 0.7,
                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: slide.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 76,
                                    color: slide.color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              // Staggered title (index 0 = no delay)
                              KhawiMotion.slideUpFadeIn(
                                index: 0,
                                duration: MotionTokens.t3,
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Staggered description (index 3 = 150ms delay)
                              KhawiMotion.slideUpFadeIn(
                                index: 3,
                                duration: MotionTokens.t3,
                                Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) {
                  final selected = _currentPage == index;
                  return AnimatedScale(
                    scale: selected ? 1.0 : 0.85,
                    duration: MotionTokens.t2,
                    curve: selected
                        ? MotionTokens.entrance
                        : MotionTokens.standard,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: selected ? 26 : 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryGreen
                            : AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              KhawiButton(
                text: _currentPage == slides.length - 1
                    ? (l10n?.getStarted ?? 'Get Started!')
                    : (l10n?.next ?? 'Next'),
                onPressed: () => _onNext(slides.length),
                isFullWidth: true,
                type: AppButtonType.primary,
              ),
              const SizedBox(height: 8),
              if (_currentPage < slides.length - 1)
                TextButton(
                  onPressed: _finish,
                  child: Text(l10n?.skip ?? 'Skip'),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final String selectedCode;
  final String arabicLabel;
  final String englishLabel;
  final ValueChanged<String> onSelect;

  const _LanguageToggle({
    required this.selectedCode,
    required this.arabicLabel,
    required this.englishLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = selectedCode == 'ar';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangChip(
              label: arabicLabel,
              selected: isArabic,
              onTap: () => onSelect('ar'),
            ),
            const SizedBox(width: 6),
            _LangChip(
              label: englishLabel,
              selected: !isArabic,
              onTap: () => onSelect('en'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryGreen : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppTheme.textPrimary,
                ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
