import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/social_provider.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => 'AuthFailure: $message';
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  @override
  String toString() => 'RateLimitException: $message';
}

class AuthRepo {
  final SupabaseClient _sb;
  AuthRepo(this._sb);

  Future<User?> signInAnonymously() async {
    final res = await _sb.auth.signInAnonymously();
    return res.user;
  }

  Future<User?> signUp(String email, String password) async {
    final res = await _sb.auth.signUp(email: email, password: password);
    return res.user;
  }

  Future<User?> signInWithPassword(String email, String password) async {
    final res =
        await _sb.auth.signInWithPassword(email: email, password: password);
    return res.user;
  }

  Future<void> signOut() async {
    await _sb.auth.signOut();
  }

  Future<void> sendOtp(String phone) async {
    await signInWithOtp(phone: phone); // Route to the rate-limited method
  }

  Future<void> verifyOtp(String phone, String code) async {
    await _sb.auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: code,
    );
  }

  Future<void> signInWithOtp({required String phone}) async {
    try {
      await _sb.auth.signInWithOtp(phone: phone, shouldCreateUser: true);
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('too many requests') ||
          e.statusCode == '429') {
        throw RateLimitException(
          'Too many OTP requests. Please wait and try again.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithOAuth(
    SocialProvider provider, {
    String? redirectTo,
  }) async {
    final oauthProvider = switch (provider) {
      SocialProvider.google => OAuthProvider.google,
      SocialProvider.apple => OAuthProvider.apple,
    };
    await _sb.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }
}
