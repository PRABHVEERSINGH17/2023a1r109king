import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';

const kDemoEmail = 'admin@trtechsolutions.com';
const kDemoPassword = 'demo1234';

final authStateProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(const AuthState(AuthChangeEvent.initialSession, null));
  }
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  return Supabase.instance.client.auth.currentUser;
});

class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  bool get isDemoMode => _ref.read(demoModeProvider);

  String? get currentUserEmail {
    if (isDemoMode) return kDemoEmail;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.email;
  }

  String? get currentUserId {
    if (isDemoMode) return 'demo-user-001';
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.id;
  }

  bool _isDemoCredentials(String email, String password) {
    return email.trim().toLowerCase() == kDemoEmail && password == kDemoPassword;
  }

  Future<void> enterDemoMode() async {
    _ref.read(demoModeProvider.notifier).state = true;
  }

  Future<void> signIn(String email, String password) async {
    // Built-in demo account always works, even when Supabase is configured.
    if (_isDemoCredentials(email, password) || !SupabaseConfig.isConfigured) {
      await enterDemoMode();
      return;
    }

    _ref.read(demoModeProvider.notifier).state = false;
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String fullName) async {
    if (!SupabaseConfig.isConfigured) {
      await enterDemoMode();
      return;
    }

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // If email confirmation is disabled, session is returned immediately.
    if (response.session != null) {
      return;
    }
  }

  Future<void> signOut() async {
    if (isDemoMode) {
      _ref.read(demoModeProvider.notifier).state = false;
    }
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
