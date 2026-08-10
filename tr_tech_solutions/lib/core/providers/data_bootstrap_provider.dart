import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';

/// Ensures the app shows usable sample data when live Supabase has no clients
/// (or the query fails due to RLS/schema issues).
final dataBootstrapProvider = FutureProvider<void>((ref) async {
  if (ref.read(demoModeProvider)) return;

  if (!SupabaseConfig.isConfigured) {
    _enableDemoMode(ref);
    return;
  }

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    final response = await Supabase.instance.client
        .from('clients')
        .select()
        .order('created_at', ascending: false);

    final clients = (response as List)
        .map((e) => ClientModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    if (clients.isEmpty) {
      _enableDemoMode(ref);
    }
  } catch (_) {
    // Empty DB, missing table, RLS, or schema mismatch — use demo seed data.
    _enableDemoMode(ref);
  }
});

void _enableDemoMode(Ref ref) {
  // Defer so we never modify providers during a widget build frame.
  Future.microtask(() {
    if (!ref.read(demoModeProvider)) {
      ref.read(demoModeProvider.notifier).state = true;
    }
  });
}
