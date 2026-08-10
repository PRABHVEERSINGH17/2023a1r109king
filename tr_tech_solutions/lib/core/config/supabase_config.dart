import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String _clean(String? value) {
    if (value == null) return '';
    // Windows CRLF in .env files often leaves a trailing \r that breaks URLs.
    return value.trim().replaceAll('\r', '');
  }

  static String get url {
    try {
      return _clean(
        dotenv.env['SUPABASE_URL'] ??
            const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      );
    } catch (_) {
      return _clean(
        const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      );
    }
  }

  static String get anonKey {
    try {
      return _clean(
        dotenv.env['SUPABASE_ANON_KEY'] ??
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );
    } catch (_) {
      return _clean(
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );
    }
  }

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      url.startsWith('http') &&
      !url.contains('YOUR_SUPABASE') &&
      !url.contains('your-project') &&
      !anonKey.contains('YOUR_SUPABASE') &&
      !anonKey.contains('your-anon-key');

  /// Deep link used to return into the Android/iOS app after OAuth.
  static const mobileOAuthRedirect = 'com.trtechsolutions.app://login-callback/';

  /// Redirect URL passed to Supabase OAuth (web origin or mobile deep link).
  static String get oauthRedirectTo {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return mobileOAuthRedirect;
  }
}
