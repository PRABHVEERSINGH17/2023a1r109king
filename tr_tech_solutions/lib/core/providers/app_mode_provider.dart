import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the user is in local demo mode (no Supabase required).
final demoModeProvider = StateProvider<bool>((ref) => false);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(demoModeProvider);
});
