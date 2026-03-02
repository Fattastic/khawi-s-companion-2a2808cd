import 'package:flutter/material.dart';

/// Utility mixin that guards the OS back button in multi-step wizard flows.
///
/// UX contract (§1.2 / UX-14):
///  - Back must never eject the user to the home screen mid-flow.
///  - Back must return to the prior step with all entered data intact.
///  - If there is unsaved progress and no prior step, prompt for confirmation
///    before dismissing.
///
/// Usage:
/// ```dart
/// class _MyWizardState extends State<MyWizard> with BackGuardMixin {
///   @override
///   bool get hasUnsavedProgress => _formIsDirty;
///
///   @override
///   Widget build(BuildContext context) {
///     return PopScope(
///       canPop: false,
///       onPopInvokedWithResult: onPopInvoked,
///       child: ...
///     );
///   }
/// }
/// ```
mixin BackGuardMixin<T extends StatefulWidget> on State<T> {
  /// Override to indicate whether the current screen has unsaved progress.
  /// When true, a confirmation dialog is shown before allowing the pop.
  bool get hasUnsavedProgress => false;

  /// Called by PopScope.onPopInvokedWithResult.
  /// Handles the confirmation dialog and programmatic pop if the user confirms.
  Future<void> onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return; // Already popped — nothing to do.

    if (!hasUnsavedProgress) {
      // No unsaved data: allow immediate back navigation.
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    // Ask for confirmation before discarding progress.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'تجاهل التغييرات؟' : 'Discard changes?'),
        content: Text(
          isRtl
              ? 'ستُفقد البيانات التي أدخلتها. هل تريد المتابعة؟'
              : 'Your entered data will be lost. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isRtl ? 'رجوع للتحرير' : 'Keep editing'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isRtl ? 'تجاهل' : 'Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
