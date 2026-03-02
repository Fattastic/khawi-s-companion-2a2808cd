import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/support/presentation/contact_support_sheet.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Help Center screen — §4.10 of the UX requirements.
///
/// Provides:
///  - Semantic search across help articles
///  - Suggested topics
///  - Browseable categories
///  - Article view with steps
///  - Escalation to support ticket
class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(isRtl ? 'مركز المساعدة' : 'Help Center'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: isRtl ? 'ابحث عن مساعدة...' : 'Search for help...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_query.isEmpty) ...[
                  _SectionHeader(isRtl ? 'مواضيع مقترحة' : 'Suggested Topics'),
                  const SizedBox(height: 8),
                  ..._suggestedTopics(isRtl).map(
                    (t) => _ArticleTile(topic: t, isRtl: isRtl),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    isRtl ? 'تصفح حسب الفئة' : 'Browse by Category',
                  ),
                  const SizedBox(height: 8),
                  ..._categories(isRtl).map(
                    (c) => _CategoryTile(category: c, isRtl: isRtl),
                  ),
                ] else ...[
                  _SectionHeader(isRtl ? 'نتائج البحث' : 'Search Results'),
                  const SizedBox(height: 8),
                  ..._allArticles(isRtl)
                      .where(
                        (a) =>
                            a.title.toLowerCase().contains(_query) ||
                            a.body.toLowerCase().contains(_query),
                      )
                      .map((a) => _ArticleTile(topic: a, isRtl: isRtl))
                      .toList()
                      .let(
                        (list) => list.isNotEmpty
                            ? list
                            : [
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      isRtl
                                          ? 'لا توجد نتائج'
                                          : 'No results found',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                      ),
                ],

                const SizedBox(height: 32),
                // ── Escalation ────────────────────────────────────────
                _ContactSupportCard(isRtl: isRtl),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_HelpTopic> _suggestedTopics(bool isRtl) => [
        _HelpTopic(
          icon: Icons.cancel_outlined,
          title: isRtl ? 'كيف أُلغي رحلة؟' : 'How do I cancel a ride?',
          body: isRtl
              ? 'يمكنك إلغاء الرحلة من شاشة الرحلة النشطة بالضغط على أيقونة الإلغاء. الإلغاء قبل 5 دقائق من وقت الانطلاق مجاني.'
              : 'You can cancel a ride from the active trip screen by tapping the cancel icon. Cancellations made more than 5 minutes before departure are free.',
        ),
        _HelpTopic(
          icon: Icons.star_outline,
          title: isRtl ? 'كيف يعمل نظام التقييم؟' : 'How do ratings work?',
          body: isRtl
              ? 'بعد كل رحلة، يُقيّم الركاب والسائقون بعضهم بنجوم من 1 إلى 5 إضافةً إلى وسوم الراحة. يظهر متوسط التقييم على بطاقة كل مستخدم.'
              : 'After every trip, passengers and drivers rate each other on a 1–5 star scale plus comfort tags. The average appears on every user card.',
        ),
        _HelpTopic(
          icon: Icons.sos,
          title: isRtl
              ? 'ماذا أفعل في حالة الطوارئ؟'
              : 'What to do in an emergency?',
          body: isRtl
              ? 'اضغط مطولاً على زر الطوارئ الأحمر في شاشة الرحلة النشطة. سيُبلَّغ جهات الاتصال الخاصة بك ويُسجَّل موقعك تلقائياً.'
              : 'Long-press the red SOS button on the active trip screen. Your emergency contacts are notified and your location is logged automatically.',
        ),
        _HelpTopic(
          icon: Icons.bolt,
          title: isRtl ? 'كيف أكسب نقاط الخبرة؟' : 'How do I earn XP?',
          body: isRtl
              ? 'تكسب نقاط مقابل كل رحلة مكتملة، وتقييمات تعطيها، ومتتاليات يومية، وتحديات أسبوعية، وإحالات ناجحة.'
              : 'You earn XP for every completed trip, ratings given, daily streaks, weekly challenges, and successful referrals.',
        ),
      ];

  List<_HelpCategory> _categories(bool isRtl) => [
        _HelpCategory(
          icon: Icons.directions_car_outlined,
          label: isRtl ? 'الرحلات' : 'Trips',
          color: AppTheme.primaryGreen,
        ),
        _HelpCategory(
          icon: Icons.person_outline,
          label: isRtl ? 'الحساب' : 'Account',
          color: Colors.blue,
        ),
        _HelpCategory(
          icon: Icons.shield_outlined,
          label: isRtl ? 'الأمان' : 'Safety',
          color: Colors.red,
        ),
        _HelpCategory(
          icon: Icons.payment,
          label: isRtl ? 'المدفوعات' : 'Payments',
          color: Colors.orange,
        ),
        const _HelpCategory(
          icon: Icons.workspace_premium,
          label: 'Khawi+',
          color: Color(0xFFFFB300),
        ),
        _HelpCategory(
          icon: Icons.child_care,
          label: isRtl ? 'جونيور' : 'Junior',
          color: Colors.purple,
        ),
      ];

  List<_HelpTopic> _allArticles(bool isRtl) => [
        ..._suggestedTopics(isRtl),
        _HelpTopic(
          icon: Icons.workspace_premium,
          title: isRtl ? 'ماهي مزايا Khawi+؟' : 'What are the Khawi+ benefits?',
          body: isRtl
              ? 'تشمل مزايا Khawi+ الأولوية في المطابقة، وشارات حصرية، وتجربة خالية من الإعلانات، وتحليلات متقدمة، وتأمين الرحلات.'
              : 'Khawi+ includes priority matching, exclusive badges, ad-free experience, enhanced analytics, and trip insurance.',
        ),
        _HelpTopic(
          icon: Icons.shield,
          title: isRtl
              ? 'ما هو نظام مستوى الثقة؟'
              : 'What is the trust tier system?',
          body: isRtl
              ? 'يتدرج النظام من برونزي إلى فضي إلى ذهبي إلى بلاتيني استناداً إلى التحقق من الهوية وعدد الرحلات والتقييمات.'
              : 'Trust tiers progress from Bronze → Silver → Gold → Platinum based on ID verification, ride count, and ratings.',
        ),
      ];
}

// ── Supporting widgets ───────────────────────────────────────────────────────

class _HelpTopic {
  final IconData icon;
  final String title;
  final String body;
  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _HelpCategory {
  final IconData icon;
  final String label;
  final Color color;
  const _HelpCategory({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textTertiary,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final _HelpTopic topic;
  final bool isRtl;
  const _ArticleTile({required this.topic, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () => _openArticle(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(topic.icon, color: AppTheme.primaryGreen, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    topic.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: AppTheme.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openArticle(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(topic.icon, color: AppTheme.primaryGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                topic.body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _ContactSupportCard(isRtl: isRtl),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _HelpCategory category;
  final bool isRtl;
  const _CategoryTile({required this.category, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const ContactSupportSheet(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: AppTheme.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  final bool isRtl;
  const _ContactSupportCard({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'لم تجد ما تبحث عنه؟' : 'Still need help?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'تواصل مع فريق الدعم وسنرد عليك في أسرع وقت.'
                : 'Contact our support team and we\'ll get back to you quickly.',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(isRtl ? 'تحدث مع الدعم' : 'Chat with Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const ContactSupportSheet(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

// ── Support ticket bottom sheet ───────────────────────────────────────────────

class _ContactSupportSheet extends ConsumerStatefulWidget {
  const _ContactSupportSheet();

  @override
  ConsumerState<_ContactSupportSheet> createState() =>
      _ContactSupportSheetState();
}

class _ContactSupportSheetState extends ConsumerState<_ContactSupportSheet> {
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'سيتم الرد على بريدك الإلكتروني في غضون ساعتين'
                : 'We\'ll reply to your account email within 2 hours',
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
