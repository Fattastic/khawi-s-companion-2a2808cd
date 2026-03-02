import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/features/promo_codes/domain/promo_code_offer.dart';
import 'package:khawi_flutter/features/promo_codes/domain/promo_discount_preview.dart';

class PromoCodesRepo {
  PromoCodesRepo(this._client);

  final SupabaseClient _client;

  Future<List<PromoCodeOffer>> fetchMyActive() async {
    try {
      final List<dynamic> rows =
          await _client.rpc<List<dynamic>>('get_my_active_promo_codes');
      return rows
          .whereType<Map<String, dynamic>>()
          .map(PromoCodeOffer.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const <PromoCodeOffer>[];
    }
  }

  Future<PromoCodeOffer?> claim(String code) async {
    final cleanedCode = code.trim().toUpperCase();
    if (cleanedCode.isEmpty) return null;

    final List<dynamic> rows = await _client.rpc<List<dynamic>>(
      'claim_promo_code',
      params: {'p_code': cleanedCode},
    );

    final mapped = rows
        .whereType<Map<String, dynamic>>()
        .map(PromoCodeOffer.fromJson)
        .toList(growable: false);

    if (mapped.isEmpty) return null;
    return mapped.first;
  }

  Future<PromoDiscountPreview> preview({
    required String code,
    required double fareSar,
  }) async {
    final cleanedCode = code.trim().toUpperCase();

    final List<dynamic> rows = await _client.rpc<List<dynamic>>(
      'preview_promo_discount',
      params: {
        'p_code': cleanedCode,
        'p_fare_sar': fareSar,
      },
    );

    final mapped = rows
        .whereType<Map<String, dynamic>>()
        .map(PromoDiscountPreview.fromJson)
        .toList(growable: false);

    if (mapped.isEmpty) {
      return const PromoDiscountPreview(
        applied: false,
        message: 'Could not preview promo code',
        discountSar: 0,
        finalFareSar: 0,
      );
    }

    return mapped.first;
  }
}
