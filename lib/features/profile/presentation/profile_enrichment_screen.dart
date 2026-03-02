import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/utils/back_guard_mixin.dart';
import 'package:khawi_flutter/features/profile/domain/profile_extension.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Profile enrichment screen shown BEFORE role selection.
///
/// Split into two sections via progressive disclosure:
/// - **Required**: fullName (minimal profile fields).
/// - **Optional**: city, preferences, vehicle info (skippable).
///
/// On success, does NOT navigate imperatively — the router redirect
/// detects `profile.fullName.isNotEmpty` and moves to `/auth/role`.
class ProfileEnrichmentScreen extends ConsumerStatefulWidget {
  const ProfileEnrichmentScreen({super.key});

  @override
  ConsumerState<ProfileEnrichmentScreen> createState() =>
      _ProfileEnrichmentScreenState();
}

class _ProfileEnrichmentScreenState
    extends ConsumerState<ProfileEnrichmentScreen> with BackGuardMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _currentStep = 0;
  bool _saving = false;

  @override
  bool get hasUnsavedProgress =>
      _currentStep > 0 || _nameController.text.trim().isNotEmpty;

  // Optional fields (step 2)
  String? _city;
  final List<String> _purposes = [];
  bool _ownsCar = false;
  String? _vehicleType;
  bool _hasAc = false;
  bool _hasChildSeat = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvoked,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGreen,
        appBar: AppBar(
          title: Text(isRtl ? 'إنشاء حسابك' : 'Create Your Profile'),
          backgroundColor: AppTheme.backgroundGreen,
          foregroundColor: AppTheme.textDark,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Progress indicator ──
              KhawiMotion.slideUpFadeIn(
                _buildProgressBar(theme, isRtl),
                index: 0,
              ),
              // ── Content ──
              Expanded(
                child: KhawiMotion.slideUpFadeIn(
                  _currentStep == 0
                      ? _buildRequiredStep(theme, isRtl)
                      : _buildOptionalStep(theme, isRtl),
                  index: 1,
                ),
              ),
            ],
          ),
        ),
      ), // PopScope
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROGRESS BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressBar(ThemeData theme, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              _stepDot(0, isRtl ? 'الملف الشخصي' : 'Profile'),
              Expanded(child: _stepLine(0)),
              _stepDot(1, isRtl ? 'اختيار الدور' : 'Role'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'الخطوة ${_currentStep + 1} من 2'
                : 'Step ${_currentStep + 1} of 2',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int step, String label) {
    final active = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryGreen : AppTheme.borderColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: active
              ? (_currentStep > step
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ))
              : Text(
                  '${step + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppTheme.primaryGreen : AppTheme.textTertiary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int afterStep) {
    final completed = _currentStep > afterStep;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: completed ? AppTheme.primaryGreen : AppTheme.borderColor,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1: REQUIRED — Minimal Profile
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRequiredStep(ThemeData theme, bool isRtl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'مرحباً بك في خاوي!' : 'Welcome to Khawi!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'أخبرنا عن نفسك للبدء.'
                  : "Tell us about yourself to get started.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Full Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(
                labelText: isRtl ? 'الاسم الكامل *' : 'Full Name *',
                hintText: isRtl ? 'مثلاً: أحمد محمد' : 'e.g. Ahmed Mohammed',
                helperText: isRtl
                    ? 'سيظهر اسمك للركاب والسائقين'
                    : 'Your name will be visible to riders and drivers',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return isRtl ? 'الاسم مطلوب' : 'Name is required';
                }
                if (v.trim().length < 2) {
                  return isRtl
                      ? 'يجب أن يكون الاسم حرفين على الأقل'
                      : 'Name must be at least 2 characters';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 40),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _saveMinimalProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isRtl ? 'متابعة' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMinimalProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      // Upsert fullName into profiles table.
      await ref.read(supabaseClientProvider).from('profiles').upsert(
        {'id': uid, 'full_name': _nameController.text.trim()},
        onConflict: 'id',
      );

      // DO NOT invalidate myProfileProvider here.
      // The realtime stream may deliver the update and trigger a redirect
      // before the user can fill step 2. Defer invalidation until step 2
      // is completed or skipped.

      if (mounted) {
        setState(() {
          _currentStep = 1;
          _saving = false;
        });
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2: OPTIONAL — Preferences (skippable)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOptionalStep(ThemeData theme, bool isRtl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'أخبرنا المزيد (اختياري)' : 'Tell us more (optional)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'يمكنك تخطي هذه الخطوة والعودة لاحقاً'
                : 'You can skip this and come back later',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ── City ──
          TextFormField(
            decoration: InputDecoration(
              labelText: isRtl ? 'المدينة' : 'City',
              hintText: isRtl ? 'مثلاً: الرياض' : 'e.g. Riyadh',
              prefixIcon: const Icon(Icons.location_city),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => _city = v,
          ),
          const SizedBox(height: 16),

          // ── Trip purposes ──
          Text(
            isRtl ? 'الغرض من الرحلات:' : 'Trip Purposes:',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildPurposeChips(isRtl),
          const SizedBox(height: 20),

          // ── Vehicle info ──
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(isRtl ? 'هل تملك سيارة؟' : 'Do you own a car?'),
            subtitle: Text(
              isRtl
                  ? 'إذا كنت تخطط للقيادة مع خاوي'
                  : 'If you plan to drive with Khawi',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textTertiary),
            ),
            value: _ownsCar,
            onChanged: (v) => setState(() => _ownsCar = v),
          ),
          if (_ownsCar) ..._buildVehicleFields(isRtl),

          const SizedBox(height: 32),

          // ── Action buttons ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _saveOptionalAndContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isRtl ? 'حفظ ومتابعة' : 'Save & Continue',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _saving ? null : _skipOptional,
              child: Text(
                isRtl ? 'تخطي الآن' : 'Skip for now',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeChips(bool isRtl) {
    final purposes = [
      {'val': 'work', 'en': 'Work', 'ar': 'العمل'},
      {'val': 'school', 'en': 'School', 'ar': 'المدرسة'},
      {'val': 'mosque', 'en': 'Mosque', 'ar': 'المسجد'},
      {'val': 'social', 'en': 'Social', 'ar': 'اجتماعي'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: purposes.map((p) {
        final selected = _purposes.contains(p['val']);
        return ChoiceChip(
          label: Text(isRtl ? p['ar']! : p['en']!),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _purposes.add(p['val']!);
              } else {
                _purposes.remove(p['val']);
              }
            });
          },
        );
      }).toList(),
    );
  }

  List<Widget> _buildVehicleFields(bool isRtl) {
    return [
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: isRtl ? 'نوع السيارة' : 'Vehicle Type',
          border: const OutlineInputBorder(),
        ),
        items: ['Sedan', 'SUV', 'Van', 'Other']
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => _vehicleType = v,
      ),
      const SizedBox(height: 8),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(isRtl ? 'تكييف متاح' : 'AC Available'),
        value: _hasAc,
        onChanged: (v) => setState(() => _hasAc = v ?? false),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(isRtl ? 'مقعد طفل متاح' : 'Child Seat Available'),
        value: _hasChildSeat,
        onChanged: (v) => setState(() => _hasChildSeat = v ?? false),
      ),
    ];
  }

  Future<void> _saveOptionalAndContinue() async {
    setState(() => _saving = true);
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (uid == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      final ext = ProfileExtension(
        userId: uid,
        roles: [],
        city: _city,
        purposes: _purposes,
        activityWindows: [],
        vehicleInfo: VehicleInfo(
          ownsCar: _ownsCar,
          type: _vehicleType,
          hasAc: _hasAc,
          hasChildSeat: _hasChildSeat,
          condition: 'good',
        ),
      );
      await ref.read(profileRepoProvider).updateExtensions(uid, ext.toJson());
    } catch (_) {
      // Non-critical; optional data — proceed even on error.
    }

    setState(() => _saving = false);
    // Router will auto-redirect to /auth/role now that profile is complete.
    // Invalidate to ensure freshest profile state.
    ref.invalidate(myProfileProvider);
  }

  void _skipOptional() {
    // Profile fullName was saved in step 1, so router will detect it
    // and redirect to /auth/role automatically.
    ref.invalidate(myProfileProvider);
  }
}
