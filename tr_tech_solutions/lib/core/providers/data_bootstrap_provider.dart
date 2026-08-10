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
    ref.read(demoModeProvider.notifier).state = true;
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
      ref.read(demoModeProvider.notifier).state = true;
    }
  } catch (_) {
    // Empty DB, missing table, RLS, or schema mismatch — use demo seed data.
    ref.read(demoModeProvider.notifier).state = true;
  }
});
