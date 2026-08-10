import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';

/// Boots usable data for the session.
///
/// - No Supabase config → Demo Mode
/// - Live query errors → Demo Mode (so the CRM never looks "broken")
/// - Empty live DB is left alone (user can add clients or switch to demo in Settings)
final dataBootstrapProvider = FutureProvider<void>((ref) async {
  if (ref.read(demoModeProvider)) return;

  if (!SupabaseConfig.isConfigured) {
    _enableDemoMode(ref);
    return;
  }

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    await Supabase.instance.client.from('clients').select('id').limit(1);
  } catch (_) {
    // Schema/RLS/network failure — fall back to a fully working demo workspace.
    _enableDemoMode(ref);
  }
});

void _enableDemoMode(Ref ref) {
  Future.microtask(() {
    if (!ref.read(demoModeProvider)) {
      ref.read(demoModeProvider.notifier).state = true;
    }
  });
}
