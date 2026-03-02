import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/auth/data/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides a fake client that always throws a rate limit exception for OTP
class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  GoTrueClient get auth => FakeGoTrueClient();
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Future<void> signInWithOtp({
    String? email,
    String? phone,
    String? emailRedirectTo,
    bool? shouldCreateUser,
    Map<String, dynamic>? data,
    String? captchaToken,
    OtpChannel channel = OtpChannel.sms,
  }) async {
    throw const AuthException('Too many requests', statusCode: '429');
  }
}

void main() {
  test('signInWithOtp surfaces RateLimitException when Supabase returns 429',
      () async {
    final repo = AuthRepo(FakeSupabaseClient());

    expect(
      () => repo.signInWithOtp(phone: '+966500000000'),
      throwsA(isA<RateLimitException>()),
    );
  });
}
