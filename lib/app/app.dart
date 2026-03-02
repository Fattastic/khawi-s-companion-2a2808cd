import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

import '../core/deep_links/deep_link_service.dart';
import '../core/localization/app_localizations.dart';
import '../core/providers/connectivity_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/gamification/data/gamification_providers.dart';
import '../state/app_settings.dart';
import '../dev/qa_nav_overlay.dart';

class KhawiApp extends ConsumerStatefulWidget {
  const KhawiApp({super.key, this.themeOverride});

  /// Optional theme for test environments (avoids GoogleFonts in tests).
  final ThemeData? themeOverride;

  @override
  ConsumerState<KhawiApp> createState() => _KhawiAppState();
}

class _KhawiAppState extends ConsumerState<KhawiApp> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    // Start listening for warm-start deep links (app already open when link
    // is tapped). Cold-start links are handled automatically by GoRouter.
    final router = ref.read(routerProvider);
    _deepLinkService.init(router);
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final localeAsync = ref.watch(localeProvider);
    final themeModeAsync = ref.watch(themeModeProvider);

    // Trigger weekly mission assignment once per session (fire-and-forget).
    ref.watch(gamificationInitProvider);

    final textScale = ref.watch(textScaleProvider).maybeWhen(
          data: (s) => s,
          orElse: () => 1.0,
        );
    final highContrast = ref.watch(highContrastProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );

    final locale = localeAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const Locale('ar'),
    );

    final themeMode = themeModeAsync.maybeWhen(
      data: (m) => m,
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: widget.themeOverride ?? AppTheme.lightTheme,
      darkTheme: widget.themeOverride != null ? null : AppTheme.darkTheme,
      themeMode: widget.themeOverride != null ? ThemeMode.light : themeMode,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      builder: (context, child) {
        Widget body = child ?? const SizedBox.shrink();
        if (qaNavOverlayEnabled) {
          body = Stack(children: [body, const QaNavOverlay()]);
        }
        // ── Accessibility wrappers ──────────────────────────────────────────
        // Text scale: override MediaQuery.textScaler so ALL text in the app
        // respects the user's chosen scale without relying on OS settings.
        // Also applies disableAnimations from reduceMotionProvider — this single
        // flag is checked by AnimationController.forward/reverse and all
        // AnimatedWidget subclasses, so every animation in the app is covered.
        final reduceMotion = ref.watch(reduceMotionProvider).maybeWhen(
              data: (v) => v,
              orElse: () => false,
            );
        body = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion,
          ),
          child: body,
        );
        // High contrast: swap the ThemeData colorScheme to stark black/white.
        if (highContrast) {
          final base = Theme.of(context);
          body = Theme(
            data: base.copyWith(
              colorScheme: base.brightness == Brightness.dark
                  ? const ColorScheme.dark()
                  : const ColorScheme.light(),
            ),
            child: body,
          );
        }
        return _OfflineBanner(child: body);
      },
    );
  }
}

/// Wraps its child with a red offline banner that slides in/out
/// whenever the device loses or regains internet connectivity.
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );

    return Column(
      children: [
        Expanded(child: child),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isOffline
              ? Material(
                  color: Colors.red.shade700,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)
                                    ?.noInternetConnection ??
                                'No internet connection',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
