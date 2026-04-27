import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over Supabase email-OTP auth.
///
/// Email OTP works out of the box on Supabase free tier — no external
/// SMS provider required.
class AuthService {
  final SupabaseClient? _client;
  AuthService(this._client);

  bool get isLive => _client != null;

  /// Ask Supabase to email a 6-digit one-time passcode.
  Future<void> sendOtp(String email) async {
    if (_client == null) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  /// Exchange the emailed code for a Supabase session.
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    if (_client == null) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (code != '123456') {
        throw const AuthException(
          'Invalid code. In mock mode use 123456.',
        );
      }
      return;
    }
    final res = await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
    if (res.session == null) {
      throw const AuthException('Verification failed — no session returned');
    }
  }

  Future<void> resendOtp(String email) => sendOtp(email);

  /// Attach display name + phone to the user profile after successful OTP.
  Future<void> updateProfile({String? name, String? phone}) async {
    if (_client == null) return;
    await _client.auth.updateUser(
      UserAttributes(
        phone: phone,
        data: {if (name != null) 'name': name},
      ),
    );
  }
}
