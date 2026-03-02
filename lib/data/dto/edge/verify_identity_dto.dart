class VerifyIdentityRequest {
  final String userId;
  final bool dryRun;
  final String? method;

  const VerifyIdentityRequest({
    required this.userId,
    this.dryRun = false,
    this.method,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'dry_run': dryRun,
        if (method != null) 'method': method,
      };
}

class VerifyIdentityResponse {
  final bool verified;
  final String? status;
  final String? message;

  const VerifyIdentityResponse({
    required this.verified,
    this.status,
    this.message,
  });

  factory VerifyIdentityResponse.fromJson(Map<String, dynamic> json) {
    return VerifyIdentityResponse(
      verified: (json['verified'] as bool?) ??
          (json['is_verified'] as bool?) ??
          false,
      status: json['status'] as String?,
      message: json['message'] as String?,
    );
  }
}
