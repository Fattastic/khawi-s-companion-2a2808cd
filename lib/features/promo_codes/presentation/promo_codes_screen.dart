import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/promo_codes/domain/promo_code_offer.dart';
import 'package:khawi_flutter/features/promo_codes/domain/promo_discount_preview.dart';
import 'package:khawi_flutter/state/providers.dart';

final _myPromoCodesProvider =
    FutureProvider.autoDispose<List<PromoCodeOffer>>((ref) {
  return ref.watch(promoCodesRepoProvider).fetchMyActive();
});

class PromoCodesScreen extends ConsumerStatefulWidget {
  const PromoCodesScreen({super.key, this.initialCode});

  /// Pre-fills the code field when opened from a deep link.
  /// e.g. https://khawi.app/invite/KHAWI50
  final String? initialCode;

  @override
  ConsumerState<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends ConsumerState<PromoCodesScreen> {
  late final TextEditingController _codeController;
  final _fareController = TextEditingController(text: '40');
  bool _isClaiming = false;
  bool _isPreviewing = false;
  PromoDiscountPreview? _preview;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final promosAsync = ref.watch(_myPromoCodesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'أكواد الخصم' : 'Promo Codes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInputCard(context, isRtl),
          const SizedBox(height: 16),
          if (_preview != null) _buildPreviewCard(context, isRtl),
          const SizedBox(height: 20),
          Text(
            isRtl ? 'أكوادك الفعالة' : 'My Active Promos',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          promosAsync.when(
            data: (items) => _buildPromoList(context, items, isRtl),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                isRtl ? 'تعذر تحميل أكوادك' : 'Could not load your promo codes',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'أدخل كود الخصم' : 'Enter Promo Code',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: isRtl ? 'مثال: KHAWI10' : 'e.g. KHAWI10',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fareController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText:
                  isRtl ? 'تقدير قيمة المشوار (ريال)' : 'Estimated fare (SAR)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isPreviewing ? null : _handlePreview,
                  child: _isPreviewing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isRtl ? 'معاينة الخصم' : 'Preview Discount'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _isClaiming ? null : _handleClaim,
                  child: _isClaiming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isRtl ? 'حفظ الكود' : 'Claim Code'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, bool isRtl) {
    final preview = _preview!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: preview.applied
            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: preview.applied
              ? AppTheme.primaryGreen.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.applied
                ? (isRtl ? 'تم تطبيق الخصم' : 'Promo Applied')
                : (isRtl ? 'لم يتم التطبيق' : 'Not Applied'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(preview.message),
          const SizedBox(height: 8),
          Text(
            '${isRtl ? 'الخصم' : 'Discount'}: ${preview.discountSar.toStringAsFixed(2)} SAR',
          ),
          Text(
            '${isRtl ? 'السعر النهائي' : 'Final Fare'}: ${preview.finalFareSar.toStringAsFixed(2)} SAR',
          ),
        ],
      ),
    );
  }

  Widget _buildPromoList(
    BuildContext context,
    List<PromoCodeOffer> items,
    bool isRtl,
  ) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          isRtl ? 'لا توجد أكواد فعالة حالياً' : 'No active promo codes yet',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: items
          .map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: Text(entry.code),
                subtitle: Text(entry.title),
                trailing: Text(
                  entry.discountType == 'percent'
                      ? '${entry.discountValue.toStringAsFixed(0)}%'
                      : '${entry.discountValue.toStringAsFixed(0)} SAR',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _handlePreview() async {
    final fare = double.tryParse(_fareController.text.trim());
    final code = _codeController.text.trim();
    if (fare == null || fare <= 0 || code.isEmpty) {
      setState(() => _error = 'Enter a valid fare and promo code');
      return;
    }

    setState(() {
      _error = null;
      _isPreviewing = true;
    });

    try {
      final preview = await ref
          .read(promoCodesRepoProvider)
          .preview(code: code, fareSar: fare);
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isPreviewing = false);
      }
    }
  }

  Future<void> _handleClaim() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a promo code first');
      return;
    }

    setState(() {
      _error = null;
      _isClaiming = true;
    });

    try {
      final claimed = await ref.read(promoCodesRepoProvider).claim(code);
      if (!mounted) return;

      if (claimed == null) {
        setState(() => _error = 'Promo code could not be claimed');
      } else {
        _codeController.clear();
        ref.invalidate(_myPromoCodesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Claimed ${claimed.code}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }
}
