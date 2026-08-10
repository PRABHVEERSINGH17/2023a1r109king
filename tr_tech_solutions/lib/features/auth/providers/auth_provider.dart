import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';

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
    if (isDemoMode) return 'admin@trtechsolutions.com';
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.email;
  }

  String? get currentUserId {
    if (isDemoMode) return 'demo-user-001';
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> enterDemoMode() async {
    _ref.read(demoModeProvider.notifier).state = true;
  }

  Future<void> signIn(String email, String password) async {
    if (!SupabaseConfig.isConfigured) {
      // Demo login — any credentials work
      await enterDemoMode();
      return;
    }
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
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() async {
    if (isDemoMode) {
      _ref.read(demoModeProvider.notifier).state = false;
      return;
    }
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.signOut();
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
