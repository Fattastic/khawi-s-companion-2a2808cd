import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Public bottom-sheet widget for opening a support ticket.
///
/// Used from both [HelpCenterScreen] and [SettingsScreen] so the sheet is
/// defined once and re-used wherever "Chat with Support" appears.
///
/// Usage:
/// ```dart
/// showModalBottomSheet<void>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.white,
///   shape: const RoundedRectangleBorder(
///     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
///   ),
///   builder: (_) => const ContactSupportSheet(),
/// );
/// ```
class ContactSupportSheet extends ConsumerStatefulWidget {
  const ContactSupportSheet({super.key});

  @override
  ConsumerState<ContactSupportSheet> createState() =>
      _ContactSupportSheetState();
}

class _ContactSupportSheetState extends ConsumerState<ContactSupportSheet> {
  final _subjectCtl = TextEditingController();
  final _bodyCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _subjectCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(supportRepoProvider).createTicket(
            subject: _subjectCtl.text.trim(),
            body: _bodyCtl.text.trim(),
          );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRtl
                  ? 'حدث خطأ — حاول مرة أخرى'
                  : 'Error submitting — please try again',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: _submitted ? _buildSuccess(isRtl) : _buildForm(isRtl),
      ),
    );
  }

  Widget _buildSuccess(bool isRtl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.check_circle_outline,
          color: AppTheme.primaryGreen,
          size: 56,
        ),
        const SizedBox(height: 16),
        Text(
          isRtl ? 'تم إرسال طلبك!' : 'Ticket submitted!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isRtl
              ? 'سيرد فريق الدعم عبر البريد الإلكتروني خلال ساعتين.'
              : 'Our support team will reply to your email within 2 hours.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: Text(isRtl ? 'تم' : 'Done'),
        ),
      ],
    );
  }

  Widget _buildForm(bool isRtl) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'تواصل مع الدعم' : 'Contact Support',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'سيتم الرد على بريدك الإلكتروني في غضون ساعتين'
                : "We'll reply to your account email within 2 hours",
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _subjectCtl,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              labelText: isRtl ? 'الموضوع' : 'Subject',
              hintText:
                  isRtl ? 'مثال: مشكلة في الدفع' : 'e.g. Issue with payment',
              border: const OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (isRtl ? 'الموضوع مطلوب' : 'Subject is required')
                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyCtl,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: isRtl ? 'الرسالة' : 'Message',
              hintText: isRtl
                  ? 'صف مشكلتك بالتفصيل لنتمكن من مساعدتك بسرعة'
                  : 'Describe your issue in detail so we can help faster',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().length < 10)
                ? (isRtl
                    ? 'الرجاء إدخال تفاصيل كافية'
                    : 'Please provide sufficient detail')
                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                isRtl ? 'إرسال' : 'Send',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
