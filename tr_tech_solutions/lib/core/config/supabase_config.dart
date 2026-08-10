import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url {
    try {
      return dotenv.env['SUPABASE_URL'] ??
          const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    } catch (_) {
      return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    }
  }

  static String get anonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ??
          const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    } catch (_) {
      return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    }
  }

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_SUPABASE') &&
      !url.contains('your-project') &&
      !anonKey.contains('YOUR_SUPABASE') &&
      !anonKey.contains('your-anon-key');
}
