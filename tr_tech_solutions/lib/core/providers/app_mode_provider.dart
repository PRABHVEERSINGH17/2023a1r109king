import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/local_auth_provider.dart';

/// Tracks whether the user is in local demo mode (no Supabase required).
final demoModeProvider = StateProvider<bool>((ref) => false);

/// True when Demo Mode, a device-local account, or a cloud session is active.
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (ref.watch(demoModeProvider)) return true;
  if (ref.watch(localAuthProvider)) return true;
  if (!SupabaseConfig.isConfigured) return false;
  try {
    return Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    return false;
  }
});
