import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
// supabase operations use providers via `authRepoProvider`.

import '../../core/localization/app_localizations.dart';
import '../../features/profile/domain/profile.dart';

const int kSafetyDisclaimerVersion = 1;

String _acceptKey(UserRole role) =>
    'khawi_safety_disclaimer_v${kSafetyDisclaimerVersion}_${role.name}_accepted';

Future<bool> isSafetyDisclaimerAccepted(UserRole role) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_acceptKey(role)) ?? false;
}

Future<void> setSafetyDisclaimerAccepted(UserRole role, bool accepted) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_acceptKey(role), accepted);
}

Future<void> showSafetyDisclaimerDialog(
  BuildContext context,
  WidgetRef ref, {
  required UserRole role,
  bool allowDecline = true,
  bool markAcceptedOnAgree = true,
}) async {
  final l10n = AppLocalizations.of(context)!;

  Future<void> onAgree() async {
    if (markAcceptedOnAgree) {
      await setSafetyDisclaimerAccepted(role, true);
    }
    if (context.mounted) Navigator.of(context).pop(true);
  }

  Future<void> onDecline() async {
    try {
      await ref.read(authRepoProvider).signOut();
    } catch (_) {
      // ignore
    }
    if (context.mounted) {
      Navigator.of(context).pop(false);
      context.go('/auth/login');
    }
  }

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.safetyDisclaimerTitle),
        content: SingleChildScrollView(
          child: Text(
            l10n.safetyDisclaimerBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          if (allowDecline)
            TextButton(
              onPressed: onDecline,
              child: Text(l10n.safetyDisclaimerDecline),
            ),
          FilledButton(
            onPressed: onAgree,
            child: Text(l10n.safetyDisclaimerAgree),
          ),
        ],
      );
    },
  );
}

/// Wraps shell contents and forces users to accept Safety & Rules once per role.
class SafetyDisclaimerGate extends ConsumerStatefulWidget {
  const SafetyDisclaimerGate({
    super.key,
    required this.role,
    required this.child,
  });

  final UserRole role;
  final Widget child;

  @override
  ConsumerState<SafetyDisclaimerGate> createState() =>
      _SafetyDisclaimerGateState();
}

class _SafetyDisclaimerGateState extends ConsumerState<SafetyDisclaimerGate> {
  bool _checked = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndMaybeShow());
  }

  @override
  void didUpdateWidget(covariant SafetyDisclaimerGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _checked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndMaybeShow());
    }
  }

  Future<void> _checkAndMaybeShow() async {
    if (_checked || _dialogShowing || !mounted) return;

    final accepted = await isSafetyDisclaimerAccepted(widget.role);
    _checked = true;

    if (!accepted && mounted) {
      _dialogShowing = true;
      await showSafetyDisclaimerDialog(
        context,
        ref,
        role: widget.role,
        allowDecline: true,
        markAcceptedOnAgree: true,
      );
      _dialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
