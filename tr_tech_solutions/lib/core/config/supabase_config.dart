import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_SUPABASE') &&
      !anonKey.contains('YOUR_SUPABASE');
}
