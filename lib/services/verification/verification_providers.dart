import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/data/core/supabase_provider.dart';
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;
import 'identity_verifier.dart';
import 'vehicle_ownership_verifier.dart';

export 'identity_verifier.dart';
export 'vehicle_ownership_verifier.dart';

/// Provider for the identity verification service.
final identityVerifierProvider = Provider<IdentityVerifier>((ref) {
  if (kUseDevMode) return MockIdentityVerifier();
  final sb = ref.watch(supabaseProvider);
  return NafathIdentityVerifier((fn, body) async {
    final res = await sb.functions.invoke(fn, body: body);
    return res.data as Map<String, dynamic>;
  });
});

/// Provider for the vehicle ownership verification service.
final vehicleOwnershipVerifierProvider =
    Provider<VehicleOwnershipVerifier>((ref) {
  if (kUseDevMode) return MockVehicleOwnershipVerifier();
  final sb = ref.watch(supabaseProvider);
  // Default to manual document verifier; swap to AbsherLinkedVehicleVerifier
  // when official integration is available.
  return ManualDocumentVehicleVerifier((fn, body) async {
    final res = await sb.functions.invoke(fn, body: body);
    return res.data as Map<String, dynamic>;
  });
});
