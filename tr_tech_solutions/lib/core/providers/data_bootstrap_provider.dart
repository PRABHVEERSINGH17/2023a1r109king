import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';

/// Boots usable data for a live session.
/// Does not enable Demo Mode — production uses cloud auth only.
final dataBootstrapProvider = FutureProvider<void>((ref) async {
  if (ref.read(demoModeProvider)) return;
  if (!SupabaseConfig.isConfigured) return;

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    await Supabase.instance.client.from('clients').select('id').limit(1);
  } catch (_) {
    // Leave live mode; UI will show load errors / empty states.
  }
});
