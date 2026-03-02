/// Abstraction for identity verification providers (Nafath, manual, etc.).
///
/// Production implementations should integrate with licensed Saudi identity
/// verification partners. The [MockIdentityVerifier] can be used for dev/test.
abstract class IdentityVerifier {
  /// Initiates identity verification for the given [userId].
  ///
  /// Returns an [IdentityVerificationResult] indicating the outcome.
  /// Implementations may open external flows (e.g. Nafath app redirect).
  Future<IdentityVerificationResult> verify(String userId);

  /// Checks the current verification status for [userId].
  Future<IdentityVerificationStatus> checkStatus(String userId);
}

/// Result of an identity verification attempt.
class IdentityVerificationResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final String provider; // e.g. "nafath", "manual"

  const IdentityVerificationResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.provider = 'nafath',
  });
}

/// Current identity verification status.
enum IdentityVerificationStatus {
  /// Not yet attempted.
  none,

  /// Verification initiated, waiting for user action (e.g. Nafath app).
  pending,

  /// Successfully verified.
  verified,

  /// Verification failed or rejected.
  rejected,
}

// ─────────────────────────────────────────────────────────────────────────────
// NAFATH IDENTITY VERIFIER (Production scaffold)
// ─────────────────────────────────────────────────────────────────────────────

/// Production Nafath integration scaffold.
///
/// Nafath is Saudi Arabia's unified digital identity platform. This verifier
/// integrates with Nafath via a backend edge function that handles the
/// actual API handshake. The client initiates the flow and polls for status.
///
/// Integration points:
/// - Backend: Supabase Edge Function `verify_identity` handles Nafath API calls.
/// - Client: Opens Nafath app via deep link or shows verification code.
/// - Callback: Backend updates profile `is_identity_verified` on success.
class NafathIdentityVerifier implements IdentityVerifier {
  NafathIdentityVerifier(this._invokeEdgeFunction);

  /// Callable that invokes a Supabase edge function.
  final Future<Map<String, dynamic>> Function(
    String functionName,
    Map<String, dynamic> body,
  ) _invokeEdgeFunction;

  @override
  Future<IdentityVerificationResult> verify(String userId) async {
    try {
      final response = await _invokeEdgeFunction('verify_identity', {
        'user_id': userId,
        'method': 'nafath',
      });
      final verified = (response['verified'] as bool?) ?? false;
      return IdentityVerificationResult(
        success: verified,
        transactionId: response['transaction_id'] as String?,
        provider: 'nafath',
      );
    } catch (e) {
      return IdentityVerificationResult(
        success: false,
        errorMessage: e.toString(),
        provider: 'nafath',
      );
    }
  }

  @override
  Future<IdentityVerificationStatus> checkStatus(String userId) async {
    try {
      final response = await _invokeEdgeFunction('verify_identity', {
        'user_id': userId,
        'method': 'nafath',
        'dry_run': true, // check status only
      });
      final status = response['status'] as String?;
      return switch (status) {
        'verified' => IdentityVerificationStatus.verified,
        'pending' => IdentityVerificationStatus.pending,
        'rejected' => IdentityVerificationStatus.rejected,
        _ => IdentityVerificationStatus.none,
      };
    } catch (_) {
      return IdentityVerificationStatus.none;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK IDENTITY VERIFIER (Dev / Test)
// ─────────────────────────────────────────────────────────────────────────────

/// Mock verifier that always succeeds after a brief delay.
class MockIdentityVerifier implements IdentityVerifier {
  @override
  Future<IdentityVerificationResult> verify(String userId) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const IdentityVerificationResult(
      success: true,
      transactionId: 'mock-txn-001',
      provider: 'nafath',
    );
  }

  @override
  Future<IdentityVerificationStatus> checkStatus(String userId) async {
    return IdentityVerificationStatus.verified;
  }
}
