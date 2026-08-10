import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/shared/services/demo_persistence.dart';

/// Boots usable data for the session.
///
/// - No Supabase config → Demo Mode (unless user chose Go Online)
/// - Live query errors → Demo Mode only when user has not chosen Go Online
/// - Empty live DB is left alone (user can add clients)
final dataBootstrapProvider = FutureProvider<void>((ref) async {
  if (ref.read(demoModeProvider)) return;

  if (!SupabaseConfig.isConfigured) {
    if (!DemoPersistence.preferLive) {
      _enableDemoMode(ref);
    }
    return;
  }

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    await Supabase.instance.client.from('clients').select('id').limit(1);
  } catch (_) {
    // Schema/RLS/network failure — stay live if user explicitly went online.
    if (!DemoPersistence.preferLive) {
      _enableDemoMode(ref);
    }
  }
});

void _enableDemoMode(Ref ref) {
  Future.microtask(() async {
    if (!ref.read(demoModeProvider) && !DemoPersistence.preferLive) {
      await DemoPersistence.setDemoMode(true);
      ref.read(demoModeProvider.notifier).state = true;
    }
  });
}
