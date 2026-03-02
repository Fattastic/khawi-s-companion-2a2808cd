import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/state/providers.dart';

enum TripIssueType {
  issue,
  lostAndFound,
}

class TripIssueSheet extends ConsumerStatefulWidget {
  final String tripId;

  const TripIssueSheet({
    super.key,
    required this.tripId,
  });

  static Future<void> show(BuildContext context, {required String tripId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TripIssueSheet(tripId: tripId),
    );
  }

  @override
  ConsumerState<TripIssueSheet> createState() => _TripIssueSheetState();
}

class _TripIssueSheetState extends ConsumerState<TripIssueSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();
  TripIssueType _type = TripIssueType.issue;
  bool _submitting = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRtl ? 'الإبلاغ عن مشكلة' : 'Report an issue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TripIssueType>(
                // ignore: deprecated_member_use
                value: _type,
                items: [
                  DropdownMenuItem(
                    value: TripIssueType.issue,
                    child: Text(isRtl ? 'مشكلة في الرحلة' : 'Trip issue'),
                  ),
                  DropdownMenuItem(
                    value: TripIssueType.lostAndFound,
                    child: Text(isRtl ? 'مفقودات وموجودات' : 'Lost & Found'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _type == TripIssueType.lostAndFound
                      ? (isRtl
                          ? 'اذكر الشيء المفقود ومكانه التقريبي ووقت الرحلة'
                          : 'Describe the lost item, likely location, and trip time')
                      : (isRtl
                          ? 'اكتب تفاصيل المشكلة'
                          : 'Describe the issue in detail'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isRtl ? 'أدخل التفاصيل' : 'Please add details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _submit(isRtl: isRtl),
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isRtl ? 'إرسال' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit({required bool isRtl}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final subject = _type == TripIssueType.lostAndFound
        ? (isRtl
            ? 'مفقودات - رحلة ${widget.tripId}'
            : 'Lost & Found - Trip ${widget.tripId}')
        : (isRtl
            ? 'بلاغ مشكلة - رحلة ${widget.tripId}'
            : 'Trip issue - Trip ${widget.tripId}');

    try {
      await ref.read(supportRepoProvider).createTicket(
            subject: subject,
            body: _bodyController.text.trim(),
            tripId: widget.tripId,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl ? 'تم إرسال البلاغ للدعم' : 'Your report has been sent',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isRtl ? 'تعذر الإرسال: $e' : 'Failed to submit: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
