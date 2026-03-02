/// Abstraction for vehicle ownership verification.
///
/// Saudi Arabia context: Vehicle ownership is tracked via Absher (MOI) and
/// vehicle registration (Istimara). This abstraction supports:
/// - Tier A: Official integration via licensed government service adapters.
/// - Tier B: Manual document upload fallback.
abstract class VehicleOwnershipVerifier {
  /// Initiates vehicle ownership verification for [userId].
  ///
  /// [method] can be 'official' (Tier A) or 'manual' (Tier B).
  Future<VehicleVerificationResult> verify(
    String userId, {
    required VehicleVerificationRequest request,
  });

  /// Checks the current verification status.
  Future<VehicleVerificationStatus> checkStatus(String userId);
}

/// Request payload for vehicle verification.
class VehicleVerificationRequest {
  /// 'official' (Tier A - Absher/Nafath linked) or 'manual' (Tier B - document upload).
  final String method;

  /// Vehicle plate number (Saudi format, e.g. "ABC 1234").
  final String plateNumber;

  /// Vehicle model description (e.g. "Toyota Camry 2023").
  final String vehicleModel;

  /// URL of uploaded Istimara (vehicle registration) photo. Used in Tier B.
  final String? istimaraPhotoUrl;

  /// URL of uploaded selfie/liveness photo. Used in Tier B if no Nafath identity.
  final String? selfiePhotoUrl;

  const VehicleVerificationRequest({
    required this.method,
    required this.plateNumber,
    required this.vehicleModel,
    this.istimaraPhotoUrl,
    this.selfiePhotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'plate_number': plateNumber,
        'vehicle_model': vehicleModel,
        if (istimaraPhotoUrl != null) 'istimara_photo_url': istimaraPhotoUrl,
        if (selfiePhotoUrl != null) 'selfie_photo_url': selfiePhotoUrl,
      };
}

/// Result of a vehicle verification attempt.
class VehicleVerificationResult {
  final bool submitted;
  final String status; // 'pending', 'approved', 'rejected', 'error'
  final String? errorMessage;
  final String? verificationId;

  const VehicleVerificationResult({
    required this.submitted,
    required this.status,
    this.errorMessage,
    this.verificationId,
  });
}

/// Current vehicle verification status.
enum VehicleVerificationStatus {
  /// No verification attempted.
  none,

  /// Documents submitted, awaiting review.
  pending,

  /// Ownership verified and approved.
  approved,

  /// Verification rejected.
  rejected,
}

// ─────────────────────────────────────────────────────────────────────────────
// ABSHER-LINKED VERIFIER (Tier A - Production scaffold)
// ─────────────────────────────────────────────────────────────────────────────

/// Production vehicle ownership verifier using Absher-linked proof.
///
/// Integration architecture:
/// 1. Client submits plate number + Nafath-verified identity.
/// 2. Backend edge function queries a licensed integrator (e.g. Elm, Yakeen)
///    to cross-reference vehicle ownership with national ID.
/// 3. Result returned and persisted in profile.
///
/// This class provides the client-side adapter. The actual government API
/// integration lives in the backend edge function `verify_vehicle_ownership`.
class AbsherLinkedVehicleVerifier implements VehicleOwnershipVerifier {
  AbsherLinkedVehicleVerifier(this._invokeEdgeFunction);

  final Future<Map<String, dynamic>> Function(
    String functionName,
    Map<String, dynamic> body,
  ) _invokeEdgeFunction;

  @override
  Future<VehicleVerificationResult> verify(
    String userId, {
    required VehicleVerificationRequest request,
  }) async {
    try {
      final response = await _invokeEdgeFunction('verify_vehicle_ownership', {
        'user_id': userId,
        ...request.toJson(),
      });
      return VehicleVerificationResult(
        submitted: true,
        status: (response['status'] as String?) ?? 'pending',
        verificationId: response['verification_id'] as String?,
      );
    } catch (e) {
      return VehicleVerificationResult(
        submitted: false,
        status: 'error',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<VehicleVerificationStatus> checkStatus(String userId) async {
    try {
      final response = await _invokeEdgeFunction('verify_vehicle_ownership', {
        'user_id': userId,
        'check_only': true,
      });
      final status = response['status'] as String?;
      return switch (status) {
        'approved' => VehicleVerificationStatus.approved,
        'pending' => VehicleVerificationStatus.pending,
        'rejected' => VehicleVerificationStatus.rejected,
        _ => VehicleVerificationStatus.none,
      };
    } catch (_) {
      return VehicleVerificationStatus.none;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MANUAL DOCUMENT VERIFIER (Tier B - Fallback)
// ─────────────────────────────────────────────────────────────────────────────

/// Fallback verifier that accepts document uploads for manual review.
///
/// Flow:
/// 1. User uploads Istimara photo + selfie.
/// 2. Backend stores documents and creates a review ticket.
/// 3. Status = 'pending' until staff approves.
class ManualDocumentVehicleVerifier implements VehicleOwnershipVerifier {
  ManualDocumentVehicleVerifier(this._invokeEdgeFunction);

  final Future<Map<String, dynamic>> Function(
    String functionName,
    Map<String, dynamic> body,
  ) _invokeEdgeFunction;

  @override
  Future<VehicleVerificationResult> verify(
    String userId, {
    required VehicleVerificationRequest request,
  }) async {
    try {
      final response = await _invokeEdgeFunction('submit_vehicle_documents', {
        'user_id': userId,
        ...request.toJson(),
      });
      return VehicleVerificationResult(
        submitted: true,
        status: 'pending',
        verificationId: response['verification_id'] as String?,
      );
    } catch (e) {
      return VehicleVerificationResult(
        submitted: false,
        status: 'error',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<VehicleVerificationStatus> checkStatus(String userId) async {
    try {
      final response = await _invokeEdgeFunction('submit_vehicle_documents', {
        'user_id': userId,
        'check_only': true,
      });
      final status = response['status'] as String?;
      return switch (status) {
        'approved' => VehicleVerificationStatus.approved,
        'pending' => VehicleVerificationStatus.pending,
        'rejected' => VehicleVerificationStatus.rejected,
        _ => VehicleVerificationStatus.none,
      };
    } catch (_) {
      return VehicleVerificationStatus.none;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK VEHICLE VERIFIER (Dev / Test)
// ─────────────────────────────────────────────────────────────────────────────

/// Mock verifier that always returns 'pending' then 'approved'.
class MockVehicleOwnershipVerifier implements VehicleOwnershipVerifier {
  bool _hasSubmitted = false;

  @override
  Future<VehicleVerificationResult> verify(
    String userId, {
    required VehicleVerificationRequest request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _hasSubmitted = true;
    return const VehicleVerificationResult(
      submitted: true,
      status: 'approved',
      verificationId: 'mock-veh-001',
    );
  }

  @override
  Future<VehicleVerificationStatus> checkStatus(String userId) async {
    return _hasSubmitted
        ? VehicleVerificationStatus.approved
        : VehicleVerificationStatus.none;
  }
}
